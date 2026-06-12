import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/firebase_service.dart';
import 'auth_design.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  final UserRepository _userRepository = UserRepository();
  final FirebaseService _firebaseService = FirebaseService();

  String _role = 'Alumno';
  bool _obscurePassword = true;
  bool _obscurePin = true;

  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasMinLength = false;

  bool get isPasswordValid => hasUpper && hasLower && hasNumber && hasMinLength;

  void _validatePassword(String password) {
    setState(() {
      hasUpper = password.contains(RegExp(r'[A-Z]'));
      hasLower = password.contains(RegExp(r'[a-z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasMinLength = password.length >= 8;
    });
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _pinController.clear();

    setState(() {
      hasUpper = false;
      hasLower = false;
      hasNumber = false;
      hasMinLength = false;
      _role = 'Alumno';
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isPasswordValid) {
      _showError('La contraseña no cumple los requisitos.');
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final emailExists = await _userRepository.emailExists(email);

    if (emailExists) {
      _showError('El correo ya está registrado.');
      return;
    }

    final appUser = User(
      username: _usernameController.text.trim(),
      email: email,
      password: _passwordController.text.trim(),
      pin: _pinController.text.trim(),
      role: _role,
    );

    try {
      await _userRepository.createUser(appUser);

      await _firebaseService.createUser(
        email: appUser.email,
        username: appUser.username,
        role: appUser.role,
        password: appUser.password,
        pin: appUser.pin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Registro completado'),
            ],
          ),
        ),
      );

      _clearForm();

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      _showError('Error al registrar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  Widget _buildRequirement(String text, bool condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: condition
            ? AuthPalette.teal.withValues(alpha: 0.13)
            : AuthPalette.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            condition ? Icons.check_circle : Icons.radio_button_unchecked,
            color: condition ? AuthPalette.teal : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AuthPalette.ink,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
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
                title: 'Crear cuenta',
                subtitle: 'Prepara tu perfil para aprender a tu ritmo.',
                icon: Icons.person_add_alt_1,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: authInputDecoration(
                  'Nombre',
                  icon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su nombre';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: authInputDecoration(
                  'Correo',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un correo';
                  }

                  if (!value.contains('@') || !value.contains('.com')) {
                    return 'Correo inválido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _validatePassword,
                decoration: authInputDecoration(
                  'Contraseña',
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
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRequirement('8 caracteres', hasMinLength),
                    _buildRequirement('Mayúscula', hasUpper),
                    _buildRequirement('Minúscula', hasLower),
                    _buildRequirement('Número', hasNumber),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                decoration: authInputDecoration(
                  'PIN (4 números)',
                  icon: Icons.pin_outlined,
                  suffix: IconButton(
                    tooltip: _obscurePin ? 'Mostrar' : 'Ocultar',
                    icon: Icon(
                      _obscurePin ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePin = !_obscurePin;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un PIN';
                  }

                  if (value.length != 4) {
                    return 'El PIN debe tener 4 números';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: primaryAuthButtonStyle(color: AuthPalette.teal),
                  onPressed: _register,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Registrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  '¿Ya tienes cuenta? Inicia sesión',
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
