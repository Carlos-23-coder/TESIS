import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../data/repositories/reward_claim_repository.dart';
import '../../data/repositories/tutor_repository.dart';

import '../tutor/tutor_reward_claims_screen.dart';
import '../tutor/stories_admin_screen.dart';
import '../tutor/tutor_profile_screen.dart';

import 'tutor_rewards_screen.dart';
import '../tutor/tutor_dashboard_screen.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  final TutorRepository _repository = TutorRepository();

  final RewardClaimRepository _claimRepository = RewardClaimRepository();

  File? tutorImage;

  String tutorName = "Tutor";

  @override
  void initState() {
    super.initState();

    loadTutorData();
  }

  /// 👤 CARGAR DATOS DEL TUTOR
  Future<void> loadTutorData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data = await _repository.getProfile(user.email!);

    if (data == null) return;

    tutorName = data["username"] ?? "Tutor";

    final photoPath = data["photoUrl"] ?? "";

    if (photoPath.isNotEmpty) {
      final file = File(photoPath);

      if (await file.exists()) {
        tutorImage = file;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF1D4ED8) : Colors.blueAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,

        elevation: 0,

        backgroundColor: headerColor,

        title: const Text("Tutor"),

        actions: [
          IconButton(
            tooltip: 'Accesibilidad',

            icon: const Icon(Icons.accessibility_new),

            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),

          StreamBuilder(
            stream: FirebaseAuth.instance.currentUser?.email == null
                ? const Stream.empty()
                : _claimRepository.watchPendingClaimsForTutor(
                    FirebaseAuth.instance.currentUser!.email!,
                  ),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TutorRewardClaimsScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔵 HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: headerColor,

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),

                  bottomRight: Radius.circular(35),
                ),
              ),

              child: Column(
                children: [
                  /// 👤 FOTO
                  CircleAvatar(
                    radius: 55,

                    backgroundColor: Colors.white,

                    backgroundImage: tutorImage != null
                        ? FileImage(tutorImage!)
                        : null,

                    child: tutorImage == null
                        ? Icon(
                            Icons.person,

                            size: 60,

                            color: Colors.blue.shade300,
                          )
                        : null,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Bienvenido $tutorName",

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Administra el progreso y recompensas",

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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

                  MaterialPageRoute(builder: (_) => const TutorRewardsScreen()),
                );
              },
            ),

            /// 🔔 SOLICITUDES
            _modernButton(
              context,

              "Solicitudes",

              "Aprueba recompensas de alumnos",

              Icons.notifications_active,

              Colors.deepOrange,

              () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const TutorRewardClaimsScreen(),
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
                    builder: (_) => const TutorDashboardScreen(),
                  ),
                );
              },
            ),

            /// ⚡ HISTORIAS
            _modernButton(
              context,

              "Historias",

              "Personaliza historias y preguntas predeterminadas",

              Icons.quiz,

              Colors.purple,

              () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const StoriesAdminScreen()),
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

              () async {
                await Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const TutorProfileScreen()),
                );

                /// 🔄 RECARGAR FOTO
                loadTutorData();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child: GestureDetector(
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: theme.cardColor,

            borderRadius: BorderRadius.circular(25),

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
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: color, size: 35),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,

                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
