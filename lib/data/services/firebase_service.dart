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
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  /// 🔐 LOGIN FIREBASE
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {

    return await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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
        _db.collection('users').doc(email);

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