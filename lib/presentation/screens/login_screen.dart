import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/services/firebase_service.dart';
import 'auth_design.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  String _role = 'Alumno';
  bool _obscurePassword = true;

  void _login() async {
    await FirebaseAuth.instance.signOut();

    debugPrint(
      'Firebase despues de signOut: '
      '${FirebaseAuth.instance.currentUser?.email}',
    );

    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint(
      'Firebase antes del login: '
      '${FirebaseAuth.instance.currentUser?.email}',
    );

    final result = await _firebaseService.login(
      identifier: _userController.text.trim(),
      passwordOrPin: _passwordController.text.trim(),
      role: _role,
    );

    debugPrint(
      'Firebase despues del login: '
      '${FirebaseAuth.instance.currentUser?.email}',
    );

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Datos incorrectos'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('¡Bienvenido!'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (_role == 'Tutor') {
        Navigator.pushReplacementNamed(context, '/tutor');
      } else {
        Navigator.pushReplacementNamed(context, '/alumno');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPanel(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthLogoHeader(
                title: 'Iniciar sesión',
                subtitle: 'Entra con calma y continúa tu aventura lectora.',
                icon: Icons.login,
              ),
              const SizedBox(height: 26),
              TextFormField(
                controller: _userController,
                style: const TextStyle(fontSize: 17),
                decoration: authInputDecoration(
                  'Correo o usuario',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese usuario o correo';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: authInputDecoration(
                  'Tipo de cuenta',
                  icon: Icons.school_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: 'Tutor', child: Text('Tutor')),
                  DropdownMenuItem(value: 'Alumno', child: Text('Alumno')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 17),
                decoration: authInputDecoration(
                  'Contraseña o PIN',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese contraseña o PIN';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: primaryAuthButtonStyle(),
                  onPressed: _login,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ingresar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(
                    color: AuthPalette.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
