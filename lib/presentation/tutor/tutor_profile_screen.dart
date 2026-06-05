import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/repositories/tutor_repository.dart';

class TutorProfileScreen
    extends StatefulWidget {

  const TutorProfileScreen({
    super.key,
  });

  @override
  State<TutorProfileScreen>
      createState() =>
          _TutorProfileScreenState();
}

class _TutorProfileScreenState
    extends State<TutorProfileScreen> {

  final TutorRepository
      _repository =
          TutorRepository();

  /// 🔥 USUARIO ACTUAL
  final user =
      FirebaseAuth
          .instance
          .currentUser;

  File? _image;

  String tutorName = "Tutor";

  String email = "Sin correo";

  int totalStudents = 0;

  @override
  void initState() {

    super.initState();

    loadProfile();
    loadStudents();
  }

  /// 👤 CARGAR PERFIL
  Future<void> loadProfile() async {

    if (user == null) return;

    final data =
        await _repository
            .getProfile(
      user!.email!,
    );

    /// 🔥 SI NO EXISTE EN FIREBASE
    /// USA DATOS DEL AUTH
    if (data == null) {

      setState(() {

        tutorName =
            user!.displayName ??
            "Tutor";

        email =
            user!.email ??
            "Sin correo";
      });

      return;
    }

    tutorName =
        data["username"] ??
        "Tutor";

    email =
        data["email"] ??
        "Sin correo";

    final photoPath =
        data["photoUrl"] ?? "";

    if (photoPath.isNotEmpty) {

      final file =
          File(photoPath);

      if (await file.exists()) {

        _image = file;
      }
    }

    if (mounted) {

      setState(() {});
    }
  }

  /// 👨‍🎓 CARGAR NÚMERO DE ALUMNOS
  Future<void> loadStudents() async {

    final count =
        await _repository
            .getStudentsCount();

    if (mounted) {

      setState(() {

        totalStudents =
            count;
      });
    }
  }

  /// 📷 CAMBIAR FOTO
  Future<void> pickImage(
    ImageSource source,
  ) async {

    if (user == null) return;

    final picked =
        await ImagePicker()
            .pickImage(
      source: source,
    );

    if (picked == null) return;

    final directory =
        await getApplicationDocumentsDirectory();

    final savedImage =
        await File(
          picked.path,
          ).copy(
          '${directory.path}/${user!.email}.jpg',
        );

    /// 💾 GUARDAR RUTA LOCAL
    await _repository
        .savePhotoUrl(
      user!.email!,
      savedImage.path,
    );

    setState(() {

      _image = savedImage;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(

      const SnackBar(

        backgroundColor:
            Colors.green,

        content: Text(
          "✅ Foto actualizada",
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFEAF6FF,
      ),

      appBar: AppBar(

        title: const Text(
          "Mi Perfil",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            const SizedBox(
              height: 20,
            ),

            /// 📷 FOTO PERFIL
            GestureDetector(

              onTap: () async {

                showModalBottomSheet(

                  context: context,

                  builder: (_) {

                    return SafeArea(

                      child: Wrap(

                        children: [

                          /// 📸 CÁMARA
                          ListTile(

                            leading:
                                const Icon(
                              Icons.camera_alt,
                            ),

                            title:
                                const Text(
                              "Tomar foto",
                            ),

                            onTap: () {

                              Navigator.pop(
                                context,
                              );

                              pickImage(
                                ImageSource.camera,
                              );
                            },
                          ),

                          /// 🖼️ GALERÍA
                          ListTile(

                            leading:
                                const Icon(
                              Icons.photo,
                            ),

                            title:
                                const Text(
                              "Abrir galería",
                            ),

                            onTap: () {

                              Navigator.pop(
                                context,
                              );

                              pickImage(
                                ImageSource.gallery,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },

              child: CircleAvatar(

                radius: 70,

                backgroundColor:
                    Colors.white,

                backgroundImage:
                    _image != null
                        ? FileImage(
                            _image!,
                          )
                        : null,

                child:
                    _image == null

                        ? const Icon(
                            Icons.person,
                            size: 70,
                            color:
                                Colors.blue,
                          )

                        : null,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(

              "Toca la foto para cambiarla",

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// 👤 NOMBRE
            Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: ListTile(

                leading: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),

                title: const Text(
                  "Nombre",
                ),

                subtitle:
                    Text(
                  tutorName,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            /// 📧 CORREO
            Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: ListTile(

                leading: const Icon(
                  Icons.email,
                  color: Colors.orange,
                ),

                title: const Text(
                  "Correo",
                ),

                subtitle:
                    Text(
                  email,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            /// 👨‍🎓 ALUMNOS
            Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: ListTile(

                leading: const Icon(
                  Icons.people,
                  color: Colors.green,
                ),

                title: const Text(
                  "Número de alumnos",
                ),

                subtitle: Text(
                  "$totalStudents alumnos",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}