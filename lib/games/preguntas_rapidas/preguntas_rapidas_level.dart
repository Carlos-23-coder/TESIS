import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/game_engine/game_progress.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/progress_repository.dart';

import '../../../data/models/rapid_question_model.dart';
import 'widgets/rapid_result_dialog.dart';

class PreguntasRapidasLevel
    extends StatefulWidget {

  final RapidQuestionModel
      level;

  const PreguntasRapidasLevel({
    super.key,
    required this.level,
  });

  @override
  State<PreguntasRapidasLevel>
      createState() =>
          _PreguntasRapidasLevelState();
}

class _PreguntasRapidasLevelState
    extends State<
        PreguntasRapidasLevel> {

  final AudioPlayer _audioPlayer =
      AudioPlayer();

  final FlutterTts _tts =
      FlutterTts();

  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  /// 🔥 USUARIO ACTUAL
  final user =
      FirebaseAuth.instance.currentUser;

  int currentQuestion = 0;

  int correctAnswers = 0;

  int? selectedAnswer;

  bool answered = false;

  /// ⭐ INTENTOS
  int attempts = 0;

  /// ⏱️ TIMER
  Timer? _questionTimer;
  int timeRemaining = 10;

  @override
  void initState() {
    super.initState();
    _initTts();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  /// 🔊 INICIALIZAR TTS
  Future<void> _initTts() async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.0);
  }

  /// ⏱️ INICIAR TIMER
  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() {
      timeRemaining = 10;
    });

    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          timeRemaining--;
        });

        if (timeRemaining <= 0) {
          _questionTimer?.cancel();
          // 🔄 PASAR A LA SIGUIENTE PREGUNTA
          _autoNextQuestion();
        }
      },
    );
  }

  /// 🔄 PASAR AUTOMÁTICAMENTE
  void _autoNextQuestion() async {
    if (answered) return;

    setState(() {
      answered = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    if (currentQuestion <
        widget.level.questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
      _startQuestionTimer();
    } else {
      _finishLevel();
    }
  }

  /// 🎊 REPRODUCIR NARRADOR
  Future<void> _readStory(String text) async {
    await _tts.speak(text);
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

  void answerQuestion(
    int answer,
  ) async {

    if (answered) return;

    _questionTimer?.cancel();

    final correct =
        widget.level.questions[
                currentQuestion]
            ["correctAnswer"];

    setState(() {
      selectedAnswer = answer;
      answered = true;
    });

    final bool isCorrect =
        answer == correct;

    /// 🔊 SONIDOS
    if (isCorrect) {

      await playSuccess();
      correctAnswers++;

    } else {

      await playError();
    }

    /// ⏳ ESPERA
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    /// ➡️ SIGUIENTE PREGUNTA O RESULTADO
    if (currentQuestion <
        widget.level.questions.length - 1) {

      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
      _startQuestionTimer();

    } else {

      _finishLevel();
    }
  }

  /// 🎉 FINALIZAR NIVEL
  Future<void> _finishLevel() async {

    /// 🎉 NIVEL COMPLETADO
    attempts++;

    /// ⭐ SISTEMA DE ESTRELLAS
    int earnedStars = 1;

    final int totalQuestions =
        widget.level.questions.length;

    /// CALCULAR ESTRELLAS BASADO EN RESPUESTAS
    if (correctAnswers ==
        totalQuestions) {

      earnedStars = 3; // PERFECTO

    } else if (correctAnswers >=
        totalQuestions - 1) {

      earnedStars = 2; // CASI PERFECTO

    } else {

      earnedStars = 1; // PASÓ
    }

    /// 💾 GUARDAR PROGRESO
    /// ⭐ GUARDADO LOCAL
    GameProgress.saveStars(
      'preguntas_rapidas',
      widget.level.level - 1,
      earnedStars,
    );

    /// 🔥 FIREBASE
    if (user != null) {

      final progress = ProgressModel(
        userId: user!.email!,
        level: widget.level.level,
        stars: earnedStars,
        game: "preguntas_rapidas",
      );

      await _progressRepository
          .saveProgress(progress);
    }

    if (!mounted) return;

    /// 🎉 MOSTRAR RESULTADO
    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) =>
          RapidResultDialog(

        correctAnswers:
            correctAnswers,

        totalQuestions:
            totalQuestions,

        earnedStars: earnedStars,

        onRetry: () {

          Navigator.pop(context);

          setState(() {

            currentQuestion = 0;
            correctAnswers = 0;
            selectedAnswer = null;
            answered = false;
            attempts = 0;
          });
          _startQuestionTimer();
        },

        onBack: () {

          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final question =
        widget.level.questions[
            currentQuestion];

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.level.title,
        ),
        actions: [
          /// ⏱️ TIMER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: timeRemaining <= 3
                      ? Colors.red
                      : Colors.blue,
                ),
                child: Center(
                  child: Text(
                    '$timeRemaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            /// 📊 PROGRESO
            LinearProgressIndicator(

              value:
                  (currentQuestion + 1) /
                      widget.level
                          .questions
                          .length,

              minHeight: 6,
            ),

            const SizedBox(
              height: 20,
            ),

            /// 🖼️ IMAGEN
            if (widget.level
                .imageUrl
                .isNotEmpty)

              ClipRRect(

                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),

                child:
                    Image.network(
                  widget.level
                      .imageUrl,
                ),
              ),

            const SizedBox(
              height: 20,
            ),

            /// 📖 HISTORIA + 🔊 NARRADOR
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Expanded(

                  child: Text(

                    widget.level.story,

                    style:
                        const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔊 BOTÓN NARRADOR
                ElevatedButton(

                  style:
                      ElevatedButton
                          .styleFrom(

                    backgroundColor:
                        Colors.blue,

                    padding:
                        const EdgeInsets
                            .all(12),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),

                  onPressed: () {

                    _readStory(
                      widget.level.story,
                    );
                  },

                  child: const Icon(

                    Icons
                        .volume_up,

                    color:
                        Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ),

            /// ❓ PREGUNTA
            Text(

              question["question"],

              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /// 🔘 OPCIONES
            ...List.generate(

              4,

              (index) {

                final isSelected =
                    selectedAnswer ==
                    index;

                final bool isCorrect =
                    question[
                            "correctAnswer"] ==
                        index;

                Color buttonColor =
                    Colors.grey.shade200;

                if (answered) {

                  if (isCorrect) {

                    buttonColor =
                        Colors.green;

                  } else if (
                      isSelected) {

                    buttonColor =
                        Colors.red;
                  }
                }

                return Padding(

                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 10,
                  ),

                  child:
                      SizedBox(

                    width:
                        double.infinity,

                    child:
                        ElevatedButton(

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            buttonColor,

                        padding:
                            const EdgeInsets
                                .all(
                          15,
                        ),
                      ),

                      onPressed:
                          answered
                              ? null
                              : () {

                                answerQuestion(
                                  index,
                                );
                              },

                      child: Text(

                        question[
                                "options"]
                            [index],

                        style:
                            TextStyle(

                          color: answered
                              ? Colors
                                  .white
                              : Colors
                                  .black,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
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