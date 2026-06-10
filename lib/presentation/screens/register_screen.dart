import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _usernameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  /// 🔥 NUEVO PIN
  final _pinController =
      TextEditingController();

  final UserRepository
      _userRepository =
          UserRepository();

  final FirebaseService
      _firebaseService =
          FirebaseService();

  String _role = "Alumno";

  bool _obscurePassword = true;
  bool _obscurePin = true;

  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasMinLength = false;

  /// VALIDAR PASSWORD
  void _validatePassword(
    String password,
  ) {

    setState(() {

      hasUpper =
          password.contains(
        RegExp(r'[A-Z]'),
      );

      hasLower =
          password.contains(
        RegExp(r'[a-z]'),
      );

      hasNumber =
          password.contains(
        RegExp(r'[0-9]'),
      );

      hasMinLength =
          password.length >= 8;
    });
  }

  bool get isPasswordValid =>

      hasUpper &&
      hasLower &&
      hasNumber &&
      hasMinLength;

  /// LIMPIAR
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

      _role = "Alumno";
    });
  }

  /// REGISTRO
  void _register() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (!isPasswordValid) {

      _showError(
        "La contraseña no cumple los requisitos.",
      );

      return;
    }

    final email =
        _emailController.text.trim().toLowerCase();

    final emailExists =
        await _userRepository
            .emailExists(email);

    if (emailExists) {

      _showError(
        "El correo ya está registrado.",
      );

      return;
    }

    final appUser = User(

      username:
          _usernameController.text.trim(),

      email: email,

      password:
          _passwordController.text.trim(),

      pin:
          _pinController.text.trim(),

      role: _role,
    );

    try {

      /// SQLITE
      await _userRepository
          .createUser(appUser);

      /// FIREBASE
      await _firebaseService
          .createUser(

        email: appUser.email,

        username:
            appUser.username,

        role: appUser.role,

        password:
            appUser.password,

        pin:
            appUser.pin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
              Colors.green,

          content: Row(

            children: [

              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),

              SizedBox(width: 10),

              Text(
                "Registro completado",
              ),
            ],
          ),
        ),
      );

      _clearForm();

      Future.delayed(

        const Duration(seconds: 1),

        () {

          Navigator
              .pushReplacementNamed(
            context,
            '/login',
          );
        },
      );

    } catch (e) {

      _showError(
        "Error al registrar: $e",
      );
    }
  }

  /// ERROR
  void _showError(
    String message,
  ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        backgroundColor:
            Colors.red,

        content:
            Text(message),
      ),
    );
  }

  Widget _buildRequirement(
    String text,
    bool condition,
  ) {

    return Row(

      children: [

        Icon(

          condition
              ? Icons.check_circle
              : Icons
                  .radio_button_unchecked,

          color:
              condition
                  ? Colors.green
                  : Colors.grey,

          size: 18,
        ),

        const SizedBox(width: 8),

        Text(text),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    Widget? suffix,
  }) {

    return InputDecoration(

      labelText: label,

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(15),
      ),

      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration:
            const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xFF4A90E2),
              Color(0xFF50C9C3),
            ],

            begin:
                Alignment.topCenter,

            end:
                Alignment.bottomCenter,
          ),
        ),

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(20),

            child: Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(25),
              ),

              elevation: 10,

              child: Padding(

                padding:
                    const EdgeInsets.all(25),

                child: Form(

                  key: _formKey,

                  child: Column(

                    children: [

                      const Text(

                        "Crear Cuenta",

                        style: TextStyle(

                          fontSize: 24,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      /// NOMBRE
                      TextFormField(

                        controller:
                            _usernameController,

                        decoration:
                            _inputDecoration(
                          "Nombre",
                        ),

                        validator: (v) {

                          if (v == null ||
                              v.isEmpty) {

                            return
                                "Ingrese su nombre";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      /// EMAIL
                      TextFormField(

                        controller:
                            _emailController,

                        decoration:
                            _inputDecoration(
                          "Correo",
                        ),

                        validator:
                            (value) {

                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {

                            return
                                "Ingrese un correo";
                          }

                          if (!value
                                  .contains("@") ||
                              !value
                                  .contains(".com")) {

                            return
                                "Correo inválido";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      /// ROL
                      DropdownButtonFormField<String>(

                        value: _role,

                        decoration:
                            _inputDecoration(
                          "Tipo de cuenta",
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "Tutor",
                            child: Text("Tutor"),
                          ),

                          DropdownMenuItem(
                            value: "Alumno",
                            child: Text("Alumno"),
                          ),
                        ],

                        onChanged: (value) {

                          setState(() {

                            _role = value!;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      /// PASSWORD
                      TextFormField(

                        controller:
                            _passwordController,

                        obscureText:
                            _obscurePassword,

                        onChanged:
                            _validatePassword,

                        decoration:
                            _inputDecoration(

                          "Contraseña",

                          suffix: IconButton(

                            icon: Icon(

                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),

                            onPressed: () {

                              setState(() {

                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _buildRequirement(
                        "Mínimo 8 caracteres",
                        hasMinLength,
                      ),

                      _buildRequirement(
                        "Una mayúscula",
                        hasUpper,
                      ),

                      _buildRequirement(
                        "Una minúscula",
                        hasLower,
                      ),

                      _buildRequirement(
                        "Un número",
                        hasNumber,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      /// 🔥 PIN
                      TextFormField(

                        controller:
                            _pinController,

                        obscureText:
                            _obscurePin,

                        keyboardType:
                            TextInputType.number,

                        decoration:
                            _inputDecoration(

                          "PIN (4 números)",

                          suffix: IconButton(

                            icon: Icon(

                              _obscurePin
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),

                            onPressed: () {

                              setState(() {

                                _obscurePin =
                                    !_obscurePin;
                              });
                            },
                          ),
                        ),

                        validator: (value) {

                          if (value == null ||
                              value.isEmpty) {

                            return
                                "Ingrese un PIN";
                          }

                          if (value.length != 4) {

                            return
                                "El PIN debe tener 4 números";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      /// BOTÓN
                      SizedBox(

                        width:
                            double.infinity,

                        child:
                            ElevatedButton(

                          onPressed:
                              _register,

                          child:
                              const Text(
                            "Registrar",
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      /// LOGIN
                      GestureDetector(

                        onTap: () {

                          Navigator
                              .pushReplacementNamed(
                            context,
                            '/login',
                          );
                        },

                        child: const Text(

                          "¿Ya tienes cuenta? Inicia sesión",

                          style: TextStyle(

                            color: Colors.blue,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}