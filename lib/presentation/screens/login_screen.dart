import 'package:flutter/material.dart';

import '../../data/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _formKey =
      GlobalKey<FormState>();

  /// 👤 CORREO O USUARIO
  final _userController =
      TextEditingController();

  /// 🔒 CONTRASEÑA O PIN
  final _passwordController =
      TextEditingController();

  final FirebaseService
      _firebaseService =
          FirebaseService();

  String _role = "Alumno";

  bool _obscurePassword = true;

  /// 🔐 LOGIN
  void _login() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final result =
        await _firebaseService.login(

      identifier:
          _userController.text.trim(),

      passwordOrPin:
          _passwordController.text.trim(),

      role: _role,
    );

    /// ❌ ERROR
    if (result == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
              Colors.red,

          content: Text(
            "Datos incorrectos",
          ),
        ),
      );

      return;
    }

    /// ✅ LOGIN EXITOSO
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

            Text("¡Bienvenido!"),
          ],
        ),
      ),
    );

    Future.delayed(
      const Duration(seconds: 1),
      () {

        if (_role == "Tutor") {

          Navigator
              .pushReplacementNamed(
            context,
            '/tutor',
          );

        } else {

          Navigator
              .pushReplacementNamed(
            context,
            '/alumno',
          );
        }
      },
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    Widget? suffix,
  }) {

    return InputDecoration(

      labelText: label,

      labelStyle:
          const TextStyle(
        fontSize: 16,
      ),

      filled: true,

      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 15,
      ),

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      suffixIcon: suffix,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      body: Container(

        decoration:
            const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xFF6DD5FA),
              Color(0xFFBFF098),
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
                const EdgeInsets.all(
              25,
            ),

            child: Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              elevation: 12,

              child: Padding(

                padding:
                    const EdgeInsets.all(
                  30,
                ),

                child: Form(

                  key: _formKey,

                  child: Column(

                    children: [

                      const Icon(

                        Icons
                            .menu_book_rounded,

                        size: 60,

                        color: Colors.blue,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(

                        "Iniciar Sesión",

                        style: TextStyle(

                          fontSize: 26,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      /// 👤 USUARIO O CORREO
                      TextFormField(

                        controller:
                            _userController,

                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),

                        decoration:
                            _inputDecoration(
                          "Correo o Usuario",
                        ),

                        validator:
                            (value) {

                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {

                            return
                                "Ingrese usuario o correo";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      /// 👤 TIPO
                      DropdownButtonFormField<
                          String>(

                        value: _role,

                        decoration:
                            _inputDecoration(
                          "Tipo de cuenta",
                        ),

                        items: const [

                          DropdownMenuItem(

                            value: "Tutor",

                            child:
                                Text(
                              "Tutor",
                            ),
                          ),

                          DropdownMenuItem(

                            value:
                                "Alumno",

                            child:
                                Text(
                              "Alumno",
                            ),
                          ),
                        ],

                        onChanged: (value) {

                          setState(() {

                            _role = value!;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      /// 🔒 PASSWORD O PIN
                      TextFormField(

                        controller:
                            _passwordController,

                        obscureText:
                            _obscurePassword,

                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),

                        decoration:
                            _inputDecoration(

                          "Contraseña o PIN",

                          suffix:
                              IconButton(

                            icon: Icon(

                              _obscurePassword
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                            ),

                            onPressed: () {

                              setState(() {

                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        validator:
                            (value) {

                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {

                            return
                                "Ingrese contraseña o PIN";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      /// 🔥 BOTÓN LOGIN
                      SizedBox(

                        width:
                            double.infinity,

                        height: 55,

                        child:
                            ElevatedButton(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors
                                    .blueAccent,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),

                          onPressed:
                              _login,

                          child:
                              const Text(

                            "Ingresar",

                            style:
                                TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      /// 🔗 REGISTRO
                      GestureDetector(

                        onTap: () {

                          Navigator
                              .pushReplacementNamed(
                            context,
                            '/register',
                          );
                        },

                        child: const Text(

                          "¿No tienes cuenta? Regístrate",

                          style: TextStyle(

                            color:
                                Colors.blue,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
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