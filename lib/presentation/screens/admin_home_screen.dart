import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
        title: const Text("Panel Administrador"),
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

          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.camera_alt, size: 40),
          ),

          const SizedBox(height: 30),

          _adminButton(context, "Premios"),
          _adminButton(context, "Mi Grupo"),
          _adminButton(context, "Mi Perfil"),
        ],
      ),
    );
  }

  Widget _adminButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}