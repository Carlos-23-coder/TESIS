  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:audioplayers/audioplayers.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter_tts/flutter_tts.dart';

  import '../../core/widgets/story_image.dart';
  import '../../core/game_engine/game_progress.dart';
  import '../../data/models/progress_model.dart';
  import '../../data/repositories/progress_repository.dart';
  import '../../data/repositories/story_repository.dart';
  import '../../data/services/tutor_resolver.dart';

  import '../../../data/models/rapid_question_model.dart';
  import 'widgets/rapid_result_dialog.dart';

  class PreguntasRapidasLevel
      extends StatefulWidget {

    final RapidQuestionModel level;
    final List<int> availableLevels;

    const PreguntasRapidasLevel({
      super.key,
      required this.level,
      required this.availableLevels,
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

    final StoryRepository
        _storyRepository =
            StoryRepository();

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
    bool gameStarted = false;

    @override
    void initState() {
      super.initState();
      _initTts();
    }

    @override
    void dispose() {
      _questionTimer?.cancel();
      _tts.stop();
      _audioPlayer.dispose();
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

          if (timeRemaining <= 1) {
            timeRemaining = 0;
            _questionTimer?.cancel();
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

    Color getButtonColor(int index, int correctAnswer) {
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

    /// 🎊 REPRODUCIR NARRADOR
    Future<void> _readStory(String text) async {
      await _tts.speak(text);
    }

    void startGame() {

    setState(() {
      gameStarted = true;
    });

    _startQuestionTimer();
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

      attempts++;

      final int totalQuestions =
          widget.level.questions.length;

      final int passThreshold =
          (totalQuestions / 2).ceil();

      final bool success =
          correctAnswers >= passThreshold;

      int earnedStars = 0;

      if (success) {
        if (correctAnswers == totalQuestions) {
          earnedStars = 3;
        } else if (correctAnswers >= totalQuestions - 1) {
          earnedStars = 2;
        } else {
          earnedStars = 1;
        }

        earnedStars = earnedStars.clamp(0, 3);

        GameProgress.saveStars(
          'preguntas_rapidas',
          widget.level.level - 1,
          earnedStars,
        );

        if (user != null) {
          final progress = ProgressModel(
            userId: user!.email!,
            level: widget.level.level,
            stars: earnedStars,
            game: "preguntas_rapidas",
          );

          await _progressRepository.saveProgress(progress);
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RapidResultDialog(
          success: success,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          earnedStars: earnedStars,
          onRetry: () {
            Navigator.pop(context);

            setState(() {
              currentQuestion = 0;
              correctAnswers = 0;
              selectedAnswer = null;
              answered = false;
              attempts = 0;
              timeRemaining = 10;
              gameStarted = false;
            });
          },
          onNextLevel: () async {
            Navigator.pop(context);

            final currentPosition = widget.availableLevels.indexOf(
              widget.level.level,
            );

            if (currentPosition >= 0 &&
                currentPosition + 1 <
                    widget.availableLevels.length) {
              final nextLevelNumber =
                  widget.availableLevels[currentPosition + 1];

              final tutorEmail =
                  await TutorResolver.resolveTutorEmail();

              final nextLevel =
                  await _storyRepository.getEffectiveRapidLevel(
                tutorEmail: tutorEmail,
                level: nextLevelNumber,
              );

              if (!mounted || nextLevel == null) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PreguntasRapidasLevel(
                    level: nextLevel,
                    availableLevels: widget.availableLevels,
                  ),
                ),
              );
            } else {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    '🎉 Has completado los niveles disponibles',
                  ),
                ),
              );
            }
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
        gameStarted
            ? widget.level.questions[
                currentQuestion]
            : null;

      return Scaffold(

        appBar: AppBar(
          title: Text(
            widget.level.title,
          ),
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

              if (gameStarted) ...[

                LinearProgressIndicator(

                  value:
                    currentQuestion /
                    widget.level.questions.length,

                  minHeight: 6,
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
              if (!gameStarted) ...[
              /// 🖼️ IMAGEN
              if (widget.level.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: StoryImage(
                    imagePath: widget.level.imageUrl,
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
              ],
              if (!gameStarted)

                Center(

                  child: ElevatedButton(

                    onPressed: () {

                      showDialog(

                        context: context,

                        builder: (_) {

                          return AlertDialog(

                            title: const Text(
                              "🚀 Preparado",
                            ),

                            content: const Text(
                              "¿Listo para comenzar las preguntas?"
                            ),

                            actions: [

                              TextButton(

                                onPressed: () {

                                  Navigator.pop(context);

                                  startGame();
                                },

                                child: const Text(
                                  "¡Vamos!"
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    child: const Text(
                      "Comenzar preguntas",
                    ),
                  ),
                ),

        if (gameStarted) ...[

          Center(

            child: Container(

              width: 120,
              height: 120,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                color: timeRemaining <= 3
                    ? Colors.red
                    : Colors.blue,
              ),

              child: Center(

                child: Text(

                  "$timeRemaining",

                  style: const TextStyle(

                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          /// ❓ PREGUNTA
          Text(

            question!["question"],

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

              /// 🔘 OPCIONES
        ...List.generate(
          4,
          (index) {
            final correctAnswer =
                question!["correctAnswer"] as int;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(
                      index,
                      correctAnswer,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: answered
                      ? null
                      : () => answerQuestion(index),
                  child: Text(
                    question!["options"][index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
        ],
        ),
      ),
    );  
  }
  }