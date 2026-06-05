import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> savePhotoUrl(
    String userId,
    String photoUrl,
  ) async {

    await _firestore
        .collection("users")
        .doc(userId)
        .set({
      "photoUrl": photoUrl,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile(
    String userId,
  ) async {

    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .get();

    return doc.data();
  }
}