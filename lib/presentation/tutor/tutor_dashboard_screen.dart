import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_progress_screen.dart';

class TutorDashboardScreen
    extends StatefulWidget {

  const TutorDashboardScreen({
    super.key,
  });

  @override
  State<TutorDashboardScreen>
      createState() =>
          _TutorDashboardScreenState();
}

class _TutorDashboardScreenState
    extends State<TutorDashboardScreen> {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<Map<String, dynamic>>
      students = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadStudents();
  }

  /// 👨‍🎓 CARGAR ALUMNOS
  Future<void> loadStudents() async {

    final snapshot = await _firestore
        .collection("users")
        .where(
          "role",
          isEqualTo: "Alumno",
        )
        .get();

    students = snapshot.docs
        .map((doc) => doc.data())
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(

        title: const Text(
          "Panel del Tutor",
        ),

        centerTitle: true,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : students.isEmpty

              ? const Center(
                  child: Text(
                    "No hay alumnos registrados",

                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  itemCount:
                      students.length,

                  itemBuilder:
                      (context, index) {

                    final student =
                        students[index];

                    return Card(

                      margin:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),

                      elevation: 4,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: ListTile(

                        contentPadding:
                            const EdgeInsets.all(
                          16,
                        ),

                        /// 👤 FOTO
                        leading:
                            CircleAvatar(

                          radius: 30,

                          backgroundColor:
                              Colors.blue
                                  .shade100,

                          backgroundImage:
                              student["photoUrl"] !=
                                      null
                                  ? NetworkImage(
                                      student[
                                          "photoUrl"],
                                    )
                                  : null,

                          child:
                              student["photoUrl"] ==
                                      null
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color:
                                          Colors.blue,
                                    )
                                  : null,
                        ),

                        /// 👨‍🎓 NOMBRE
                        title: Text(

                          student["username"] ??
                              "Alumno",

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        /// 📧 EMAIL
                        subtitle: Padding(

                          padding:
                              const EdgeInsets.only(
                            top: 5,
                          ),

                          child: Text(

                            student["email"] ??
                                "",

                            style:
                                const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),

                        /// ➡️ ICONO
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),

                        /// 🔥 ABRIR PERFIL
                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  StudentProgressScreen(
                                student:
                                    student,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}