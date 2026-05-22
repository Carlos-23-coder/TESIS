import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/repositories/progress_repository.dart';

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

  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  List<Map<String, dynamic>>
      students = [];

  bool isLoading = true;

  double averageProgress = 0;

  int totalStars = 0;

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

    students = [];

    double progressSum = 0;

    int starsSum = 0;

    for (var doc in snapshot.docs) {

      final data = doc.data();

      final email =
          data["email"] ?? "";

      /// ⭐ ESTRELLAS
      final stars =
          await _progressRepository
              .getTotalStars(email);

      /// 📈 PROGRESO
      final percentage =
          await _progressRepository
              .getProgressPercentage(
            email,
          );

      progressSum += percentage;

      starsSum += stars;

      students.add({

        ...data,

        "stars": stars,

        "percentage": percentage,
      });
    }

    /// 🏆 ORDENAR POR ESTRELLAS
    students.sort(
      (a, b) =>
          (b["stars"] as int)
              .compareTo(
        a["stars"] as int,
      ),
    );

    averageProgress =
        students.isEmpty
            ? 0
            : progressSum /
                students.length;

    totalStars = starsSum;

    setState(() {
      isLoading = false;
    });
  }

  /// 📊 CARD ESTADÍSTICA
  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Expanded(

      child: Container(

        margin:
            const EdgeInsets.all(8),

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          boxShadow: [

            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            ),
          ],
        ),

        child: Column(

          children: [

            Icon(
              icon,
              size: 35,
              color: color,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              value,

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(

              title,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📈 GRÁFICO
  Widget buildChart() {

    return Container(

      height: 260,

      padding:
          const EdgeInsets.all(16),

      margin:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),

      child: BarChart(

        BarChartData(

          borderData:
              FlBorderData(show: false),

          gridData:
              FlGridData(show: false),

          titlesData:
              FlTitlesData(

            leftTitles:
                AxisTitles(

              sideTitles:
                  SideTitles(
                showTitles: true,
              ),
            ),

            topTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),

            bottomTitles:
                AxisTitles(

              sideTitles:
                  SideTitles(

                showTitles: true,

                getTitlesWidget:
                    (value, meta) {

                  final index =
                      value.toInt();

                  if (index >=
                      students.length) {

                    return const SizedBox();
                  }

                  final name =
                      students[index]
                              ["username"] ??
                          "";

                  return Padding(

                    padding:
                        const EdgeInsets.only(
                      top: 8,
                    ),

                    child: Text(

                      name.toString()
                          .substring(
                        0,
                        name.length > 3
                            ? 3
                            : name.length,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups:
              students
                  .asMap()
                  .entries
                  .map((entry) {

            final index =
                entry.key;

            final student =
                entry.value;

            final stars =
                student["stars"] ?? 0;

            return BarChartGroupData(

              x: index,

              barRods: [

                BarChartRodData(

                  toY:
                      stars.toDouble(),

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(
                    6,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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

          : SingleChildScrollView(

              child: Column(

                children: [

                  const SizedBox(
                    height: 10,
                  ),

                  /// 📊 ESTADÍSTICAS
                  Row(

                    children: [

                      statCard(

                        title:
                            "Alumnos",

                        value:
                            students.length
                                .toString(),

                        icon:
                            Icons.people,

                        color:
                            Colors.blue,
                      ),

                      statCard(

                        title:
                            "Promedio",

                        value:
                            "${averageProgress.toInt()}%",

                        icon:
                            Icons.bar_chart,

                        color:
                            Colors.green,
                      ),
                    ],
                  ),

                  Row(

                    children: [

                      statCard(

                        title:
                            "Estrellas",

                        value:
                            totalStars
                                .toString(),

                        icon:
                            Icons.star,

                        color:
                            Colors.orange,
                      ),

                      statCard(

                        title:
                            "Top Alumno",

                        value:
                            students.isNotEmpty
                                ? students.first[
                                    "username"]
                                : "-",

                        icon:
                            Icons.emoji_events,

                        color:
                            Colors.purple,
                      ),
                    ],
                  ),

                  /// 📈 GRÁFICO
                  buildChart(),

                  const SizedBox(
                    height: 20,
                  ),

                  /// 🏆 TÍTULO
                  Container(

                    alignment:
                        Alignment.centerLeft,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: const Text(

                      "🏆 Ranking de alumnos",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  /// 👨‍🎓 LISTA ALUMNOS
                  ListView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

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

                          subtitle: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                student["email"] ??
                                    "",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              /// ⭐ ESTRELLAS
                              Row(

                                children: [

                                  const Icon(
                                    Icons.star,
                                    color:
                                        Colors.amber,
                                    size: 20,
                                  ),

                                  const SizedBox(
                                    width: 5,
                                  ),

                                  Text(
                                    "${student["stars"]} estrellas",
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              /// 📈 PROGRESO
                              ClipRRect(

                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),

                                child:
                                    LinearProgressIndicator(

                                  value:
                                      (student["percentage"] ??
                                              0) /
                                          100,

                                  minHeight: 8,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                "${student["percentage"].toStringAsFixed(1)}% completado",
                              ),
                            ],
                          ),

                          trailing:
                              const Icon(
                            Icons.arrow_forward_ios,
                          ),

                          /// 🔥 PERFIL
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
                ],
              ),
            ),
    );
  }
}