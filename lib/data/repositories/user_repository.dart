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

  /// CREAR USUARIO DESDE ADMIN (tutores u otros roles permitidos)
  Future<int> createUserFromAdmin(
    User user,
  ) async {
    final db =
        await dbHelper.database;

    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
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

  /// LISTAR USUARIOS LOCALES POR ROLES
  Future<List<User>> getUsersByRoles(
    List<String> roles,
  ) async {
    if (roles.isEmpty) {
      return [];
    }

    final db =
        await dbHelper.database;

    final placeholders =
        List.filled(roles.length, '?').join(', ');

    final result = await db.query(
      'users',
      where: 'role IN ($placeholders)',
      whereArgs: roles,
      orderBy: 'role ASC, username ASC',
    );

    return result
        .map(
          (item) => User.fromMap(item),
        )
        .toList();
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
