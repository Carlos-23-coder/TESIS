import 'dart:convert';

class StoryGameType {
  static const ideaPrincipal = 'idea_principal';
  static const preguntasRapidas = 'preguntas_rapidas';
}

class StoryOverrideModel {
  final String id;
  final String tutorEmail;
  final String game;
  final int level;
  final String title;
  final String story;
  final String imagePath;
  final String imageUrl;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final List<Map<String, dynamic>> questions;
  final bool isNewLevel;
  final String date;
  final int synced;

  StoryOverrideModel({
    required this.id,
    required this.tutorEmail,
    required this.game,
    required this.level,
    required this.title,
    required this.story,
    this.imagePath = '',
    this.imageUrl = '',
    this.question = '',
    this.options = const [],
    this.correctAnswer = 0,
    this.questions = const [],
    this.isNewLevel = false,
    required this.date,
    this.synced = 0,
  });

  static String buildId(
    String tutorEmail,
    String game,
    int level,
  ) {
    return '${tutorEmail}_${game}_$level';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorEmail': tutorEmail,
      'game': game,
      'level': level,
      'title': title,
      'story': story,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'questions': questions,
      'isNewLevel': isNewLevel,
      'date': date,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'tutorEmail': tutorEmail,
      'game': game,
      'level': level,
      'title': title,
      'story': story,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'question': question,
      'optionsJson': jsonEncode(options),
      'correctAnswer': correctAnswer,
      'questionsJson': jsonEncode(questions),
      'isNewLevel': isNewLevel ? 1 : 0,
      'date': date,
      'synced': synced,
    };
  }

  StoryOverrideModel copyWith({
    String? imagePath,
    String? imageUrl,
    int? synced,
  }) {
    return StoryOverrideModel(
      id: id,
      tutorEmail: tutorEmail,
      game: game,
      level: level,
      title: title,
      story: story,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      questions: questions,
      isNewLevel: isNewLevel,
      date: date,
      synced: synced ?? this.synced,
    );
  }

  factory StoryOverrideModel.fromMap(
    Map<String, dynamic> map,
  ) {
    List<String> parsedOptions = [];
    if (map['options'] is List) {
      parsedOptions = List<String>.from(map['options']);
    } else if (map['optionsJson'] is String &&
        (map['optionsJson'] as String).isNotEmpty) {
      parsedOptions = List<String>.from(
        jsonDecode(map['optionsJson'] as String),
      );
    }

    List<Map<String, dynamic>> parsedQuestions = [];
    if (map['questions'] is List) {
      parsedQuestions = List<Map<String, dynamic>>.from(
        (map['questions'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
    } else if (map['questionsJson'] is String &&
        (map['questionsJson'] as String).isNotEmpty) {
      parsedQuestions = List<Map<String, dynamic>>.from(
        jsonDecode(map['questionsJson'] as String),
      );
    }

    return StoryOverrideModel(
      id: map['id'] ?? '',
      tutorEmail: map['tutorEmail'] ?? '',
      game: map['game'] ?? '',
      level: map['level'] ?? 1,
      title: map['title'] ?? '',
      story: map['story'] ?? '',
      imagePath: map['imagePath'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      question: map['question'] ?? '',
      options: parsedOptions,
      correctAnswer: map['correctAnswer'] ?? 0,
      questions: parsedQuestions,
      isNewLevel: map['isNewLevel'] == true ||
          map['isNewLevel'] == 1,
      date: map['date'] ?? DateTime.now().toIso8601String(),
      synced: map['synced'] ?? 0,
    );
  }
}

class StoryLevelSummary {
  final String game;
  final int level;
  final String title;
  final bool isCustomized;
  final bool isNewLevel;

  StoryLevelSummary({
    required this.game,
    required this.level,
    required this.title,
    required this.isCustomized,
    required this.isNewLevel,
  });
}

class EffectiveIdeaLevel {
  final int level;
  final String story;
  final String image;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final bool isCustomized;

  EffectiveIdeaLevel({
    required this.level,
    required this.story,
    required this.image,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.isCustomized = false,
  });
}
