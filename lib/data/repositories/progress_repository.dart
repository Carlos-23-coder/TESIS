import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_model.dart';

class ProgressRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 🔥 GUARDAR PROGRESO
  Future<void> saveProgress(
    ProgressModel progress,
  ) async {

    await _firestore
        .collection("progress")
        .doc(
          "${progress.userId}_${progress.game}_${progress.level}",
        )
        .set(
          progress.toMap(),
        );
  }

  /// 📚 OBTENER PROGRESO DEL ALUMNO
  Future<List<Map<String, dynamic>>>
      getStudentProgress(
    String userId,
  ) async {

    final snapshot = await _firestore
        .collection("progress")
        .where("userId", isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  /// ⭐ OBTENER TOTAL DE ESTRELLAS
  Future<int> getTotalStars(
    String userId,
  ) async {

    final snapshot = await _firestore
        .collection("progress")
        .where("userId", isEqualTo: userId)
        .get();

    int total = 0;

    for (var doc in snapshot.docs) {

      total +=
          (doc.data()["stars"] ?? 0) as int;
    }

    return total;
  }
}