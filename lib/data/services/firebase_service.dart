import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'tutor_resolver.dart';

class FirebaseService {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;
  
  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 🔥 CREAR USUARIO
  Future<void> createUser({
    required String email,
    required String username,
    required String role,
    required String password,
    required String pin,
  }) async {
    email = email.trim().toLowerCase();
    /// 🔐 CREAR EN FIREBASE AUTH
    await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    /// 💾 GUARDAR DATOS EN FIRESTORE
    final normalizedEmail =
    email.trim().toLowerCase();

    if (role != 'Alumno') {
      throw Exception('Solo se pueden registrar alumnos.');
    }

    final userData = <String, dynamic>{
      'username': username,
      'email': normalizedEmail,
      'role': role,

      /// ⚠️ SOLO PARA TU PROYECTO EDUCATIVO
      /// EN PRODUCCIÓN NO SE DEBEN GUARDAR
      /// PASSWORDS NI PINS EN FIRESTORE
      'password': password,
      'pin': pin,

      'createdAt': FieldValue.serverTimestamp(),
    };

    if (role == 'Alumno') {
      userData['tutorEmail'] = TutorResolver.defaultTutorEmail;
    }

    await _db.collection('users').doc(normalizedEmail).set(userData);
  }

  /// CREAR TUTOR DESDE EL PANEL ADMIN
  /// Usa una app secundaria para no reemplazar la sesion actual del admin.
  Future<void> createTutorByAdmin({
    required String email,
    required String username,
    required String password,
    required String pin,
  }) async {
    final normalizedEmail =
        email.trim().toLowerCase();

    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'AdminTutorCreation',
        options: Firebase.app().options,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        secondaryApp = Firebase.app('AdminTutorCreation');
      } else {
        rethrow;
      }
    }

    final secondaryAuth =
        FirebaseAuth.instanceFor(app: secondaryApp);

    await secondaryAuth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    await secondaryAuth.signOut();

    await _db.collection('users').doc(normalizedEmail).set({
      'username': username,
      'email': normalizedEmail,
      'role': 'Tutor',
      'password': password,
      'pin': pin,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': _auth.currentUser?.email ?? 'admin-local',
    });
  }

  /// 🔐 LOGIN FLEXIBLE (OFFLINE FIRST)
  /// Intenta primero SQLite, luego Firebase
  /// Puede iniciar con:
  /// - correo + contraseña
  /// - usuario + contraseña
  /// - correo + pin
  /// - usuario + pin
  Future<Map<String, dynamic>?> login({

    required String identifier,
    required String passwordOrPin,
    required String role,

  }) async {

      identifier = identifier.trim();

      if (identifier.contains("@")) {
        identifier = identifier.toLowerCase();
      }

    try {

      /// 📱 INTENTA LOGIN OFFLINE (SQLITE)
      final offlineResult =
          await _loginOffline(
        identifier: identifier,
        passwordOrPin: passwordOrPin,
        role: role,
      );

      if (offlineResult != null) {

        print("✅ Login OFFLINE exitoso");

        try {

          await _auth.signInWithEmailAndPassword(
            email: offlineResult["email"],
            password: offlineResult["password"],
          );

          print(
            "✅ FirebaseAuth sincronizado desde login principal",
          );

        } catch (e) {

          print(
            "❌ Error iniciando FirebaseAuth: $e",
          );
        }

        return offlineResult;
      }

      /// 🌐 SI FALLA OFFLINE, INTENTA FIREBASE
      print(
        "📶 Intentando login con Firebase...",
      );

      return await _loginFirebase(
        identifier: identifier,
        passwordOrPin: passwordOrPin,
        role: role,
      );

    } catch (e) {

      print(
        "ERROR LOGIN: $e",
      );

      return null;
    }
  }

  /// 📱 LOGIN OFFLINE CON SQLITE
  Future<Map<String, dynamic>?> _loginOffline({

    required String identifier,
    required String passwordOrPin,
    required String role,

  }) async {

    try {

      final db = await _dbHelper.database;

      /// 🔍 BUSCAR POR EMAIL O USERNAME
      final List<Map<String, dynamic>>
          results = await db.query(

        'users',

        where: '(email = ? OR username = ?) AND role = ?',

        whereArgs: [
          identifier,
          identifier,
          role,
        ],
      );

      /// ❌ NO EXISTE OFFLINE
      if (results.isEmpty) {
        return null;
      }

      final userData = results.first;
        print("========== LOGIN SQLITE ==========");
        print(userData);

      final String savedPassword =
          userData["password"] ?? "";

      final String savedPin =
          userData["pin"] ?? "";

      /// 🔐 VALIDAR PASSWORD O PIN
      final bool validAccess =
        passwordOrPin == savedPassword ||
        passwordOrPin == savedPin;

        if (!validAccess) {
          return null;
        }

        /// 🔥 INICIAR SESIÓN EN FIREBASE AUTH
        try {

          await _auth.signInWithEmailAndPassword(
            email: userData["email"],
            password: savedPassword,
          );

          print(
            "✅ FirebaseAuth sincronizado desde login offline",
          );

        } catch (e) {

          print(
            "⚠️ Error FirebaseAuth: $e",
          );
        }

        /// ✅ RETORNAR DATOS DEL USUARIO
        return userData;

    } catch (e) {

      print(
        "ERROR LOGIN OFFLINE: $e",
      );

      return null;
    }
  }


  /// 🌐 LOGIN CON FIREBASE (ONLINE)
  Future<Map<String, dynamic>?> _loginFirebase({

    required String identifier,
    required String passwordOrPin,
    required String role,

  }) async {

    try {

      QuerySnapshot snapshot;

      /// 🔍 BUSCAR POR EMAIL O USERNAME
      if (identifier.contains("@")) {

        snapshot = await _db
            .collection("users")
            .where(
              "email",
              isEqualTo: identifier,
            )
            .where(
              "role",
              isEqualTo: role,
            )
            .get();

      } else {

        snapshot = await _db
            .collection("users")
            .where(
              "username",
              isEqualTo: identifier,
            )
            .where(
              "role",
              isEqualTo: role,
            )
            .get();
      }

      /// ❌ NO EXISTE EN FIREBASE
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final userData =
          snapshot.docs.first.data()
              as Map<String, dynamic>;

      final String savedPassword =
          userData["password"] ?? "";

      final String savedPin =
          userData["pin"] ?? "";

      /// 🔐 VALIDAR PASSWORD O PIN
      final bool validAccess =

          passwordOrPin == savedPassword ||

          passwordOrPin == savedPin;

      if (!validAccess) {
        return null;
      }

      /// 🔥 LOGIN FIREBASE AUTH
      /// SI ENTRA CON PIN,
      /// SE USA LA PASSWORD REAL
      await _auth
          .signInWithEmailAndPassword(

        email: userData["email"],

        password: savedPassword,
      );

      return userData;

    } catch (e) {

      print(
        "ERROR LOGIN FIREBASE: $e",
      );

      return null;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {

    await _auth.signOut();
  }

  /// 👤 USUARIO ACTUAL
  User? getCurrentUser() {

    return _auth.currentUser;
  }

  /// 🔥 GUARDAR PROGRESO (OFFLINE FIRST)
  Future<void> saveProgress({

    required String email,
    required String game,
    required int score,
    required int level,

  }) async {

    try {

      /// 📱 GUARDAR EN SQLITE (OFFLINE)
      await _saveProgressOffline(
        email: email,
        game: game,
        score: score,
        level: level,
      );

      /// 🌐 INTENTA GUARDAR EN FIREBASE
      /// (SI HAY CONEXIÓN)
      try {

        final userRef =
            _db.collection('users')
                .doc(email.toLowerCase());

        await userRef
            .collection('progress')
            .doc("${game}_$level")
            .set({

          'game': game,
          'score': score,
          'level': level,

          'date':
              FieldValue.serverTimestamp(),
        });

      } catch (e) {

        print(
          "⚠️ No se sincronizó con Firebase: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR GUARDAR PROGRESO: $e",
      );
    }
  }

  /// 📱 GUARDAR PROGRESO OFFLINE
  Future<void> _saveProgressOffline({

    required String email,
    required String game,
    required int score,
    required int level,

  }) async {

    final db = await _dbHelper.database;

    /// CREAR TABLA SI NO EXISTE
    await db.execute('''

      CREATE TABLE IF NOT EXISTS progress (

        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        game TEXT NOT NULL,
        stars INTEGER NOT NULL,
        level INTEGER NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(email, game, level)
      )

    ''');

    /// GUARDAR O ACTUALIZAR
    await db.insert(

      'progress',

      {

        'email': email,
        'game': game,
        'stars': score,
        'level': level,
        'date': DateTime.now().toIso8601String(),
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// 📚 OBTENER PROGRESO (OFFLINE FIRST)
  Future<List<Map<String, dynamic>>>
      getUserProgress(
    String email,
  ) async {

    try {

      /// 📱 INTENTA OBTENER OFFLINE
      final offlineProgress =
          await _getUserProgressOffline(
        email,
      );

      if (offlineProgress.isNotEmpty) {
        return offlineProgress;
      }

      /// 🌐 SI NO HAY OFFLINE,
      /// INTENTA FIREBASE
      return await _getUserProgressFirebase(
        email,
      );

    } catch (e) {

      print(
        "ERROR OBTENER PROGRESO: $e",
      );

      return [];
    }
  }

  /// 📱 OBTENER PROGRESO OFFLINE
  Future<List<Map<String, dynamic>>>
      _getUserProgressOffline(
    String email,
  ) async {

    try {

      final db =
          await _dbHelper.database;

      /// CREAR TABLA SI NO EXISTE
      await db.execute('''

        CREATE TABLE IF NOT EXISTS progress (

          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          game TEXT NOT NULL,
          stars INTEGER NOT NULL,
          level INTEGER NOT NULL,
          date TEXT NOT NULL,
          UNIQUE(email, game, level)
        )

      ''');

      final results = await db.query(

        'progress',

        where: 'email = ?',

        whereArgs: [email],
      );

      return results;

    } catch (e) {

      print(
        "ERROR OBTENER PROGRESO OFFLINE: $e",
      );

      return [];
    }
  }

  /// 🌐 OBTENER PROGRESO DE FIREBASE
  Future<List<Map<String, dynamic>>>
      _getUserProgressFirebase(
    String email,
  ) async {

    try {

      final snapshot = await _db
          .collection('users')
          .doc(email)
          .collection('progress')
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();

    } catch (e) {

      print(
        "ERROR OBTENER PROGRESO FIREBASE: $e",
      );

      return [];
    }
  }
}
