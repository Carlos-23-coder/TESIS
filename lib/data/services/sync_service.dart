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
        _syncRapidQuestions(),
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
              .collection('users')
              .doc(email)
              .collection('progress')
              .doc("${game}_$level")
              .set({

            'game': game,
            'stars': item['stars'],
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

  /// ❓ SINCRONIZAR PREGUNTAS RÁPIDAS
  Future<void> _syncRapidQuestions() async {

    try {

      final db =
          await _dbHelper.database;

      /// 🔍 OBTENER DATOS NO SINCRONIZADOS
      final unsyncedQuestions =
          await db.query(

        'rapid_questions',

        where: 'synced = 0',
      );

      for (var item in unsyncedQuestions) {

        try {

          /// 📤 SUBIR A FIREBASE
          final level = item['level'] as int;

          await _firestore
              .collection("rapid_questions")
              .doc("level_$level")
              .set({

            'level': level,
            'title': item['title'],
            'story': item['story'],
            'imageUrl': item['imageUrl'],
            'date': item['date'],
          });

          /// ✅ MARCAR COMO SINCRONIZADO
          await db.update(

            'rapid_questions',

            {'synced': 1},

            where: 'level = ?',

            whereArgs: [level],
          );

          print(
            "✅ Pregunta rápida sincronizada: level $level",
          );

        } catch (e) {

          print(
            "❌ Error sincronizando pregunta rápida: $e",
          );
        }
      }

    } catch (e) {

      print(
        "ERROR EN _syncRapidQuestions: $e",
      );
    }
  }
}
