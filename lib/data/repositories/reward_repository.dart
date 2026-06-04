import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/reward_model.dart';

class RewardRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 🔥 GUARDAR RECOMPENSA (OFFLINE FIRST)
  Future<void> addReward(
    RewardModel reward,
  ) async {

    try {

      /// 📱 GUARDAR OFFLINE
      await _saveRewardOffline(
        reward,
      );

      /// 🌐 INTENTA SINCRONIZAR
      try {

        await _firestore
            .collection("rewards")
            .doc(reward.id)
            .set(reward.toMap());

        /// 📤 MARCAR COMO SINCRONIZADO
        final db =
            await _dbHelper.database;

        await db.update(

          'rewards',

          {'synced': 1},

          where: 'id = ?',

          whereArgs: [reward.id],
        );

      } catch (e) {

        print(
          "⚠️ Recompensa guardada offline: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR GUARDAR RECOMPENSA: $e",
      );
    }
  }

  /// 📱 GUARDAR RECOMPENSA OFFLINE
  Future<void> _saveRewardOffline(
    RewardModel reward,
  ) async {

    final db =
        await _dbHelper.database;

    await db.insert(

      'rewards',

      {

        'id': reward.id,
        'name': reward.name,
        'category': reward.category,
        'imagePath': reward.imagePath,
        'requiredStars': reward.requiredStars,
        'tutorEmail': reward.tutorEmail,
        'date':
            DateTime.now().toIso8601String(),
        'synced': 0,
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// ✏️ ACTUALIZAR RECOMPENSA
  Future<void> updateReward(
    RewardModel reward,
  ) async {

    await addReward(reward);
  }

  /// 📚 OBTENER RECOMPENSAS (OFFLINE FIRST)
  Future<List<RewardModel>>
      getRewards() async {

    try {

      /// 📱 OBTENER OFFLINE
      final offlineRewards =
          await _getRewardsOffline();

      if (offlineRewards.isNotEmpty) {
        return offlineRewards;
      }

      /// 🌐 OBTENER DE FIREBASE
      return await _getRewardsFirebase();

    } catch (e) {

      print(
        "ERROR OBTENER RECOMPENSAS: $e",
      );

      return [];
    }
  }

  /// 📱 OBTENER RECOMPENSAS OFFLINE
  Future<List<RewardModel>>
      _getRewardsOffline() async {

    try {

      final db =
          await _dbHelper.database;

      final results = await db.query(
        'rewards',
      );

      return results
          .map((row) {

            final map =
                row as Map<String, dynamic>;

            return RewardModel(

              id: map['id'] ?? '',

              name: map['name'] ?? '',

              category: map['category'] ?? '',

              imagePath:
                  map['imagePath'] ?? '',

              requiredStars:
                  (map['requiredStars'] ?? 0)
                      as int,

              tutorEmail:
                  map['tutorEmail'] ?? '',
            );
          })
          .toList();

    } catch (e) {

      print(
        "ERROR OBTENER RECOMPENSAS OFFLINE: $e",
      );

      return [];
    }
  }

  /// 🌐 OBTENER RECOMPENSAS DE FIREBASE
  Future<List<RewardModel>>
      _getRewardsFirebase() async {

    try {

      final snapshot = await _firestore
          .collection("rewards")
          .get();

      return snapshot.docs.map((doc) {

        return RewardModel.fromMap(
          doc.data(),
        );
      }).toList();

    } catch (e) {

      print(
        "ERROR OBTENER RECOMPENSAS FIREBASE: $e",
      );

      return [];
    }
  }

  /// 👨‍🏫 OBTENER RECOMPENSAS DEL TUTOR
  Future<List<RewardModel>>
      getRewardsByTutor(
    String tutorEmail,
  ) async {

    final rewards = await getRewards();

    return rewards
        .where((reward) =>
            reward.tutorEmail.isEmpty ||
            reward.tutorEmail == tutorEmail)
        .toList();
  }
}