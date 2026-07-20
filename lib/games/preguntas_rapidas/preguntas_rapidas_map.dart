import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/game_engine/game_progress.dart';
import '../../data/repositories/progress_repository.dart';

import '../../../data/models/rapid_question_model.dart';
import '../../../data/repositories/rapid_questions_repository.dart';
import 'preguntas_rapidas_level.dart';

class PreguntasRapidasMap
    extends StatefulWidget {

  const PreguntasRapidasMap({
    super.key,
  });

  @override
  State<PreguntasRapidasMap>
      createState() =>
          _PreguntasRapidasMapState();
}

class _PreguntasRapidasMapState
    extends State<PreguntasRapidasMap> {

  /// 📚 REPOSITORIO DE PREGUNTAS
  final RapidQuestionsRepository
      _questionsRepository =
          RapidQuestionsRepository();

  /// 🔥 REPOSITORIO DE PROGRESO
  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  /// 👤 USUARIO ACTUAL
  final user =
      FirebaseAuth.instance.currentUser;

  /// 📚 NIVELES
  List<RapidQuestionModel>
      levels = [];

  /// ⭐ ESTRELLAS
  Map<int, int> starsMap = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadLevelsAndProgress();
  }

  /// 📚 CARGAR NIVELES Y PROGRESO
  Future<void>
      loadLevelsAndProgress() async {

    /// CARGAR NIVELES
    levels = await _questionsRepository
        .getAllLevels();

    /// CARGAR PROGRESO
    if (user != null) {

      final progress =
          await _progressRepository
              .getStudentProgress(
        user!.email!,
      );

      Map<int, int> loadedStars = {};

      for (var item in progress) {

        final int level =
            item["level"] ?? 1;

        final int stars =
            item["stars"] ?? 0;

        /// ⭐ GUARDAR EN MAPA
        loadedStars[level - 1] = stars;

        /// 💾 GUARDAR LOCAL
        GameProgress.saveStars(
          'preguntas_rapidas',
          level - 1,
          stars,
        );
      }

      setState(() {
        starsMap = loadedStars;
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: const Text(
          "Preguntas Rápidas",
        ),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(

              child: Column(

                children: [

                  const SizedBox(height: 30),

                  for (int i = 0; i < levels.length; i++)
                    _levelItem(context, i),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  /// 🎮 ITEM DE NIVEL
  Widget _levelItem(
    BuildContext context,
    int index,
  ) {

    final level = index + 1;

    /// ⭐ ESTRELLAS DEL NIVEL
    final stars =
        starsMap[index] ??
      GameProgress.getStars('preguntas_rapidas', index);

    /// 🔓 DESBLOQUEAR NIVEL
    final bool unlocked =
        level == 1 ||
        (
          starsMap[index - 1] ??
          GameProgress.getStars('preguntas_rapidas', index - 1)
        ) > 0;

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 20,
      ),

      child: Column(

        children: [

          /// 🛣️ CAMINO
          if (index != 0)

            Container(
              width: 8,
              height: 50,

              decoration: BoxDecoration(
                color: Colors.blue.shade200,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
            ),

          /// 🎮 BOTÓN NIVEL
          GestureDetector(

            onTap: unlocked
                ? () async {

                    /// ABRIR NIVEL
                    await Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            PreguntasRapidasLevel(
                          level: levels[index],
                        ),
                      ),
                    );

                    /// 🔥 RECARGAR PROGRESO
                    await loadLevelsAndProgress();
                  }
                : null,

            child: AnimatedContainer(

              duration:
                  const Duration(
                milliseconds: 300,
              ),

              width: 110,
              height: 110,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                gradient: LinearGradient(

                  colors: unlocked
                      ? [
                          Colors.blue,
                          Colors.cyan,
                        ]
                      : [
                          Colors.grey,
                          Colors.black38,
                        ],
                ),

                boxShadow: [

                  BoxShadow(
                    color: unlocked
                        ? Colors.cyanAccent
                        : Colors.black26,

                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    unlocked
                        ? Icons.quiz
                        : Icons.lock,

                    color: Colors.white,
                    size: 30,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "$level",

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// ⭐ ESTRELLAS GANADAS
          Row(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: List.generate(

              3,

              (star) => Icon(

                star < stars
                    ? Icons.star
                    : Icons.star_border,

                color: Colors.amber,
                size: 24,
              ),
            ),
          ),

          /// 📖 TÍTULO DEL NIVEL
          if (index < levels.length)
            Padding(

              padding:
                  const EdgeInsets.only(
                top: 10,
              ),

              child: Text(

                levels[index].title,

                style: const TextStyle(

                  fontSize: 14,
                  fontWeight:
                      FontWeight.w500,
                ),

                textAlign:
                    TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}