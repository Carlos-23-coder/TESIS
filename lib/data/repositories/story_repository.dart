import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../../games/idea_principal/idea_principal_data.dart';
import '../services/local_image_service.dart';
import '../../games/preguntas_rapidas/preguntas_rapidas_data.dart';
import '../database/database_helper.dart';
import '../models/rapid_question_model.dart';
import '../repositories/progress_repository.dart';
import '../models/story_override_model.dart';

class StoryRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  int _defaultMaxLevel(String game) {
    if (game == StoryGameType.ideaPrincipal) {
      return ideaLevels.length;
    }

    return preguntasRapidasLevels.length;
  }

  String _defaultTitle(String game, int level) {
    if (game == StoryGameType.preguntasRapidas) {
      for (final item in preguntasRapidasLevels) {
        if (item.level == level) {
          return item.title;
        }
      }
    }

    for (final item in ideaLevels) {
      if (item.level == level) {
        final words = item.story.split(' ');

        if (words.length <= 4) {
          return 'Nivel $level';
        }

        return '${words.take(4).join(' ')}...';
      }
    }

    return 'Nivel $level';
  }

  String _resolveImage({
    required StoryOverrideModel? override,
    required String defaultImage,
  }) {
    if (override != null) {
      if (override.imagePath.isNotEmpty) {
        final file = File(override.imagePath);

        if (file.existsSync()) {
          return override.imagePath;
        }
      }

      if (override.imageUrl.isNotEmpty) {
        return override.imageUrl;
      }
    }

    return defaultImage;
  }

  Future<List<StoryLevelSummary>> listLevels({
    required String tutorEmail,
    required String game,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    await cacheTutorStories(tutorEmail);

    final overrides =
        await _getOverridesForGame(
      tutorEmail,
      game,
    );

    final overrideByLevel = {
      for (final item in overrides) item.level: item,
    };

    final levelNumbers = <int>{};

    if (game == StoryGameType.ideaPrincipal) {
      for (final item in ideaLevels) {
        levelNumbers.add(item.level);
      }
    } else {
      for (final item in preguntasRapidasLevels) {
        levelNumbers.add(item.level);
      }
    }

    for (final item in overrides) {
      levelNumbers.add(item.level);
    }

    final sortedLevels = levelNumbers.toList()..sort();

    return sortedLevels.map((level) {
      final override = overrideByLevel[level];
      final hasDefault = _hasDefaultLevel(game, level);

      return StoryLevelSummary(
        game: game,
        level: level,
        title: override?.title.isNotEmpty == true
            ? override!.title
            : _defaultTitle(game, level),
        isCustomized: override != null && hasDefault,
        isNewLevel: override?.isNewLevel == true ||
            (!hasDefault && override != null),
      );
    }).toList();
  }

  bool hasDefaultLevel(String game, int level) {
    return _hasDefaultLevel(game, level);
  }

  bool _hasDefaultLevel(String game, int level) {
    if (game == StoryGameType.ideaPrincipal) {
      return ideaLevels.any((item) => item.level == level);
    }

    return preguntasRapidasLevels.any(
      (item) => item.level == level,
    );
  }

  Future<EffectiveIdeaLevel?> getEffectiveIdeaLevel({
    required String tutorEmail,
    required int level,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    await cacheTutorStories(tutorEmail);

    final override = await _getOverride(
      tutorEmail,
      StoryGameType.ideaPrincipal,
      level,
    );

    IdeaLevel? defaultLevel;

    for (final item in ideaLevels) {
      if (item.level == level) {
        defaultLevel = item;
        break;
      }
    }

    if (override == null && defaultLevel == null) {
      return null;
    }

    if (override != null) {
      return EffectiveIdeaLevel(
        level: level,
        story: override.story,
        image: _resolveImage(
          override: override,
          defaultImage: defaultLevel?.image ?? '',
        ),
        question: override.question,
        options: override.options,
        correctAnswer: override.correctAnswer,
        isCustomized: defaultLevel != null,
      );
    }

    return EffectiveIdeaLevel(
      level: defaultLevel!.level,
      story: defaultLevel.story,
      image: defaultLevel.image,
      question: defaultLevel.question,
      options: defaultLevel.options,
      correctAnswer: defaultLevel.correctAnswer,
    );
  }

  Future<RapidQuestionModel?> getEffectiveRapidLevel({
    required String tutorEmail,
    required int level,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    await cacheTutorStories(tutorEmail);

    final override = await _getOverride(
      tutorEmail,
      StoryGameType.preguntasRapidas,
      level,
    );

    PreguntaRapidaLevel? defaultLevel;

    for (final item in preguntasRapidasLevels) {
      if (item.level == level) {
        defaultLevel = item;
        break;
      }
    }

    if (override == null && defaultLevel == null) {
      return null;
    }

    if (override != null) {
      return RapidQuestionModel(
        level: level,
        title: override.title,
        story: override.story,
        audioUrl: '',
        imageUrl: _resolveImage(
          override: override,
          defaultImage: defaultLevel?.image ?? '',
        ),
        questions: override.questions,
      );
    }

    return RapidQuestionModel(
      level: defaultLevel!.level,
      title: defaultLevel.title,
      story: defaultLevel.story,
      audioUrl: '',
      imageUrl: defaultLevel.image,
      questions: defaultLevel.questions,
    );
  }

  Future<StoryOverrideModel?> getEditableContent({
    required String tutorEmail,
    required String game,
    required int level,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    final override = await _getOverride(
      tutorEmail,
      game,
      level,
    );

    if (override != null) {
      return override;
    }

    if (game == StoryGameType.ideaPrincipal) {
      for (final item in ideaLevels) {
        if (item.level == level) {
          return StoryOverrideModel(
            id: StoryOverrideModel.buildId(
              tutorEmail,
              game,
              level,
            ),
            tutorEmail: tutorEmail,
            game: game,
            level: level,
            title: _defaultTitle(game, level),
            story: item.story,
            imagePath: item.image,
            question: item.question,
            options: item.options,
            correctAnswer: item.correctAnswer,
            date: DateTime.now().toIso8601String(),
          );
        }
      }
    } else {
      for (final item in preguntasRapidasLevels) {
        if (item.level == level) {
          return StoryOverrideModel(
            id: StoryOverrideModel.buildId(
              tutorEmail,
              game,
              level,
            ),
            tutorEmail: tutorEmail,
            game: game,
            level: level,
            title: item.title,
            story: item.story,
            imagePath: item.image,
            questions: item.questions,
            date: DateTime.now().toIso8601String(),
          );
        }
      }
    }

    return null;
  }

  Future<void> saveOverride({
    required StoryOverrideModel override,
    File? newImage,
  }) async {
    final tutorEmail = _normalizeEmail(override.tutorEmail);
    var imagePath = override.imagePath;
    var imageUrl = override.imageUrl;

    if (newImage != null) {
      imagePath = await LocalImageService.saveStoryImage(
        tutorEmail: tutorEmail,
        game: override.game,
        level: override.level,
        image: newImage,
      );
      imageUrl = '';
    }

    final hasDefault = _hasDefaultLevel(
      override.game,
      override.level,
    );

    final model = StoryOverrideModel(
      id: override.id,
      tutorEmail: tutorEmail,
      game: override.game,
      level: override.level,
      title: override.title,
      story: override.story,
      imagePath: imagePath,
      imageUrl: imageUrl,
      question: override.question,
      options: override.options,
      correctAnswer: override.correctAnswer,
      questions: override.questions,
      isNewLevel: override.isNewLevel || !hasDefault,
      date: DateTime.now().toIso8601String(),
      synced: 0,
    );

    await _saveOverrideOffline(model);

    try {
      await _firestore
          .collection('story_overrides')
          .doc(model.id)
          .set(model.toMap());

      final db = await _dbHelper.database;

      await db.update(
        'story_overrides',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (_) {}
  }

  Future<void> restoreDefault({
    required String tutorEmail,
    required String game,
    required int level,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    final id = StoryOverrideModel.buildId(
      tutorEmail,
      game,
      level,
    );

    final db = await _dbHelper.database;

    await db.delete(
      'story_overrides',
      where: 'id = ?',
      whereArgs: [id],
    );

    try {
      await _firestore
          .collection('story_overrides')
          .doc(id)
          .delete();
    } catch (_) {}
  }

  Future<void> deleteLevel({
    required String tutorEmail,
    required String game,
    required int level,
  }) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    await restoreDefault(
      tutorEmail: tutorEmail,
      game: game,
      level: level,
    );

    if (!_hasDefaultLevel(game, level)) {
      await ProgressRepository().deleteProgressForLevel(
        game: game,
        level: level,
      );
    }
  }

  Future<void> cacheTutorStories(String tutorEmail) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    try {
      final snapshot = await _firestore
          .collection('story_overrides')
          .where('tutorEmail', isEqualTo: tutorEmail)
          .get();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['tutorEmail'] = _normalizeEmail(
          data['tutorEmail']?.toString() ?? tutorEmail,
        );

        final model = StoryOverrideModel.fromMap(data);

        await _saveOverrideOffline(
          model.copyWith(synced: 1),
        );
      }
    } catch (_) {}
  }

  Future<StoryOverrideModel?> _getOverride(
    String tutorEmail,
    String game,
    int level,
  ) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    final id = StoryOverrideModel.buildId(
      tutorEmail,
      game,
      level,
    );

    final db = await _dbHelper.database;

    final results = await db.query(
      'story_overrides',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return StoryOverrideModel.fromMap(
      results.first,
    );
  }

  Future<List<StoryOverrideModel>> _getOverridesForGame(
    String tutorEmail,
    String game,
  ) async {
    tutorEmail = _normalizeEmail(tutorEmail);

    final db = await _dbHelper.database;

    final results = await db.query(
      'story_overrides',
      where: 'tutorEmail = ? AND game = ?',
      whereArgs: [tutorEmail, game],
      orderBy: 'level ASC',
    );

    return results
        .map((row) => StoryOverrideModel.fromMap(row))
        .toList();
  }

  Future<void> _saveOverrideOffline(
    StoryOverrideModel override,
  ) async {
    final db = await _dbHelper.database;

    await db.insert(
      'story_overrides',
      override.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> syncUnsyncedOverrides() async {
    final db = await _dbHelper.database;

    final unsynced = await db.query(
      'story_overrides',
      where: 'synced = 0',
    );

    for (final item in unsynced) {
      try {
        final model = StoryOverrideModel.fromMap(item);

        await _firestore
            .collection('story_overrides')
            .doc(model.id)
            .set(model.toMap());

        await db.update(
          'story_overrides',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [model.id],
        );
      } catch (_) {}
    }
  }

  int get nextSuggestedLevel {
    return _defaultMaxLevel(StoryGameType.ideaPrincipal) + 1;
  }
}
