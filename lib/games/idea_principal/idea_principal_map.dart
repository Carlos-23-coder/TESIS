import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/game_engine/game_progress.dart';
import '../../../data/models/story_override_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/tutor_resolver.dart';

import 'idea_principal_level.dart';

class IdeaPrincipalMap extends StatefulWidget {
  const IdeaPrincipalMap({super.key});

  @override
  State<IdeaPrincipalMap> createState() => _IdeaPrincipalMapState();
}

class _IdeaPrincipalMapState extends State<IdeaPrincipalMap> {
  final ProgressRepository _progressRepository = ProgressRepository();

  final StoryRepository _storyRepository = StoryRepository();

  final user = FirebaseAuth.instance.currentUser;

  Map<int, int> starsMap = {};
  List<int> availableLevels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (user != null) {
      await TutorResolver.ensureStudentLinkedToTutor(user!.email!);
    }

    final tutorEmail = await TutorResolver.resolveTutorEmail();

    final levels = await _storyRepository.listLevels(
      tutorEmail: tutorEmail,
      game: StoryGameType.ideaPrincipal,
    );

    if (user != null) {
      final progress = await _progressRepository.getStudentProgress(
        user!.email!,
      );

      GameProgress.clearGame('idea_principal');

      final loadedStars = <int, int>{};

      for (var item in progress) {
        if (item['game'] != 'idea_principal') continue;

        final int level = item['level'] ?? 1;
        final int stars = ((item['stars'] ?? 0) as int).clamp(0, 3);
        final levelIndex = level - 1;
        final current = loadedStars[levelIndex] ?? 0;

        if (stars > current) {
          loadedStars[levelIndex] = stars;
          GameProgress.saveStars('idea_principal', levelIndex, stars);
        }
      }

      starsMap = loadedStars;
    }

    if (!mounted) return;

    setState(() {
      availableLevels = levels.map((item) => item.level).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Idea Principal'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  for (int i = 0; i < availableLevels.length; i++)
                    _levelItem(context, availableLevels[i], i),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _levelItem(BuildContext context, int level, int displayIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final index = level - 1;

    final stars =
        starsMap[index] ?? GameProgress.getStars('idea_principal', index);

    final bool unlocked;

    if (level == 1) {
      unlocked = true;
    } else {
      final previousIndex = availableLevels[displayIndex - 1] - 1;

      unlocked =
          (starsMap[previousIndex] ??
              GameProgress.getStars('idea_principal', previousIndex)) >
          0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (displayIndex != 0)
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blueAccent.withValues(alpha: 0.35)
                    : Colors.blue.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          GestureDetector(
            onTap: unlocked
                ? () async {
                    final tutorEmail = await TutorResolver.resolveTutorEmail();

                    final effectiveLevel = await _storyRepository
                        .getEffectiveIdeaLevel(
                          tutorEmail: tutorEmail,
                          level: level,
                        );

                    if (effectiveLevel == null) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo cargar el nivel'),
                        ),
                      );

                      return;
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdeaPrincipalLevel(
                          level: effectiveLevel,
                          availableLevels: availableLevels,
                        ),
                      ),
                    );

                    await loadData();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: unlocked
                      ? [Colors.blue, Colors.cyan]
                      : [Colors.grey, Colors.black38],
                ),
                boxShadow: [
                  BoxShadow(
                    color: unlocked ? Colors.cyanAccent : Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.star : Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (star) => Icon(
                star < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
