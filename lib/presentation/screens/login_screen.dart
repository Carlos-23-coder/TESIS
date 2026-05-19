import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/user_repository.dart';

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

  /// 📧 CORREO
  final _emailController =
      TextEditingController();

  /// 🔒 CONTRASEÑA
  final _passwordController =
      TextEditingController();

  String _role = "Alumno";

  bool _obscurePassword = true;

  /// 🔥 LOGIN REAL CON FIREBASE AUTH
  void _login() async {

    if (!_formKey.currentState!
        .validate()) return;

    try {

      /// 🔥 LOGIN FIREBASE
      final credential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(

        email:
            _emailController.text
                .trim(),

        password:
            _passwordController.text
                .trim(),
      );

      final firebaseUser =
          credential.user;

      if (firebaseUser == null) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
                Colors.red,

            content: Text(
              "No se pudo iniciar sesión",
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

      /// ⏳ ESPERA
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

    } on FirebaseAuthException
        catch (e) {

      String message =
          "Error al iniciar sesión";

      if (e.code ==
          'user-not-found') {

        message =
            "El usuario no existe";

      } else if (
          e.code ==
              'wrong-password' ||
          e.code ==
              'invalid-credential') {

        message =
            "Contraseña incorrecta";

      } else if (
          e.code ==
          'invalid-email') {

        message =
            "Correo inválido";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
              Colors.red,

          content: Text(message),
        ),
      );
    }
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

                      /// 📧 CORREO
                      TextFormField(

                        controller:
                            _emailController,

                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),

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
                                "Ingrese su correo";
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

                      /// 🔒 PASSWORD
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

                          "Contraseña",

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
                                "Ingrese su contraseña";
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