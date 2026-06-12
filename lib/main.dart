import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/database/database_helper.dart';
import 'data/services/sync_service.dart';
import 'core/accessibility/accessibility_controller.dart';

import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/tutor_home_screen.dart';
import 'presentation/screens/alumno_home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 FIREBASE (CON MANEJO DE ERRORES)
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase inicializado");
  } catch (e) {
    debugPrint("⚠️ Firebase offline: $e");

    /// LA APP FUNCIONARÁ EN MODO OFFLINE
  }

  /// 💾 SQLITE
  await DatabaseHelper.instance.database;

  /// 🔄 INICIALIZAR SERVICIO DE SINCRONIZACIÓN
  SyncService.instance;

  runApp(const LectoPlayApp());

  AccessibilityController.instance.init();
}

class LectoPlayApp extends StatelessWidget {
  const LectoPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = AccessibilityController.instance;

    return AnimatedBuilder(
      animation: accessibility,

      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'LectoPlay',

          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFEAF6FF),
            cardTheme: const CardThemeData(color: Colors.white),
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF111827),
            cardTheme: const CardThemeData(color: Color(0xFF1F2937)),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
            ),
          ),

          themeMode:
              FirebaseAuth.instance.currentUser != null &&
                  accessibility.darkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          builder: (context, child) {
            final currentUser = FirebaseAuth.instance.currentUser;
            final content = child ?? const SizedBox();

            if (currentUser == null) {
              return content;
            }

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(accessibility.fontScale),
              ),
              child: content,
            );
          },

          initialRoute: '/',

          routes: {
            '/': (context) => const _PublicRoute(child: WelcomeScreen()),

            '/login': (context) => const _PublicRoute(child: LoginScreen()),

            '/register': (context) =>
                const _PublicRoute(child: RegisterScreen()),

            /// 👨‍🏫 HOME TUTOR
            '/tutor': (context) => const TutorHomeScreen(),

            /// 👨‍🎓 HOME ALUMNO
            '/alumno': (context) => const AlumnoHomeScreen(),

            '/settings': (context) => const SettingsScreen(),

            '/userProfile': (context) => const UserProfileScreen(),
          },
        );
      },
    );
  }
}

class _PublicRoute extends StatelessWidget {
  final Widget child;

  const _PublicRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
      child: Builder(
        builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child,
          );
        },
      ),
    );
  }
}
