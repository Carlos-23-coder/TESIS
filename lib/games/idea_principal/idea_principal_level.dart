import '../../../../../core/game_engine/game_progress.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/widgets/story_image.dart';
import '../../../../../data/models/progress_model.dart';
import '../../../../../data/models/story_override_model.dart';
import '../../../../../data/repositories/progress_repository.dart';
import '../../../../../data/repositories/story_repository.dart';
import '../../../../../data/services/tutor_resolver.dart';

import 'widgets/level_result_dialog.dart';

class IdeaPrincipalLevel extends StatefulWidget {
  final EffectiveIdeaLevel level;
  final List<int> availableLevels;

  const IdeaPrincipalLevel({
    super.key,
    required this.level,
    required this.availableLevels,
  });

  @override
  State<IdeaPrincipalLevel> createState() => _IdeaPrincipalLevelState();
}

class _IdeaPrincipalLevelState extends State<IdeaPrincipalLevel> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final ProgressRepository _progressRepository = ProgressRepository();

  final StoryRepository _storyRepository = StoryRepository();

  final user = FirebaseAuth.instance.currentUser;

  int? selectedAnswer;
  bool answered = false;
  int attempts = 0;

  late final List<String> shuffledOptions;
  late final int shuffledCorrectAnswer;

  int get levelIndex => widget.level.level - 1;

  @override
  void initState() {
    super.initState();

    final options = List<String>.from(widget.level.options);
    final correctOption = options[widget.level.correctAnswer];

    options.shuffle(Random());

    shuffledOptions = options;
    shuffledCorrectAnswer = shuffledOptions.indexOf(correctOption);
  }

  Future<void> playSuccess() async {
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  Future<void> playError() async {
    await _audioPlayer.play(AssetSource('sounds/error.mp3'));
  }

  void checkAnswer(int index) async {
    if (answered) return;

    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    attempts++;

    final bool isCorrect = index == shuffledCorrectAnswer;

    int earnedStars = 1;

    if (attempts == 1) {
      earnedStars = 3;
    } else if (attempts == 2) {
      earnedStars = 2;
    } else {
      earnedStars = 1;
    }

    if (isCorrect) {
      final cappedStars = earnedStars.clamp(0, 3);

      GameProgress.saveStars('idea_principal', levelIndex, cappedStars);

      if (user != null) {
        final progress = ProgressModel(
          userId: user!.email!,
          level: widget.level.level,
          stars: cappedStars,
          game: 'idea_principal',
        );

        await _progressRepository.saveProgress(progress);
      }
    }

    if (isCorrect) {
      await playSuccess();
    } else {
      await playError();
    }

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelResultDialog(
        success: isCorrect,
        onRetry: () {
          Navigator.pop(context);

          setState(() {
            answered = false;
            selectedAnswer = null;
          });
        },
        onNextLevel: () async {
          Navigator.pop(context);

          final currentPosition = widget.availableLevels.indexOf(
            widget.level.level,
          );

          if (currentPosition >= 0 &&
              currentPosition + 1 < widget.availableLevels.length) {
            final nextLevelNumber = widget.availableLevels[currentPosition + 1];

            final tutorEmail = await TutorResolver.resolveTutorEmail();

            final nextLevel = await _storyRepository.getEffectiveIdeaLevel(
              tutorEmail: tutorEmail,
              level: nextLevelNumber,
            );

            if (!mounted || nextLevel == null) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => IdeaPrincipalLevel(
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
                content: Text('🎉 Has completado los niveles disponibles'),
              ),
            );
          }
        },
        onMap: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Nivel ${level.level}'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: StoryImage(imagePath: level.image, height: 220),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lee la siguiente historia',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                level.story,
                style: const TextStyle(fontSize: 24, height: 1.6),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              level.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < shuffledOptions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 65),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getButtonColor(
                          i,
                          shuffledCorrectAnswer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => checkAnswer(i),
                      child: Text(
                        shuffledOptions[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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
