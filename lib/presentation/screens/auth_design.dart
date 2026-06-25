import 'package:flutter/material.dart';

class AuthPalette {
  static const Color ink = Color(0xFF123047);
  static const Color blue = Color(0xFF2F80ED);
  static const Color teal = Color(0xFF19B6A3);
  static const Color yellow = Color(0xFFFFD166);
  static const Color coral = Color(0xFFFF7A59);
  static const Color surface = Color(0xFFFFFEFA);
  static const Color field = Color(0xFFF4FBFF);
}

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF0F172A),
                    Color(0xFF111827),
                    Color(0xFF1E293B),
                  ]
                : const [
                    Color(0xFFEAF8FF),
                    Color(0xFFEAFBF6),
                    Color(0xFFFFF3CC),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthPanel extends StatelessWidget {
  final Widget child;

  const AuthPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : AuthPalette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : AuthPalette.blue.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthLogoHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthLogoHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AuthPalette.ink;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : AuthPalette.ink.withValues(alpha: 0.72);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AuthPalette.blue, width: 3),
              ),
              child: Image.asset(
                'assets/images/logo_uleam.png',
                fit: BoxFit.contain,
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AuthPalette.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 16,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

InputDecoration authInputDecoration(
  String label, {
  IconData? icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: AuthPalette.field,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: AuthPalette.blue.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AuthPalette.blue, width: 2),
    ),
  );
}

ButtonStyle primaryAuthButtonStyle({Color color = AuthPalette.blue}) {
  return ElevatedButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
  );
}
