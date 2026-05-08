class GameProgress {

  /// NIVEL : ESTRELLAS
  static Map<int, int> earnedStars = {};

  static void saveStars(
    int level,
    int stars,
  ) {

    earnedStars[level] = stars;
  }

  static int getStars(int level) {

    return earnedStars[level] ?? 0;
  }
}