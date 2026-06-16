import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/game_engine/game_progress.dart';
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

      final normalizedUserId =
          progress.userId.trim().toLowerCase();

      final cappedStars = progress.stars.clamp(0, 3);

      final existing = await _getLevelProgress(
        normalizedUserId,
        progress.game,
        progress.level,
      );

      final existingStars =
          (existing?['stars'] ?? 0) as int;

      if (cappedStars <= existingStars) {
        return;
      }

      final updated = ProgressModel(
        userId: normalizedUserId,
        level: progress.level,
        stars: cappedStars,
        game: progress.game,
      );

      /// 📱 GUARDAR OFFLINE PRIMERO
      await _saveProgressOffline(
        updated,
      );

      /// 🌐 INTENTA SINCRONIZAR CON FIREBASE
      try {

        await _firestore
            .collection("progress")
            .doc(
              "${updated.userId}_${updated.game}_${updated.level}",
            )
            .set(
              updated.toMap(),
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
            updated.userId,
            updated.game,
            updated.level,
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

  Future<Map<String, dynamic>?> _getLevelProgress(
    String userId,
    String game,
    int level,
  ) async {
    userId = userId.trim().toLowerCase();

    try {
      final db = await _dbHelper.database;

      final results = await db.query(
        'progress',
        where: 'LOWER(email) = ? AND game = ? AND level = ?',
        whereArgs: [userId, game, level],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
    } catch (_) {}

    try {
      final doc = await _firestore
          .collection('progress')
          .doc('${userId}_${game}_$level')
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (_) {}

    return null;
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
        'stars': progress.stars.clamp(0, 3),
        'level': progress.level,
        'date': DateTime.now().toIso8601String(),
        'synced': 0,
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// 📚 OBTENER PROGRESO DEL ALUMNO (OFFLINE + FIREBASE)
  Future<List<Map<String, dynamic>>>
      getStudentProgress(
    String userId,
  ) async {

    try {

      final normalizedUserId = userId.trim().toLowerCase();

      final offlineProgress =
          await _getStudentProgressOffline(
        normalizedUserId,
      );

      final firebaseProgress =
          await _getStudentProgressFirebase(
        normalizedUserId,
      );

      return _mergeProgressEntries([
        ...offlineProgress,
        ...firebaseProgress,
      ], normalizedUserId);

    } catch (e) {

      print(
        "ERROR OBTENER PROGRESO: $e",
      );

      return [];
    }
  }

  List<Map<String, dynamic>> _mergeProgressEntries(
    List<Map<String, dynamic>> entries,
    String userId,
  ) {
    final bestByLevel = <String, Map<String, dynamic>>{};

    for (final doc in entries) {
      final game = doc['game']?.toString() ?? '';
      final level = doc['level'] ?? 0;
      final stars =
          ((doc['stars'] ?? doc['score'] ?? 0) as int).clamp(0, 3);

      if (game.isEmpty) {
        continue;
      }

      final key = '${game}_$level';
      final currentStars =
          ((bestByLevel[key]?['stars'] ?? 0) as int).clamp(0, 3);

      if (stars >= currentStars) {
        bestByLevel[key] = {
          'email': userId,
          'userId': userId,
          'game': game,
          'level': level,
          'stars': stars,
        };
      }
    }

    return bestByLevel.values.toList();
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

        where: 'LOWER(email) = ?',

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

  /// ⭐ TOTAL DE ESTRELLAS
  Future<int> getTotalStars(
    String userId,
  ) async {

    final progress =
        await getStudentProgress(
      userId,
    );

    return progress.fold<int>(
      0,
      (total, doc) =>
          total + ((doc['stars'] ?? 0) as int).clamp(0, 3),
    );
  }

  /// 🗑️ BORRAR PROGRESO DE UN NIVEL PARA TODOS LOS ALUMNOS
  Future<void> deleteProgressForLevel({
    required String game,
    required int level,
  }) async {
    final db = await _dbHelper.database;

    await db.delete(
      'progress',
      where: 'game = ? AND level = ?',
      whereArgs: [game, level],
    );

    try {
      final snapshot = await _firestore
          .collection('progress')
          .where('game', isEqualTo: game)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final docLevel = data['level'];

        if (docLevel == level) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('ERROR BORRAR PROGRESO DEL NIVEL: $e');
    }

    GameProgress.removeStars(game, level - 1);
  }

  /// 🔄 RESETEAR PROGRESO DE UN ALUMNO (PARA PRUEBAS)
  Future<void> resetStudentProgress(
    String userId,
  ) async {
    GameProgress.clear();

    final db = await _dbHelper.database;

    await db.delete(
      'progress',
      where: 'email = ?',
      whereArgs: [userId],
    );

    try {
      final snapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('ERROR RESETEAR PROGRESO FIREBASE: $e');
    }

    try {
      final subSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();

      for (final doc in subSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('ERROR RESETEAR SUBCOLECCIÓN PROGRESO: $e');
    }
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