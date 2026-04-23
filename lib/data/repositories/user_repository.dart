import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> createUser(User user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<bool> emailExists(String email) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<User?> login(String username, String password, String role) async {
  final db = await dbHelper.database;

  final maps = await db.query(
    'users',
    where: 'username = ? AND password = ? AND role = ?',
    whereArgs: [username, password, role],
  );

  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  } else {
    return null;
  }
}
}