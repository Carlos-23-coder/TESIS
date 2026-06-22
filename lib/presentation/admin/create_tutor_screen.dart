import 'package:flutter/material.dart';

import '../../data/models/user_model.dart' as app_user;
import '../../data/repositories/user_repository.dart';
import '../../data/services/firebase_service.dart';
import '../screens/auth_design.dart';

class CreateTutorScreen extends StatefulWidget {
  const CreateTutorScreen({super.key});

  @override
  State<CreateTutorScreen> createState() => _CreateTutorScreenState();
}

class _CreateTutorScreenState extends State<CreateTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  final UserRepository _userRepository = UserRepository();
  final FirebaseService _firebaseService = FirebaseService();

  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _saving = false;

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

  Future<void> _createTutor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isPasswordValid) {
      _showError('La contrasena no cumple los requisitos.');
      return;
    }

    setState(() {
      _saving = true;
    });

    final email = _emailController.text.trim().toLowerCase();

    try {
      final exists = await _userRepository.emailExists(email);

      if (exists) {
        _showError('El correo ya esta registrado localmente.');
        return;
      }

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final pin = _pinController.text.trim();

      await _firebaseService.createTutorByAdmin(
        email: email,
        username: username,
        password: password,
        pin: pin,
      );

      await _userRepository.createUserFromAdmin(
        app_user.User(
          username: username,
          email: email,
          password: password,
          pin: pin,
          role: 'Tutor',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Tutor creado correctamente'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo crear el tutor: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
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
                title: 'Crear tutor',
                subtitle: 'Registra una cuenta de tutor para LectoPlay.',
                icon: Icons.supervisor_account,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: authInputDecoration(
                  'Nombre del tutor',
                  icon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre del tutor';
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un correo';
                  }

                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Correo invalido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _validatePassword,
                decoration: authInputDecoration(
                  'Contrasena',
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
                    _buildRequirement('Mayuscula', hasUpper),
                    _buildRequirement('Minuscula', hasLower),
                    _buildRequirement('Numero', hasNumber),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                decoration: authInputDecoration(
                  'PIN (4 numeros)',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un PIN';
                  }

                  if (value.trim().length != 4) {
                    return 'El PIN debe tener 4 numeros';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: primaryAuthButtonStyle(color: AuthPalette.teal),
                  onPressed: _saving ? null : _createTutor,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(_saving ? 'Creando...' : 'Crear tutor'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _saving ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
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
