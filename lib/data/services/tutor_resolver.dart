import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorResolver {
  static const defaultTutorEmail = 'tutor@lectoplay.com';

  static Future<String> resolveTutorEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.email == null) {
      return defaultTutorEmail;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email!)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final role = data['role'];

        if (role == 'Tutor') {
          return user.email!;
        }

        final tutorEmail = data['tutorEmail'];

        if (tutorEmail is String && tutorEmail.isNotEmpty) {
          return tutorEmail;
        }
      }
    } catch (_) {}

    try {
      final tutors = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Tutor')
          .limit(1)
          .get();

      if (tutors.docs.isNotEmpty) {
        final email = tutors.docs.first.data()['email'];

        if (email is String && email.isNotEmpty) {
          return email;
        }

        return tutors.docs.first.id;
      }
    } catch (_) {}

    return defaultTutorEmail;
  }
}
