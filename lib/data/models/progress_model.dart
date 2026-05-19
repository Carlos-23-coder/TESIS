class ProgressModel {

  final String userId;
  final int level;
  final int stars;
  final String game;

  ProgressModel({
    required this.userId,
    required this.level,
    required this.stars,
    required this.game,
  });

  Map<String, dynamic> toMap() {

    return {
      'userId': userId,
      'level': level,
      'stars': stars,
      'game': game,
    };
  }

  factory ProgressModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return ProgressModel(
      userId: map['userId'],
      level: map['level'],
      stars: map['stars'],
      game: map['game'],
    );
  }
}