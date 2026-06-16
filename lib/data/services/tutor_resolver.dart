import 'package:cloud_firestore/cloud_firestore.dart';
class TutorResolver {
  static const defaultTutorEmail = 'tutorjohn@gmail.com';
  static const defaultTutorUsername = 'John';

  static String normalizeEmail(String email) =>
      email.trim().toLowerCase();

  /// Todo el contenido del tutor (historias, premios, etc.) vive bajo este correo.
  static Future<String> resolveTutorEmail() async {
    return defaultTutorEmail;
  }

  static Future<void> ensureStudentLinkedToTutor(
    String studentEmail,
  ) async {
    final normalizedEmail = normalizeEmail(studentEmail);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(normalizedEmail)
          .get();

      if (!doc.exists) {
        return;
      }

      final data = doc.data() ?? {};

      if (data['role'] != 'Alumno') {
        return;
      }

      final currentTutor = data['tutorEmail'];

      if (currentTutor is String &&
          normalizeEmail(currentTutor) == defaultTutorEmail) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(normalizedEmail)
          .set(
        {'tutorEmail': defaultTutorEmail},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
