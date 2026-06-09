import '../../core/game_engine/game_progress.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/progress_model.dart';
import '../../data/repositories/progress_repository.dart';

import 'idea_principal_data.dart';
import 'widgets/level_result_dialog.dart';

class IdeaPrincipalLevel extends StatefulWidget {

  final int levelIndex;

  const IdeaPrincipalLevel({
    super.key,
    required this.levelIndex,
  });

  @override
  State<IdeaPrincipalLevel> createState() =>
      _IdeaPrincipalLevelState();
}

class _IdeaPrincipalLevelState
    extends State<IdeaPrincipalLevel> {

  final AudioPlayer _audioPlayer =
      AudioPlayer();

  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  /// 🔥 USUARIO ACTUAL
  final user =
      FirebaseAuth.instance.currentUser;

  int? selectedAnswer;

  bool answered = false;

  /// ⭐ INTENTOS
  int attempts = 0;

  late final List<String> shuffledOptions;

  late final int shuffledCorrectAnswer;

  @override
  void initState() {
    super.initState();

    final level = ideaLevels[widget.levelIndex];

    final options = List<String>.from(
      level.options,
    );

    final correctOption =
        options[level.correctAnswer];

    options.shuffle(Random());

    shuffledOptions = options;
    shuffledCorrectAnswer =
        shuffledOptions.indexOf(
      correctOption,
    );
  }

  Future<void> playSuccess() async {

    await _audioPlayer.play(
      AssetSource('sounds/success.mp3'),
    );
  }

  Future<void> playError() async {

    await _audioPlayer.play(
      AssetSource('sounds/error.mp3'),
    );
  }

  void checkAnswer(int index) async {

    if (answered) return;

    final level =
        ideaLevels[widget.levelIndex];

    setState(() {

      selectedAnswer = index;
      answered = true;
    });

    /// ⭐ SUMAR INTENTO
    attempts++;

    final bool isCorrect =
      index == shuffledCorrectAnswer;

    /// ⭐ SISTEMA DE ESTRELLAS
    int earnedStars = 1;

    if (attempts == 1) {

      earnedStars = 3;

    } else if (attempts == 2) {

      earnedStars = 2;

    } else {

      earnedStars = 1;
    }

    /// 💾 GUARDAR PROGRESO
    if (isCorrect) {

      /// ⭐ GUARDADO LOCAL
      GameProgress.saveStars(
        widget.levelIndex,
        earnedStars,
      );

      /// 🔥 FIREBASE
      if (user != null) {

        final progress = ProgressModel(
          userId: user!.email!,
          level: widget.levelIndex + 1,
          stars: earnedStars,
          game: "idea_principal",
        );

        await _progressRepository
            .saveProgress(progress);
      }
    }

    /// 🔊 SONIDOS
    if (isCorrect) {

      await playSuccess();

    } else {

      await playError();
    }

    /// ⏳ ESPERA
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    /// 🎉 RESULTADO
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (_) => LevelResultDialog(

        success: isCorrect,

        /// 🔄 REINTENTAR
        onRetry: () {

          Navigator.pop(context);

          setState(() {

            answered = false;
            selectedAnswer = null;
          });
        },

        /// ➡️ SIGUIENTE NIVEL
        onNextLevel: () {

          Navigator.pop(context);

          if (
            widget.levelIndex + 1 <
            ideaLevels.length
          ) {

            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder: (_) =>
                    IdeaPrincipalLevel(
                  levelIndex:
                      widget.levelIndex + 1,
                ),
              ),
            );

          } else {

            Navigator.pop(context);

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                backgroundColor:
                    Colors.green,

                content: Text(
                  "🎉 Has completado los niveles disponibles",
                ),
              ),
            );
          }
        },

        /// 🗺️ VOLVER AL MAPA
        onMap: () {

          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  Color getButtonColor(
    int index,
    int correctAnswer,
  ) {

    if (!answered) {
      return Colors.blueAccent;
    }

    if (index == correctAnswer) {
      return Colors.green;
    }

    if (index == selectedAnswer) {
      return Colors.red;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {

    final level =
        ideaLevels[widget.levelIndex];

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: Text(
          "Nivel ${level.level}",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// 🖼️ IMAGEN
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),

              child: Image.asset(
                level.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// 📖 TITULO
            const Text(
              "Lee la siguiente historia",

              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 📚 HISTORIA
            Container(

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                level.story,

                style: const TextStyle(
                  fontSize: 24,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ❓ PREGUNTA
            Text(
              level.question,

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ OPCIONES
            for (
              int i = 0;
              i < level.options.length;
              i++
            )

              Padding(

                padding:
                    const EdgeInsets.only(
                  bottom: 15,
                ),

                child: SizedBox(

                  width: double.infinity,
                  height: 65,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          getButtonColor(
                        i,
                          shuffledCorrectAnswer,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),

                    onPressed: () =>
                        checkAnswer(i),

                    child: Text(

                      shuffledOptions[i],

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 18,
                        color:
                            Colors.white,
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