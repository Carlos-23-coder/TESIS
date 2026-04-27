import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lectoplay.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// CREACIÓN INICIAL
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    ///  Usuario tutor por defecto
    await db.insert('users', {
      'username': 'tutor',
      'email': 'tutor@lectoplay.com',
      'password': '12345678',
      'role': 'Tutor',
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

    
    if (oldVersion < 2) {
   
      final result = await db.rawQuery("PRAGMA table_info(users)");
      final columns = result.map((e) => e['name']).toList();

      if (!columns.contains('username')) {
        await db.execute("ALTER TABLE users ADD COLUMN username TEXT");
      }

      if (!columns.contains('role')) {
        await db.execute("ALTER TABLE users ADD COLUMN role TEXT");
      }
    }
  }
}