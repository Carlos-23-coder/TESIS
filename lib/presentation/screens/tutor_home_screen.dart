import 'package:flutter/material.dart';

import 'tutor_rewards_screen.dart';
import '../tutor/tutor_dashboard_screen.dart';

class TutorHomeScreen extends StatelessWidget {

  const TutorHomeScreen({
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
          "Tutor",
        ),

        actions: [

          IconButton(

            icon: const Icon(
              Icons.settings,
            ),

            onPressed: () {

              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
          ),

          IconButton(

            icon: const Icon(
              Icons.logout,
            ),

            onPressed: () =>
                _logout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            /// 🔵 HEADER
            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(25),

              decoration:
                  const BoxDecoration(

                color: Colors.blueAccent,

                borderRadius:
                    BorderRadius.only(

                  bottomLeft:
                      Radius.circular(35),

                  bottomRight:
                      Radius.circular(35),
                ),
              ),

              child: Column(

                children: [

                  /// 👤 FOTO
                  CircleAvatar(

                    radius: 55,

                    backgroundColor:
                        Colors.white,

                    child: Icon(

                      Icons.person,

                      size: 60,

                      color:
                          Colors.blue.shade300,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  const Text(

                    "Bienvenido Tutor",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(

                    "Administra el progreso y recompensas",

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// 🎁 RECOMPENSAS
            _modernButton(

              context,

              "Recompensas",

              "Gestiona premios y estrellas",

              Icons.card_giftcard,

              Colors.orange,

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const TutorRewardsScreen(),
                  ),
                );
              },
            ),

            /// 👨‍🎓 MI GRUPO
            _modernButton(

              context,

              "Mi Grupo",

              "Ver progreso y estadísticas",

              Icons.people,

              Colors.green,

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const TutorDashboardScreen(),
                  ),
                );
              },
            ),

            /// 👤 PERFIL
            _modernButton(

              context,

              "Mi Perfil",

              "Configuración del tutor",

              Icons.person,

              Colors.blue,

              () {

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(

                    content: Text(
                      "Perfil próximamente 😊",
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

  /// 🔥 BOTÓN MODERNO
  Widget _modernButton(

    BuildContext context,

    String title,

    String subtitle,

    IconData icon,

    Color color,

    VoidCallback onTap,

  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      child: GestureDetector(

        onTap: onTap,

        child: Container(

          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              25,
            ),

            boxShadow: const [

              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),

          child: Row(

            children: [

              Container(

                padding:
                    const EdgeInsets.all(
                  15,
                ),

                decoration: BoxDecoration(

                  color:
                      color.withOpacity(0.15),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 35,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      title,

                      style:
                          const TextStyle(

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}