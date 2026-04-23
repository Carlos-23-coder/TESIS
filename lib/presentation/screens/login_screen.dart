import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  String _role = "Usuario";
  bool _obscurePassword = true;

  void _login() async {

  if (!_formKey.currentState!.validate()) return;

  final user = await _userRepository.login(
    _usernameController.text.trim(),
    _passwordController.text.trim(),
    _role,
  );

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Datos incorrectos"),
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
          Text("¡Bienvenido!"),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 1), () {

    if (user.role == "Admin") {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/user');
    }

  });
}
  InputDecoration _inputDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6DD5FA),
              Color(0xFFBFF098)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const Icon(
                        Icons.menu_book_rounded,
                        size: 60,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Usuario
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(fontSize: 18),
                        decoration: _inputDecoration("Usuario"),
                        validator: (value) =>
                            value!.isEmpty ? "Ingrese su usuario" : null,
                      ),

                      const SizedBox(height: 20),

                      /// Tipo Usuario
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: _inputDecoration("Tipo de usuario"),
                        items: const [
                          DropdownMenuItem(
                              value: "Admin", child: Text("Admin")),
                          DropdownMenuItem(
                              value: "Usuario", child: Text("Usuario")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Contraseña con OJO
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 18),
                        decoration: _inputDecoration(
                          "Contraseña",
                          suffix: IconButton(
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
                        validator: (value) =>
                            value!.isEmpty ? "Ingrese su contraseña" : null,
                      ),

                      const SizedBox(height: 30),

                      /// BOTÓN GRANDE
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            "Ingresar",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/register');
                        },
                        child: const Text(
                          "¿No tienes cuenta? Regístrate",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
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