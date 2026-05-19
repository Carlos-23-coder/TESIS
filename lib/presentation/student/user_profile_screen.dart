import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class UserProfileScreen extends StatefulWidget {

  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {

  final TextEditingController
      _nameController =
          TextEditingController();

  final TextEditingController
      _emailController =
          TextEditingController();

  final StudentRepository
      _studentRepository =
          StudentRepository();

  File? _image;

  bool loading = false;

  /// 📸 SELECCIONAR IMAGEN
  Future<void> pickImage(
    ImageSource source,
  ) async {

    final picked =
        await ImagePicker().pickImage(
      source: source,
    );

    if (picked != null) {

      setState(() {
        _image = File(picked.path);
      });
    }
  }

  /// ☁️ SUBIR IMAGEN
  Future<String> uploadImage() async {

    if (_image == null) return "";

    final ref = FirebaseStorage.instance
        .ref()
        .child(
          "students/${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

    await ref.putFile(_image!);

    return await ref.getDownloadURL();
  }

  /// 💾 GUARDAR PERFIL
  Future<void> saveProfile() async {

    setState(() {
      loading = true;
    });

    final imageUrl =
        await uploadImage();

    final student = StudentModel(
      id: "alumno_1",
      name: _nameController.text,
      email: _emailController.text,
      imageUrl: imageUrl,
      totalStars: 0,
    );

    await _studentRepository
        .saveStudent(student);

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "✅ Perfil guardado",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            /// 👤 FOTO
            Stack(

              children: [

                CircleAvatar(

                  radius: 70,

                  backgroundColor:
                      Colors.white,

                  backgroundImage:
                      _image != null
                          ? FileImage(_image!)
                          : null,

                  child: _image == null
                      ? const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.blue,
                        )
                      : null,
                ),

                Positioned(

                  bottom: 0,
                  right: 0,

                  child: Container(

                    decoration:
                        const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),

                    child: PopupMenuButton(

                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),

                      itemBuilder: (_) => [

                        PopupMenuItem(
                          child: const Text(
                            "Tomar foto",
                          ),
                          onTap: () {
                            pickImage(
                              ImageSource.camera,
                            );
                          },
                        ),

                        PopupMenuItem(
                          child: const Text(
                            "Galería",
                          ),
                          onTap: () {
                            pickImage(
                              ImageSource.gallery,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 👦 NOMBRE
            TextField(

              controller:
                  _nameController,

              decoration:
                  InputDecoration(

                labelText:
                    "Nombre del alumno",

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📧 EMAIL
            TextField(

              controller:
                  _emailController,

              decoration:
                  InputDecoration(

                labelText: "Correo",

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 💾 BOTÓN
            SizedBox(

              width: double.infinity,
              height: 60,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.orange,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                onPressed:
                    loading
                        ? null
                        : saveProfile,

                child: loading

                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : const Text(

                        "Guardar Perfil",

                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}