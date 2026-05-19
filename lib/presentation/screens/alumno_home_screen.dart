import 'package:flutter/material.dart';

import '../../games/idea_principal/idea_principal_map.dart';
import '../profile/student_profile_screen.dart';

class AlumnoHomeScreen extends StatelessWidget {
  const AlumnoHomeScreen({super.key});

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
      backgroundColor: const Color(0xFFEAF6FF),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Juegos"),

        actions: [

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
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),

              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,

                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          /// ⚙️ AJUSTES
          IconButton(
            icon: const Icon(Icons.settings),

            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
          ),

          /// 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

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

            /// PALABRAS CLAVE
            _gameCard(
              context,
              Icons.auto_awesome,
              "Palabras\nClave",
            ),
          ],
        ),
      ),
    );
  }

  /// 🎮 TARJETA JUEGO
  Widget _gameCard(
    BuildContext context,
    IconData icon,
    String title,
  ) {

    return GestureDetector(

      onTap: () {

        /// ✅ IDEA PRINCIPAL
        if (title == "Idea\nPrincipal") {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const IdeaPrincipalMap(),
            ),
          );

        } else {

          /// 🚧 JUEGOS FUTUROS
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
              BorderRadius.circular(18),

          boxShadow: const [

            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 38,
              color: Colors.blueAccent,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}