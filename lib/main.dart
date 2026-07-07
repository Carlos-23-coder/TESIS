import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
import 'presentation/admin/admin_home_screen.dart';

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
        final highContrast = accessibility.highContrast;
        final lightScheme = accessibility.highContrast
            ? const ColorScheme.highContrastLight(
                primary: Color(0xFF001B5E),
                onPrimary: Colors.white,
                secondary: Color(0xFF004D40),
                onSecondary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
                error: Color(0xFFB00020),
                onError: Colors.white,
              )
            : ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.light,
              );
        final darkScheme = accessibility.highContrast
            ? const ColorScheme.highContrastDark(
                primary: Color(0xFFFFD600),
                onPrimary: Colors.black,
                secondary: Color(0xFF00E5FF),
                onSecondary: Colors.black,
                surface: Colors.black,
                onSurface: Colors.white,
                error: Color(0xFFFF8A80),
                onError: Colors.black,
              )
            : ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.dark,
              );
        final lightCardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: highContrast ? Colors.black : Colors.transparent,
            width: highContrast ? 2 : 0,
          ),
        );
        final darkCardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: highContrast ? Colors.white : Colors.transparent,
            width: highContrast ? 2 : 0,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'LectoPlay',

          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: accessibility.highContrast
                ? const Color(0xFFF7F7F7)
                : const Color(0xFFEAF6FF),
            appBarTheme: AppBarTheme(
              backgroundColor: highContrast
                  ? Colors.black
                  : const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              elevation: highContrast ? 4 : 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: highContrast ? 6 : null,
              shadowColor: highContrast ? Colors.black54 : null,
              surfaceTintColor: Colors.transparent,
              shape: lightCardShape,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: highContrast
                    ? Colors.black
                    : lightScheme.primary,
                foregroundColor: Colors.white,
                side: highContrast
                    ? const BorderSide(color: Color(0xFFFFD600), width: 2)
                    : BorderSide.none,
              ),
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: highContrast ? Colors.black : null,
              inactiveTrackColor: highContrast ? Colors.black26 : null,
              thumbColor: highContrast ? const Color(0xFFFFD600) : null,
              valueIndicatorColor: highContrast ? Colors.black : null,
              valueIndicatorTextStyle: highContrast
                  ? const TextStyle(color: Colors.white)
                  : null,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: highContrast
                  ? const WidgetStatePropertyAll(Color(0xFFFFD600))
                  : null,
              trackColor: highContrast
                  ? const WidgetStatePropertyAll(Colors.black)
                  : null,
            ),
          ),

          darkTheme: ThemeData(
            colorScheme: darkScheme,
            scaffoldBackgroundColor: accessibility.highContrast
                ? Colors.black
                : const Color(0xFF111827),
            cardTheme: CardThemeData(
              color: accessibility.highContrast
                  ? Colors.black
                  : const Color(0xFF1F2937),
              elevation: highContrast ? 6 : null,
              shadowColor: highContrast ? Colors.white54 : null,
              surfaceTintColor: Colors.transparent,
              shape: darkCardShape,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: highContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF1D4ED8),
              foregroundColor: highContrast ? Colors.black : Colors.white,
              elevation: highContrast ? 4 : 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: highContrast
                    ? const Color(0xFFFFD600)
                    : darkScheme.primary,
                foregroundColor: highContrast ? Colors.black : Colors.white,
                side: highContrast
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
              ),
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: highContrast ? const Color(0xFFFFD600) : null,
              inactiveTrackColor: highContrast ? Colors.white38 : null,
              thumbColor: highContrast ? Colors.white : null,
              valueIndicatorColor: highContrast ? const Color(0xFFFFD600) : null,
              valueIndicatorTextStyle: highContrast
                  ? const TextStyle(color: Colors.black)
                  : null,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: highContrast
                  ? const WidgetStatePropertyAll(Colors.black)
                  : null,
              trackColor: highContrast
                  ? const WidgetStatePropertyAll(Color(0xFFFFD600))
                  : null,
            ),
          ),

          themeMode: accessibility.darkMode ? ThemeMode.dark : ThemeMode.light,

          builder: (context, child) {
            final content = child ?? const SizedBox();

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

            '/admin': (context) => const AdminHomeScreen(),

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
