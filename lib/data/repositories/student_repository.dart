import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/database_helper.dart';
import '../models/student_model.dart';

class StudentRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  /// 💾 GUARDAR ALUMNO
  Future<void> saveStudent(
    StudentModel student,
  ) async {

    try {

      /// 🌐 GUARDAR EN FIREBASE
      try {

        await _firestore
            .collection("students")
            .doc(student.id)
            .set(
              student.toMap(),
            );

      } catch (e) {

        print(
          "⚠️ No se guardó en Firebase: $e",
        );
      }

    } catch (e) {

      print(
        "ERROR GUARDAR ALUMNO: $e",
      );
    }
  }

  /// 👤 OBTENER UN SOLO ALUMNO
  Future<StudentModel?> getStudentById(
    String id,
  ) async {

    try {

      final doc =
          await _firestore
              .collection("students")
              .doc(id)
              .get();

      if (!doc.exists) {
        return null;
      }

      return StudentModel.fromMap(
        doc.data()!,
      );

    } catch (e) {

      print(
        "ERROR OBTENER ALUMNO: $e",
      );

      return null;
    }
  }

  /// 📚 OBTENER TODOS LOS ALUMNOS
  Future<List<StudentModel>>
      getStudents() async {

    try {

      return await _getStudentsFirebase();

    } catch (e) {

      print(
        "ERROR OBTENER ALUMNOS: $e",
      );

      return [];
    }
  }

  /// 🌐 OBTENER ALUMNOS DE FIREBASE
  Future<List<StudentModel>>
      _getStudentsFirebase() async {

    try {

      final snapshot =
          await _firestore
              .collection("students")
              .get();

      return snapshot.docs.map((doc) {

        return StudentModel.fromMap(
          doc.data(),
        );

      }).toList();

    } catch (e) {

      print(
        "ERROR OBTENER ALUMNOS FIREBASE: $e",
      );

      return [];
    }
  }
}