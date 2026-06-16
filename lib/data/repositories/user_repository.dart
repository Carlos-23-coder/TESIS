import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {

  final DatabaseHelper dbHelper =
      DatabaseHelper.instance;

  /// CREAR USUARIO (solo alumnos desde registro)
  Future<int> createUser(
    User user,
  ) async {
    if (user.role != 'Alumno') {
      throw Exception('Solo se pueden registrar alumnos.');
    }

    final db =
        await dbHelper.database;

    return await db.insert(
      'users',
      user.toMap(),
    );
  }

  /// VERIFICAR EMAIL
  Future<bool> emailExists(
    String email,
  ) async {

    final db =
        await dbHelper.database;

    final result = await db.query(

      'users',

      where: 'email = ?',

      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  /// LOGIN
  Future<User?> login({

    required String userInput,
    required String passwordOrPin,
    required String role,

  }) async {

    final db =
        await dbHelper.database;

    final maps = await db.query(

      'users',

      where: '''
      (email = ? OR username = ?)
      AND
      (password = ? OR pin = ?)
      AND
      role = ?
      ''',

      whereArgs: [

        userInput,
        userInput,

        passwordOrPin,
        passwordOrPin,

        role,
      ],
    );

    if (maps.isNotEmpty) {

      return User.fromMap(
        maps.first,
      );
    }

    return null;
  }
}