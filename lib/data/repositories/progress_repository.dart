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

  /// ⭐ TOTAL DE ESTRELLAS
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

  /// 📊 TODOS LOS PROGRESOS
  Future<List<Map<String, dynamic>>>
      getAllProgress() async {

    final snapshot = await _firestore
        .collection("progress")
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  /// 🏆 RANKING DE ALUMNOS
  Future<List<Map<String, dynamic>>>
      getRanking() async {

    final snapshot = await _firestore
        .collection("progress")
        .get();

    Map<String, int> ranking = {};

    for (var doc in snapshot.docs) {

      final data = doc.data();

      final String userId =
          data["userId"]?.toString() ?? "";

      final int stars =
          (data["stars"] ?? 0) as int;

      if (ranking.containsKey(userId)) {

        ranking[userId] =
            ranking[userId]! + stars;

      } else {

        ranking[userId] = stars;
      }
    }

    List<Map<String, dynamic>>
        rankingList = [];

    ranking.forEach((userId, stars) {

      rankingList.add({

        "userId": userId,
        "stars": stars,
      });
    });

    rankingList.sort(
      (a, b) =>
          b["stars"]
              .compareTo(a["stars"]),
    );

    return rankingList;
  }

  /// 📈 PORCENTAJE DE AVANCE
  Future<double> getProgressPercentage(
    String userId,
  ) async {

    final snapshot = await _firestore
        .collection("progress")
        .where("userId", isEqualTo: userId)
        .get();

    int completedLevels =
        snapshot.docs.length;

    /// TOTAL DE NIVELES
    int totalLevels = 10;

    return
        (completedLevels / totalLevels) *
            100;
  }
}