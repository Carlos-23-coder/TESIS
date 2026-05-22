import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database =
        await _initDB('lectoplay.db');

    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {

    final dbPath =
        await getDatabasesPath();

    final path =
        join(dbPath, filePath);

    return await openDatabase(

      path,

      version: 3,

      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(
    Database db,
    int version,
  ) async {

    await db.execute('''

      CREATE TABLE users (

        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        pin TEXT NOT NULL,
        role TEXT NOT NULL
      )

    ''');

    /// TUTOR POR DEFECTO
    await db.insert('users', {

      'username': 'tutor',
      'email': 'tutor@lectoplay.com',
      'password': '12345678',
      'pin': '1234',
      'role': 'Tutor',
    });
  }

  Future _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {

    final result =
        await db.rawQuery(
      "PRAGMA table_info(users)",
    );

    final columns =
        result.map((e) => e['name']).toList();

    if (!columns.contains('pin')) {

      await db.execute(
      "ALTER TABLE users ADD COLUMN pin TEXT DEFAULT '0000'",
      );
    }
  }
}