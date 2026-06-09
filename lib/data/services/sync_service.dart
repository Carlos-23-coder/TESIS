import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/database_helper.dart';

class SyncService {

  static final SyncService instance =
      SyncService._init();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  final Connectivity _connectivity =
      Connectivity();

  SyncService._init() {
    _initConnectivityListener();
  }

  /// 📡 ESCUCHAR CAMBIOS DE CONECTIVIDAD
  void _initConnectivityListener() {

    _connectivity
        .onConnectivityChanged
        .listen((result) {

      if (result ==
          ConnectivityResult.wifi ||

          result ==
              ConnectivityResult.mobile) {

        print(
          "✅ Conexión detectada, sincronizando...",
        );

        syncAllData();

      } else {

        print(
          "❌ Sin conexión, datos guardados localmente",
        );
      }
    });
  }

  /// 🔄 SINCRONIZAR TODOS LOS DATOS
  Future<void> syncAllData() async {

    try {

      await Future.wait([

        _syncProgress(),
        _syncRewards(),
        _syncStoryOverrides(),
        _syncRewardClaims(),
      ]);

      print(
        "✅ Sincronización completada",
      );

    } catch (e) {

      print(
        "❌ Error sincronizando: $e",
      );
    }
  }

  /// 📊 SINCRONIZAR PROGRESO
  Future<void> _syncProgress() async {

    try {

      final db =
          await _dbHelper.database;

      /// 🔍 OBTENER DATOS NO SINCRONIZADOS
      final unsyncedProgress =
          await db.query(

        'progress',

        where: 'synced = 0',
      );

      for (var item in unsyncedProgress) {

        try {

          /// 📤 SUBIR A FIREBASE
          final email =
              item['email'] as String;

          final game =
              item['game'] as String;

          final level =
              item['level'] as int;

          await _firestore
              .collection('progress')
              .doc('${email}_${game}_$level')
              .set({

            'userId': email,
            'game': game,
            'stars': (item['stars'] as int).clamp(0, 3),
            'level': level,

            'date':
                item['date'],
          });

          /// ✅ MARCAR COMO SINCRONIZADO
          await db.update(

            'progress',

            {'synced': 1},

            where: '''
            email = ? AND game = ? AND level = ?
            ''',

            whereArgs: [
              email,
              game,
              level,
            ],
          );

          print(
            "✅ Progreso sincronizado: $email - $game",
          );

        } catch (e) {

          print(
            "❌ Error sincronizando progreso: $e",
          );
        }
      }

    } catch (e) {

      print(
        "ERROR EN _syncProgress: $e",
      );
    }
  }

  /// 🎁 SINCRONIZAR RECOMPENSAS
  Future<void> _syncRewards() async {

    try {

      final db =
          await _dbHelper.database;

      /// 🔍 OBTENER DATOS NO SINCRONIZADOS
      final unsyncedRewards =
          await db.query(

        'rewards',

        where: 'synced = 0',
      );

      for (var item in unsyncedRewards) {

        try {

          /// 📤 SUBIR A FIREBASE
          final id = item['id'] as String;

          await _firestore
              .collection("rewards")
              .doc(id)
              .set({

            'id': id,
            'name': item['name'],
            'category': item['category'],
            'imagePath': item['imagePath'],
            'requiredStars': item['requiredStars'],
            'tutorEmail': item['tutorEmail'],
            'date': item['date'],
          });

          /// ✅ MARCAR COMO SINCRONIZADO
          await db.update(

            'rewards',

            {'synced': 1},

            where: 'id = ?',

            whereArgs: [id],
          );

          print(
            "✅ Recompensa sincronizada: $id",
          );

        } catch (e) {

          print(
            "❌ Error sincronizando recompensa: $e",
          );
        }
      }

    } catch (e) {

      print(
        "ERROR EN _syncRewards: $e",
      );
    }
  }

  /// 📚 SINCRONIZAR HISTORIAS PERSONALIZADAS
  Future<void> _syncStoryOverrides() async {

    try {

      final db =
          await _dbHelper.database;

      final unsyncedStories =
          await db.query(

        'story_overrides',

        where: 'synced = 0',
      );

      for (var item in unsyncedStories) {

        try {

          final id = item['id'] as String;

          final optionsJson = item['optionsJson'] as String? ?? '[]';
          final questionsJson = item['questionsJson'] as String? ?? '[]';

          await _firestore
              .collection("story_overrides")
              .doc(id)
              .set({

            'id': id,
            'tutorEmail': item['tutorEmail'],
            'game': item['game'],
            'level': item['level'],
            'title': item['title'],
            'story': item['story'],
            'imagePath': item['imagePath'],
            'imageUrl': item['imageUrl'],
            'question': item['question'],
            'options': jsonDecode(optionsJson),
            'correctAnswer': item['correctAnswer'],
            'questions': jsonDecode(questionsJson),
            'isNewLevel': item['isNewLevel'] == 1,
            'date': item['date'],
          });

          await db.update(

            'story_overrides',

            {'synced': 1},

            where: 'id = ?',

            whereArgs: [id],
          );

          print(
            "✅ Historia sincronizada: $id",
          );

        } catch (e) {

          print(
            "❌ Error sincronizando historia: $e",
          );
        }
      }

    } catch (e) {

      print(
        "ERROR EN _syncStoryOverrides: $e",
      );
    }
  }

  /// 🔔 SINCRONIZAR SOLICITUDES DE RECOMPENSAS
  Future<void> _syncRewardClaims() async {
    try {
      final db = await _dbHelper.database;

      final unsyncedClaims = await db.query(
        'reward_claims',
        where: 'synced = 0',
      );

      for (var item in unsyncedClaims) {
        try {
          final id = item['id'] as String;

          await _firestore
              .collection('reward_claims')
              .doc(id)
              .set({
            'id': id,
            'studentEmail': item['studentEmail'],
            'studentName': item['studentName'],
            'rewardId': item['rewardId'],
            'rewardName': item['rewardName'],
            'tutorEmail': item['tutorEmail'],
            'status': item['status'],
            'date': item['date'],
          });

          await db.update(
            'reward_claims',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [id],
          );
        } catch (e) {
          print(
            "❌ Error sincronizando solicitud de recompensa: $e",
          );
        }
      }
    } catch (e) {
      print(
        "ERROR EN _syncRewardClaims: $e",
      );
    }
  }
}
