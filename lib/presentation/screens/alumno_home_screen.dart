import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';

import '../../games/idea_principal/idea_principal_map.dart';
import '../../games/preguntas_rapidas/preguntas_rapidas_map.dart';

import '../profile/student_profile_screen.dart';

import 'student_rewards_screen.dart';

class AlumnoHomeScreen extends StatelessWidget {

  const AlumnoHomeScreen({
    super.key,
  });

  void _logout(BuildContext context) {

    Navigator.pushNamedAndRemoveUntil(

      context,

      '/',

      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(

        automaticallyImplyLeading: false,

        elevation: 0,

        backgroundColor: Colors.blueAccent,

        title: const Text(
          "LectoPlay",
        ),

        actions: [

          /// 🎁 RECOMPENSAS
          IconButton(

            icon: const Icon(
              Icons.card_giftcard,
            ),

            onPressed: () async {

              final progressRepo =
                  ProgressRepository();

              final User? currentUser =
                FirebaseAuth.instance.currentUser;

              final String userId =
                currentUser?.email ?? "";

              if (userId.isEmpty) {
              return;
              }

              final stars =
                  await progressRepo
                      .getTotalStars(
                userId,
              );

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      StudentRewardsScreen(
                    userStars: stars,
                  ),
                ),
              );
            },
          ),

          /// 👤 PERFIL
          GestureDetector(

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      const StudentProfileScreen(),
                ),
              );
            },

            child: const Padding(

              padding:
                  EdgeInsets.symmetric(
                horizontal: 10,
              ),

              child: CircleAvatar(

                radius: 18,

                backgroundColor:
                    Colors.white,

                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          /// 🚪 LOGOUT
          IconButton(

            icon: const Icon(
              Icons.logout,
            ),

            onPressed: () =>
                _logout(context),
          ),
        ],
      ),

      body: Column(

        children: [

          /// 🔵 HEADER
          Container(

            width: double.infinity,

            padding:
                const EdgeInsets.all(
              25,
            ),

            decoration:
                const BoxDecoration(

              color: Colors.blueAccent,

              borderRadius:
                  BorderRadius.only(

                bottomLeft:
                    Radius.circular(30),

                bottomRight:
                    Radius.circular(30),
              ),
            ),

            child: const Column(

              children: [

                Text(

                  "¡Aprendamos jugando!",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 26,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 8,
                ),

                Text(

                  "Completa niveles y gana estrellas ⭐",

                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Expanded(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                20,
              ),

              child: GridView.count(

                crossAxisCount: 2,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                childAspectRatio: 1.1,

                children: [

                  /// IDEA PRINCIPAL
                  _gameCard(

                    context,

                    Icons.lightbulb,

                    "Idea\nPrincipal",
                  ),

                  /// PREGUNTAS RÁPIDAS
                  _gameCard(

                    context,

                    Icons.timer,

                    "Preguntas\nRápidas",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎮 CARD JUEGO
  Widget _gameCard(

    BuildContext context,

    IconData icon,

    String title,

  ) {

    return GestureDetector(

      onTap: () {

        if (title ==
            "Idea\nPrincipal") {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const IdeaPrincipalMap(),
            ),
          );

        } else if (title ==
            "Preguntas\nRápidas") {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const PreguntasRapidasMap(),
            ),
          );

        } else {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(

              content: Text(

                "Este juego estará disponible próximamente 😊",
              ),
            ),
          );
        }
      },

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          boxShadow: const [

            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(

              padding:
                  const EdgeInsets.all(
                15,
              ),

              decoration: BoxDecoration(

                color:
                    Colors.blue.shade50,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Icon(

                icon,

                size: 40,

                color:
                    Colors.blueAccent,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(

              title,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}