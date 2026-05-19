import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';

class StudentProgressScreen
    extends StatefulWidget {

  final Map<String, dynamic> student;

  const StudentProgressScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentProgressScreen>
      createState() =>
          _StudentProgressScreenState();
}

class _StudentProgressScreenState
    extends State<StudentProgressScreen> {

  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  List<Map<String, dynamic>>
      progressList = [];

  int totalStars = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadProgress();
  }

  /// 📚 CARGAR PROGRESO
  Future<void> loadProgress() async {

    final progress =
        await _progressRepository
            .getStudentProgress(
      widget.student["email"],
    );

    int stars = 0;

    for (var item in progress) {

      stars +=
          (item["stars"] ?? 0)
              as int;
    }

    setState(() {

      progressList = progress;
      totalStars = stars;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: Text(
          widget.student["username"],
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(20),

              child: Column(

                children: [

                  /// 👤 FOTO
                  CircleAvatar(

                    radius: 60,

                    backgroundColor:
                        Colors.white,

                    backgroundImage:
                        widget.student[
                                    "photoUrl"] !=
                                null
                            ? NetworkImage(
                                widget.student[
                                    "photoUrl"],
                              )
                            : null,

                    child:
                        widget.student[
                                    "photoUrl"] ==
                                null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color:
                                    Colors.blue,
                              )
                            : null,
                  ),

                  const SizedBox(height: 20),

                  /// 👨‍🎓 NOMBRE
                  Text(

                    widget.student[
                            "username"] ??
                        "Alumno",

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.student[
                            "email"] ??
                        "",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ⭐ ESTRELLAS
                  Card(

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Padding(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      child: Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 40,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Text(

                            "$totalStars Estrellas",

                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 📚 PROGRESO
                  const Align(

                    alignment:
                        Alignment.centerLeft,

                    child: Text(

                      "Progreso",

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (progressList.isEmpty)

                    const Text(
                      "No hay progreso registrado",
                    ),

                  for (var item in progressList)

                    Card(

                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: ListTile(

                        leading: const Icon(
                          Icons.school,
                          color: Colors.blue,
                        ),

                        title: Text(
                          "Nivel ${item["level"]}",
                        ),

                        subtitle: Text(
                          item["game"] ??
                              "",
                        ),

                        trailing: Row(

                          mainAxisSize:
                              MainAxisSize.min,

                          children: List.generate(

                            3,

                            (index) => Icon(

                              index <
                                      item["stars"]
                                  ? Icons.star
                                  : Icons
                                      .star_border,

                              color:
                                  Colors.amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}