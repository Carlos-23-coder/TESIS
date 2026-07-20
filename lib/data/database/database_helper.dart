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

      version: 4,

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

    /// 📊 TABLA DE PROGRESO OFFLINE
    await db.execute('''

      CREATE TABLE progress (

        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        game TEXT NOT NULL,
        stars INTEGER NOT NULL,
        level INTEGER NOT NULL,
        date TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        UNIQUE(email, game, level)
      )

    ''');

    /// 🎁 TABLA DE RECOMPENSAS OFFLINE
    await db.execute('''

      CREATE TABLE rewards (

        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        imagePath TEXT,
        requiredStars INTEGER,
        tutorEmail TEXT,
        date TEXT,
        synced INTEGER DEFAULT 0
      )

    ''');

    /// ❓ TABLA DE PREGUNTAS RÁPIDAS OFFLINE
    await db.execute('''

      CREATE TABLE rapid_questions (

        level INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        story TEXT,
        imageUrl TEXT,
        date TEXT,
        synced INTEGER DEFAULT 0
      )

    ''');
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

    /// CREAR TABLA DE PROGRESO SI NO EXISTE
    try {

      await db.execute('''

        CREATE TABLE IF NOT EXISTS progress (

          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          game TEXT NOT NULL,
          stars INTEGER NOT NULL,
          level INTEGER NOT NULL,
          date TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          UNIQUE(email, game, level)
        )

      ''');

    } catch (e) {
      print(
        "Tabla progress ya existe: $e",
      );
    }

    /// CREAR TABLA DE RECOMPENSAS SI NO EXISTE
    try {

      await db.execute('''

        CREATE TABLE IF NOT EXISTS rewards (

          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT,
          imagePath TEXT,
          requiredStars INTEGER,
          tutorEmail TEXT,
          date TEXT,
          synced INTEGER DEFAULT 0
        )

      ''');

    } catch (e) {
      print(
        "Tabla rewards ya existe: $e",
      );
    }

    /// CREAR TABLA DE PREGUNTAS RÁPIDAS SI NO EXISTE
    try {

      await db.execute('''

        CREATE TABLE IF NOT EXISTS rapid_questions (

          level INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          story TEXT,
          imageUrl TEXT,
          date TEXT,
          synced INTEGER DEFAULT 0
        )

      ''');

    } catch (e) {
      print(
        "Tabla rapid_questions ya existe: $e",
      );
    }

    /// AGREGAR COLUMNA synced SI NO EXISTE
    try {

      final progressInfo =
          await db.rawQuery(
        "PRAGMA table_info(progress)",
      );

      final progressCols =
          progressInfo.map((e) => e['name']).toList();

      if (!progressCols.contains('synced')) {

        await db.execute(
          "ALTER TABLE progress ADD COLUMN synced INTEGER DEFAULT 0",
        );
      }

    } catch (e) {
      print(
        "Error en migración progress: $e",
      );
    }
  }
}