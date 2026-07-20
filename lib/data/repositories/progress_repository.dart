import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/progress_model.dart';

class ProgressRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 🔥 GUARDAR PROGRESO (OFFLINE FIRST)
  Future<void> saveProgress(
    ProgressModel progress,
  ) async {

    try {

      /// 📱 GUARDAR OFFLINE PRIMERO
      await _saveProgressOffline(
        progress,
      );

      /// 🌐 INTENTA SINCRONIZAR CON FIREBASE
      try {

        await _firestore
            .collection("progress")
            .doc(
              "${progress.userId}_${progress.game}_${progress.level}",
            )
            .set(
              progress.toMap(),
            );

        /// 📤 MARCAR COMO SINCRONIZADO
        final db =
            await _dbHelper.database;

        await db.update(

          'progress',

          {'synced': 1},

          where: '''
          email = ? AND game = ? AND level = ?
          ''',

          whereArgs: [
            progress.userId,
            progress.game,
            progress.level,
          ],
        );

      } catch (e) {

        print(
          "⚠️ Progreso guardado offline, se sincronizará después: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR GUARDAR PROGRESO: $e",
      );
    }
  }

  /// 📱 GUARDAR OFFLINE
  Future<void> _saveProgressOffline(
    ProgressModel progress,
  ) async {

    final db =
        await _dbHelper.database;

    await db.insert(

      'progress',

      {

        'email': progress.userId,
        'game': progress.game,
        'stars': progress.stars ?? 0,
        'level': progress.level,
        'date': DateTime.now().toIso8601String(),
        'synced': 0,
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// 📚 OBTENER PROGRESO DEL ALUMNO (OFFLINE FIRST)
  Future<List<Map<String, dynamic>>>
      getStudentProgress(
    String userId,
  ) async {

    try {

      /// 📱 INTENTA OBTENER OFFLINE
      final offlineProgress =
          await _getStudentProgressOffline(
        userId,
      );

      if (offlineProgress.isNotEmpty) {
        return offlineProgress;
      }

      /// 🌐 SI NO HAY OFFLINE, OBTIENE DE FIREBASE
      return await _getStudentProgressFirebase(
        userId,
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
      _getStudentProgressOffline(
    String userId,
  ) async {

    try {

      final db =
          await _dbHelper.database;

      return await db.query(

        'progress',

        where: 'email = ?',

        whereArgs: [userId],
      );

    } catch (e) {

      print(
        "ERROR OBTENER PROGRESO OFFLINE: $e",
      );

      return [];
    }
  }

  /// 🌐 OBTENER PROGRESO DE FIREBASE
  Future<List<Map<String, dynamic>>>
      _getStudentProgressFirebase(
    String userId,
  ) async {

    try {

      final snapshot = await _firestore
          .collection("progress")
          .where("userId", isEqualTo: userId)
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

  /// ⭐ TOTAL DE ESTRELLAS (OFFLINE FIRST)
  Future<int> getTotalStars(
    String userId,
  ) async {

    final progress =
        await getStudentProgress(
      userId,
    );

    int total = 0;

    for (var doc in progress) {

      total +=
          (doc["stars"] ?? 0) as int;
    }

    return total;
  }

  /// 📊 TODOS LOS PROGRESOS
  Future<List<Map<String, dynamic>>>
      getAllProgress() async {

    try {

      final db =
          await _dbHelper.database;

      final offlineProgress =
          await db.query('progress');

      if (offlineProgress.isNotEmpty) {
        return offlineProgress;
      }

      final snapshot = await _firestore
          .collection("progress")
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();

    } catch (e) {

      print(
        "ERROR OBTENER TODOS LOS PROGRESOS: $e",
      );

      return [];
    }
  }

  /// 🏆 RANKING DE ALUMNOS
  Future<List<Map<String, dynamic>>>
      getRanking() async {

    final progress =
        await getAllProgress();

    Map<String, int> ranking = {};

    for (var doc in progress) {

      final String userId =
          doc["email"]?.toString() ?? "";

      final int stars =
          (doc["score"] ?? 0) as int;

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

    final progress =
        await getStudentProgress(
      userId,
    );

    int completedLevels =
        progress.length;

    /// TOTAL DE NIVELES
    int totalLevels = 10;

    return
        (completedLevels / totalLevels) *
            100;
  }
}