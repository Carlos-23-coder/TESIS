import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_model.dart';

class StudentRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 💾 GUARDAR ALUMNO
  Future<void> saveStudent(
    StudentModel student,
  ) async {

    await _firestore
        .collection("students")
        .doc(student.id)
        .set(student.toMap());
  }

  /// 📚 OBTENER ALUMNOS
  Future<List<StudentModel>>
      getStudents() async {

    final snapshot =
        await _firestore
            .collection("students")
            .get();

    return snapshot.docs.map((doc) {

      return StudentModel.fromMap(
        doc.data(),
      );

    }).toList();
  }
}