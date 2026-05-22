import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// 🔥 CREAR USUARIO
  Future<void> createUser({
    required String email,
    required String username,
    required String role,
    required String password,
    required String pin,
  }) async {

    /// 🔐 CREAR EN FIREBASE AUTH
    await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    /// 💾 GUARDAR DATOS EN FIRESTORE
    await _db
        .collection('users')
        .doc(email)
        .set({

      'username': username,
      'email': email,
      'role': role,

      /// ⚠️ SOLO PARA TU PROYECTO EDUCATIVO
      /// EN PRODUCCIÓN NO SE DEBEN GUARDAR
      /// PASSWORDS NI PINS EN FIRESTORE
      'password': password,
      'pin': pin,

      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  /// 🔐 LOGIN FLEXIBLE
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

      /// ❌ NO EXISTE
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

  /// 🔥 GUARDAR PROGRESO
  Future<void> saveProgress({

    required String email,
    required String game,
    required int score,
    required int level,

  }) async {

    final userRef =
        _db.collection('users')
            .doc(email);

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
  }

  /// 📚 OBTENER PROGRESO
  Future<List<Map<String, dynamic>>>
      getUserProgress(
    String email,
  ) async {

    final snapshot = await _db
        .collection('users')
        .doc(email)
        .collection('progress')
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }
}