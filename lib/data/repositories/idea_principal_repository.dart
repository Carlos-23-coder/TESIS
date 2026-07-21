import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../database/database_helper.dart';
import '../models/story_override_model.dart';

class IdeaPrincipalRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 🔥 GUARDAR NIVEL (OFFLINE FIRST)
  Future<void> saveLevel(
    EffectiveIdeaLevel level,
    String? tutorEmail,
  ) async {

    try {

      /// 📱 GUARDAR OFFLINE
      await _saveLevelOffline(
        level,
        tutorEmail,
      );

      /// 🌐 INTENTA SINCRONIZAR
      try {

        await _firestore
            .collection("idea_principal")
            .doc("level_${level.level}")
            .set({
          'level': level.level,
          'story': level.story,
          'question': level.question,
          'options': level.options,
          'correctAnswer': level.correctAnswer,
          'image': level.image,
          'tutorEmail': tutorEmail,
          'date': DateTime.now().toIso8601String(),
        });

        /// 📤 MARCAR COMO SINCRONIZADO
        final db =
            await _dbHelper.database;

        await db.update(

          'idea_principal',

          {'synced': 1},

          where: 'level = ?',

          whereArgs: [level.level],
        );

      } catch (e) {

        print(
          "⚠️ Nivel guardado offline: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR GUARDAR NIVEL: $e",
      );
    }
  }

  /// 📱 GUARDAR NIVEL OFFLINE
  Future<void> _saveLevelOffline(
    EffectiveIdeaLevel level,
    String? tutorEmail,
  ) async {

    final db =
        await _dbHelper.database;

    await db.insert(

      'idea_principal',

      {

        'level': level.level,
        'story': level.story,
        'question': level.question,
        'options': jsonEncode(level.options),
        'correctAnswer': level.correctAnswer,
        'imageUrl': level.image,
        'tutorEmail': tutorEmail,
        'date':
            DateTime.now().toIso8601String(),
        'synced': 0,
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// ❓ OBTENER NIVEL (OFFLINE FIRST)
  Future<EffectiveIdeaLevel?>
      getLevel(int level) async {

    try {

      /// 📱 INTENTA OFFLINE PRIMERO
      final db =
          await _dbHelper.database;

      final result =
          await db.query(

        'idea_principal',

        where: 'level = ?',

        whereArgs: [level],

        limit: 1,
      );

      if (result.isNotEmpty) {

        return _mapRowToLevel(
          result.first,
        );
      }

      /// 🌐 SI NO EXISTE OFFLINE, OBTENER DE FIREBASE
      try {

        final doc = await _firestore
            .collection("idea_principal")
            .doc("level_$level")
            .get();

        if (doc.exists) {

          final data = doc.data();

          if (data != null) {

            final ideaLevel =
                EffectiveIdeaLevel(
              level: data['level'] ?? level,
              story: data['story'] ?? '',
              image: data['image'] ?? '',
              question: data['question'] ?? '',
              options: List<String>.from(
                data['options'] ?? [],
              ),
              correctAnswer:
                  data['correctAnswer'] ?? 0,
              isCustomized: true,
            );

            /// 💾 GUARDAR OFFLINE PARA FUTURO
            await _saveLevelOffline(
              ideaLevel,
              data['tutorEmail'],
            );

            return ideaLevel;
          }
        }

      } catch (e) {

        print(
          "ERROR OBTENER DE FIREBASE: $e",
        );
      }

      return null;

    } catch (e) {

      print(
        "ERROR OBTENER NIVEL: $e",
      );

      return null;
    }
  }

  /// 📂 OBTENER TODOS LOS NIVELES (OFFLINE FIRST)
  Future<List<EffectiveIdeaLevel>>
      getAllLevels() async {

    try {

      /// 📱 OBTENER DE OFFLINE
      final db =
          await _dbHelper.database;

      final results =
          await db.query(
        'idea_principal',
        orderBy: 'level',
      );

      List<EffectiveIdeaLevel> levels = [];

      for (var row in results) {

        levels.add(
          _mapRowToLevel(row),
        );
      }

      /// 🌐 SI ESTÁ VACÍO, OBTENER DE FIREBASE
      if (levels.isEmpty) {

        try {

          final snapshot = await _firestore
              .collection("idea_principal")
              .get();

          for (var doc
              in snapshot.docs) {

            final data = doc.data();

            final ideaLevel =
                EffectiveIdeaLevel(
              level: data['level'] ?? 0,
              story: data['story'] ?? '',
              image: data['image'] ?? '',
              question: data['question'] ?? '',
              options: List<String>.from(
                data['options'] ?? [],
              ),
              correctAnswer:
                  data['correctAnswer'] ?? 0,
              isCustomized: true,
            );

            levels.add(ideaLevel);

            /// 💾 GUARDAR OFFLINE
            await _saveLevelOffline(
              ideaLevel,
              data['tutorEmail'],
            );
          }

        } catch (e) {

          print(
            "ERROR OBTENER DE FIREBASE: $e",
          );
        }
      }

      return levels;

    } catch (e) {

      print(
        "ERROR OBTENER TODOS: $e",
      );

      return [];
    }
  }

  /// 🗺️ MAPEAR FILA A MODELO
  EffectiveIdeaLevel _mapRowToLevel(
    Map<String, dynamic> row,
  ) {

    List<String> options = [];

    try {

      final optionsJson = row['options'];

      if (optionsJson is String) {

        options = List<String>.from(
          jsonDecode(optionsJson),
        );

      } else if (optionsJson is List) {

        options = List<String>.from(
          optionsJson,
        );
      }

    } catch (e) {

      print(
        "ERROR DECODIFICAR OPTIONS: $e",
      );
    }

    return EffectiveIdeaLevel(
      level: row['level'] ?? 0,
      story: row['story'] ?? '',
      image: row['imageUrl'] ?? '',
      question: row['question'] ?? '',
      options: options,
      correctAnswer: row['correctAnswer'] ?? 0,
      isCustomized: true,
    );
  }

  /// 🧹 ELIMINAR NIVEL OFFLINE
  Future<void> deleteLevel(
    int level,
  ) async {

    try {

      final db =
          await _dbHelper.database;

      await db.delete(

        'idea_principal',

        where: 'level = ?',

        whereArgs: [level],
      );

    } catch (e) {

      print(
        "ERROR ELIMINAR NIVEL: $e",
      );
    }
  }

  /// 🔄 SINCRONIZAR CAMBIOS PENDIENTES
  Future<void> syncPendingChanges() async {

    try {

      final db =
          await _dbHelper.database;

      final unsyncedRows =
          await db.query(

        'idea_principal',

        where: 'synced = ?',

        whereArgs: [0],
      );

      for (var row
          in unsyncedRows) {

        try {

          await _firestore
              .collection(
                "idea_principal",
              )
              .doc(
                "level_${row['level']}",
              )
              .set(row);

          await db.update(

            'idea_principal',

            {'synced': 1},

            where: 'level = ?',

            whereArgs: [row['level']],
          );

        } catch (e) {

          print(
            "ERROR SINCRONIZAR NIVEL: $e",
          );
        }
      }

    } catch (e) {

      print(
        "ERROR SINCRONIZAR: $e",
      );
    }
  }
}
