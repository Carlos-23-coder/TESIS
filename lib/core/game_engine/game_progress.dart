class GameProgress {

  /// CLAVE: "juego_nivel" → estrellas (máx. 3)
  static Map<String, int> earnedStars = {};

  static String _key(String game, int levelIndex) {
    return '${game}_$levelIndex';
  }

  static void saveStars(
    String game,
    int levelIndex,
    int stars,
  ) {
    final capped = stars.clamp(0, 3);
    final key = _key(game, levelIndex);
    final current = earnedStars[key] ?? 0;

    if (capped > current) {
      earnedStars[key] = capped;
    }
  }

  static int getStars(
    String game,
    int levelIndex,
  ) {
    return earnedStars[_key(game, levelIndex)] ?? 0;
  }

  static void clear() {
    earnedStars.clear();
  }
}
