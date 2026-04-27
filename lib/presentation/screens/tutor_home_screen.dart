import 'package:flutter/material.dart';

class TutorHomeScreen extends StatelessWidget {
  const TutorHomeScreen({super.key});

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Panel del Tutor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [

          const SizedBox(height: 30),

          /// FOTO DE PERFIL
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.camera_alt, size: 40),
          ),

          const SizedBox(height: 30),

          /// BOTONES
          _tutorButton(context, "Premios"),
          _tutorButton(context, "Mi grupo"),
          _tutorButton(context, "Mi perfil"),
        ],
      ),
    );
  }

  /// BOTÓN REUTILIZABLE
  Widget _tutorButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            // Luego conectamos navegación real
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}