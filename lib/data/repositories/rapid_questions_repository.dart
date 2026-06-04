import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/rapid_question_model.dart';

class RapidQuestionsRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 🔥 GUARDAR NIVEL (OFFLINE FIRST)
  Future<void> saveLevel(
    RapidQuestionModel level,
  ) async {

    try {

      /// 📱 GUARDAR OFFLINE
      await _saveLevelOffline(
        level,
      );

      /// 🌐 INTENTA SINCRONIZAR
      try {

        await _firestore
            .collection("rapid_questions")
            .doc("level_${level.level}")
            .set(level.toMap());

        /// 📤 MARCAR COMO SINCRONIZADO
        final db =
            await _dbHelper.database;

        await db.update(

          'rapid_questions',

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
    RapidQuestionModel level,
  ) async {

    final db =
        await _dbHelper.database;

    await db.insert(

      'rapid_questions',

      {

        'level': level.level,
        'title': level.title,
        'story': level.story,
        'imageUrl': level.imageUrl,
        'date':
            DateTime.now().toIso8601String(),
        'synced': 0,
      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  /// ❓ OBTENER NIVEL (OFFLINE FIRST)
  Future<RapidQuestionModel?>
      getLevel(int level) async {

    try {

      /// 📱 INTENTA OBTENER OFFLINE
      final offlineLevel =
          await _getLevelOffline(
        level,
      );

      if (offlineLevel != null) {
        return offlineLevel;
      }

      /// 🌐 OBTENER DE FIREBASE
      return await _getLevelFirebase(
        level,
      );

    } catch (e) {

      print(
        "ERROR OBTENER NIVEL: $e",
      );

      return null;
    }
  }

  /// 📱 OBTENER NIVEL OFFLINE
  Future<RapidQuestionModel?>
      _getLevelOffline(
    int level,
  ) async {

    try {

      final db =
          await _dbHelper.database;

      final results = await db.query(

        'rapid_questions',

        where: 'level = ?',

        whereArgs: [level],
      );

      if (results.isEmpty) {
        return null;
      }

      return RapidQuestionModel.fromMap(
        results.first as Map<String, dynamic>,
      );

    } catch (e) {

      print(
        "ERROR OBTENER NIVEL OFFLINE: $e",
      );

      return null;
    }
  }

  /// 🌐 OBTENER NIVEL DE FIREBASE
  Future<RapidQuestionModel?>
      _getLevelFirebase(
    int level,
  ) async {

    try {

      final doc =
          await _firestore
              .collection("rapid_questions")
              .doc("level_$level")
              .get();

      if (!doc.exists) {
        return null;
      }

      return RapidQuestionModel.fromMap(
        doc.data()!,
      );

    } catch (e) {

      print(
        "ERROR OBTENER NIVEL FIREBASE: $e",
      );

      return null;
    }
  }

  /// 📚 OBTENER TODOS LOS NIVELES
  Future<List<RapidQuestionModel>>
      getAllLevels() async {

    try {

      /// 📱 INTENTA OBTENER OFFLINE
      final offlineLevels =
          await _getAllLevelsOffline();

      if (offlineLevels.isNotEmpty) {
        return offlineLevels;
      }

      /// 🌐 OBTENER DE FIREBASE
      return await _getAllLevelsFirebase();

    } catch (e) {

      print(
        "ERROR OBTENER TODOS LOS NIVELES: $e",
      );

      return [];
    }
  }

  /// 📱 OBTENER TODOS LOS NIVELES OFFLINE
  Future<List<RapidQuestionModel>>
      _getAllLevelsOffline() async {

    try {

      final db =
          await _dbHelper.database;

      final results = await db.query(
        'rapid_questions',
        orderBy: 'level',
      );

      return results
          .map((row) =>
              RapidQuestionModel.fromMap(
            row as Map<String, dynamic>,
          ))
          .toList();

    } catch (e) {

      print(
        "ERROR OBTENER NIVELES OFFLINE: $e",
      );

      return [];
    }
  }

  /// 🌐 OBTENER TODOS LOS NIVELES DE FIREBASE
  Future<List<RapidQuestionModel>>
      _getAllLevelsFirebase() async {

    try {

      final snapshot =
          await _firestore
              .collection("rapid_questions")
              .orderBy("level")
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                RapidQuestionModel.fromMap(
              doc.data(),
            ),
          )
          .toList();

    } catch (e) {

      print(
        "ERROR OBTENER NIVELES FIREBASE: $e",
      );

      return [];
    }
  }

  /// 🗑️ ELIMINAR NIVEL
  Future<void> deleteLevel(
    int level,
  ) async {

    try {

      /// 📱 ELIMINAR OFFLINE
      final db =
          await _dbHelper.database;

      await db.delete(

        'rapid_questions',

        where: 'level = ?',

        whereArgs: [level],
      );

      /// 🌐 INTENTA ELIMINAR DE FIREBASE
      try {

        await _firestore
            .collection("rapid_questions")
            .doc("level_$level")
            .delete();

      } catch (e) {

        print(
          "⚠️ No se eliminó de Firebase: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR ELIMINAR NIVEL: $e",
      );
    }
  }

  /// ✓ NIVEL EXISTE
  Future<bool> levelExists(
    int level,
  ) async {

    final lvl = await getLevel(level);

    return lvl != null;
  }

  /// 📤 SUBIR IMAGEN
  Future<String> uploadImage(
    int level,
    File image,
  ) async {

    try {

      final ref = _storage
          .ref()
          .child(
            "rapid_questions/level_$level.jpg",
          );

      await ref.putFile(image);

      return await ref.getDownloadURL();

    } catch (e) {

      print(
        "ERROR SUBIR IMAGEN: $e",
      );

      return "";
    }
  }
}