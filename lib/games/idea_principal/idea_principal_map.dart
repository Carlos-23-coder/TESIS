import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/game_engine/game_progress.dart';
import '../../data/repositories/progress_repository.dart';

import 'idea_principal_level.dart';

class IdeaPrincipalMap extends StatefulWidget {

  const IdeaPrincipalMap({super.key});

  @override
  State<IdeaPrincipalMap> createState() =>
      _IdeaPrincipalMapState();
}

class _IdeaPrincipalMapState
    extends State<IdeaPrincipalMap> {

  /// 🔥 REPOSITORIO
  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  /// 👤 USUARIO ACTUAL
  final user =
      FirebaseAuth.instance.currentUser;

  /// ⭐ ESTRELLAS
  Map<int, int> starsMap = {};

  @override
  void initState() {
    super.initState();

    loadProgress();
  }

  /// 📚 CARGAR PROGRESO
  Future<void> loadProgress() async {

    if (user == null) return;

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
        level - 1,
        stars,
      );
    }

    setState(() {
      starsMap = loadedStars;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: const Text(
          "Idea Principal",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            const SizedBox(height: 30),

            for (int i = 0; i < 10; i++)
              _levelItem(context, i),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _levelItem(
    BuildContext context,
    int index,
  ) {

    final level = index + 1;

    /// ⭐ ESTRELLAS DEL NIVEL
    final stars =
        starsMap[index] ??
        GameProgress.getStars(index);

    /// 🔓 DESBLOQUEAR NIVEL
    final bool unlocked =
        level == 1 ||
        (
          starsMap[index - 1] ??
          GameProgress.getStars(index - 1)
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
                            IdeaPrincipalLevel(
                          levelIndex: index,
                        ),
                      ),
                    );

                    /// 🔥 RECARGAR PROGRESO
                    await loadProgress();
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
                          Colors.orange,
                          Colors.deepOrange,
                        ]
                      : [
                          Colors.grey,
                          Colors.black38,
                        ],
                ),

                boxShadow: [

                  BoxShadow(
                    color: unlocked
                        ? Colors.orangeAccent
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
                        ? Icons.star
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
        ],
      ),
    );
  }
}