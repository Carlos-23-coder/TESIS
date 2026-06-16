import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalImageService {
  static String _normalizeEmail(String email) =>
      email.trim().toLowerCase();

  static String _safeEmailKey(String email) {
    return _normalizeEmail(email)
        .replaceAll('@', '_at_')
        .replaceAll('.', '_');
  }

  static Future<String> saveProfileImage({
    required String email,
    required File image,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${_normalizeEmail(email)}.jpg';

    return (await image.copy(path)).path;
  }

  static Future<String> saveStoryImage({
    required String tutorEmail,
    required String game,
    required int level,
    required File image,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/story_${_safeEmailKey(tutorEmail)}_${game}_$level.jpg';

    return (await image.copy(path)).path;
  }

  static Future<String> saveRapidQuestionImage({
    required int level,
    required File image,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/rapid_question_level_$level.jpg';

    return (await image.copy(path)).path;
  }

  static String profileImagePath(String email) {
    // Caller should combine with getApplicationDocumentsDirectory when needed.
    return '${_normalizeEmail(email)}.jpg';
  }
}
