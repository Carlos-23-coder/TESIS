import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class TutorRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 👤 OBTENER PERFIL DEL TUTOR
  Future<Map<String, dynamic>?>
      getProfile(
    String email,
  ) async {

    try {

      final doc =
          await _firestore
              .collection("users")
              .doc(email)
              .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();

    } catch (e) {

      print(
        "ERROR PERFIL TUTOR: $e",
      );

      return null;
    }
  }

  /// 📷 GUARDAR FOTO
  Future<void> savePhotoUrl(
    String email,
    String photoPath,
  ) async {

    try {

      await _firestore
          .collection("users")
          .doc(email)
          .update({

        "photoUrl": photoPath,
      });

    } catch (e) {

      print(
        "ERROR FOTO TUTOR: $e",
      );
    }
  }

  /// 👨‍🎓 CONTAR ALUMNOS
  Future<int> getStudentsCount() async {

    try {

      final snapshot =
          await _firestore
              .collection("users")
              .where(
                "role",
                isEqualTo: "Alumno",
              )
              .get();

      return snapshot.docs.length;

    } catch (e) {

      print(
        "ERROR CONTAR ALUMNOS: $e",
      );

      return 0;
    }
  }

  /// 📂 FOTO LOCAL
  Future<File?> getLocalPhoto(
    String path,
  ) async {

    try {

      final file =
          File(path);

      if (await file.exists()) {
        return file;
      }

      return null;

    } catch (e) {

      print(
        "ERROR FOTO LOCAL: $e",
      );

      return null;
    }
  }
}