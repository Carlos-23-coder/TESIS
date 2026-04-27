import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 CREAR USUARIO EN FIREBASE
  Future<void> createUser({
    required String email,
    required String username,
    required String role,
  }) async {
    await _db.collection('users').doc(email).set({
      'username': username,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔥 GUARDAR PROGRESO
  Future<void> saveProgress({
    required String email,
    required String game,
    required int score,
    required int level,
  }) async {

    final userRef = _db.collection('users').doc(email);

    await userRef.collection('progress').add({
      'game': game,
      'score': score,
      'level': level,
      'date': FieldValue.serverTimestamp(),
    });
  }

  /// 🔥 OBTENER PROGRESO (para tutor)
  Future<List<Map<String, dynamic>>> getUserProgress(String email) async {
    final snapshot = await _db
        .collection('users')
        .doc(email)
        .collection('progress')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}