import 'package:flutter/material.dart';

import 'auth_design.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthLogoHeader(
            title: 'LectoPlay',
            subtitle: 'Lectura, retos y recompensas en un espacio tranquilo.',
            icon: Icons.auto_stories,
          ),
          const SizedBox(height: 28),
          AuthPanel(
            child: Column(
              children: [
                const Text(
                  'Elige cómo quieres empezar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AuthPalette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: primaryAuthButtonStyle(),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AuthPalette.blue,
                      side: const BorderSide(color: AuthPalette.blue, width: 2),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Crear cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
