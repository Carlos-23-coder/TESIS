import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  /// SUBIR FOTO
  Future<String> uploadProfileImage(
    String userId,
    File imageFile,
  ) async {

    final ref = _storage
        .ref()
        .child("profiles")
        .child("$userId.jpg");

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }

  /// GUARDAR FOTO EN FIRESTORE
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

  /// OBTENER PERFIL
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