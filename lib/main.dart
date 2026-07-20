import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/database/database_helper.dart';
import 'data/services/sync_service.dart';

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
    print("✅ Firebase inicializado");

  } catch (e) {

    print(
      "⚠️ Firebase offline: $e",
    );
    /// LA APP FUNCIONARÁ EN MODO OFFLINE
  }

  /// 💾 SQLITE
  await DatabaseHelper.instance.database;

  /// 🔄 INICIALIZAR SERVICIO DE SINCRONIZACIÓN
  SyncService.instance;

  runApp(
    const LectoPlayApp(),
  );
}

class LectoPlayApp extends StatelessWidget {

  const LectoPlayApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'LectoPlay',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',

      routes: {

        '/': (context) =>
            const WelcomeScreen(),

        '/login': (context) =>
            const LoginScreen(),

        '/register': (context) =>
            const RegisterScreen(),

        /// 👨‍🏫 HOME TUTOR
        '/tutor': (context) =>
            const TutorHomeScreen(),

        /// 👨‍🎓 HOME ALUMNO
        '/alumno': (context) =>
            const AlumnoHomeScreen(),

        '/settings': (context) =>
            const SettingsScreen(),

        '/userProfile': (context) =>
            const UserProfileScreen(),
      },
    );
  }
}