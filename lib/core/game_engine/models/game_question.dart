class GameQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String gameType;
  final int points;

  GameQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.gameType,
    required this.points,
  });
}