import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:path_provider/path_provider.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';

class StudentProfileScreen
    extends StatefulWidget {

  const StudentProfileScreen({
    super.key,
  });

  @override
  State<StudentProfileScreen>
      createState() =>
          _StudentProfileScreenState();
}

class _StudentProfileScreenState
    extends State<StudentProfileScreen> {

  final ProfileRepository
      _profileRepository =
          ProfileRepository();

  final ProgressRepository
      _progressRepository =
          ProgressRepository();

  String studentName = "Alumno";
  String email = "Sin correo";

  String? photoUrl;

  File? localImage;

  int totalStars = 0;

  final user =
      FirebaseAuth.instance.currentUser;

  @override
  void initState() {

    super.initState();

    loadProfile();
    loadStars();
    loadLocalImage();
  }

  /// ⭐ CARGAR ESTRELLAS
  Future<void> loadStars() async {

    if (user == null) return;

    final stars = await _progressRepository.getTotalStars(
      user!.email!,
    );

    setState(() {
      totalStars = stars;
    });
  }

  /// 👤 CARGAR PERFIL
  Future<void> loadProfile() async {

    if (user == null) return;

    print("========== PERFIL ALUMNO ==========");
    print("FirebaseAuth email: ${user!.email}");
    print("FirebaseAuth uid: ${user!.uid}");


    final data =
        await _profileRepository
            .getProfile(
      user!.email!,
    );

    if (data != null) {

      setState(() {

        studentName =
            data["username"] ??
            "Alumno";

        email =
            data["email"] ??
            "Sin correo";

        photoUrl =
            data["photoUrl"];
      });
    }
  }

  /// 📂 CARGAR IMAGEN LOCAL
  Future<void> loadLocalImage() async {

    if (user == null) return;

    final directory =
        await getApplicationDocumentsDirectory();

    final imagePath =
        '${directory.path}/${user!.email}.jpg';

    final file =
        File(imagePath);

    if (await file.exists()) {

      setState(() {
        localImage = file;
      });
    }
  }

  /// 📷 CAMBIAR FOTO
  Future<void> changePhoto() async {

    if (user == null) return;

    final ImagePicker picker =
        ImagePicker();

    final XFile? image =
        await showModalBottomSheet<XFile>(

      context: this.context,

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

                title: const Text(
                  "Tomar Foto",
                ),

                onTap: () async {

                  final photo =
                      await picker.pickImage(
                    source:
                        ImageSource.camera,
                    imageQuality: 70,
                  );

                  Navigator.pop(
                    this.context,
                    photo,
                  );
                },
              ),

              /// 🖼️ GALERÍA
              ListTile(

                leading:
                    const Icon(
                  Icons.photo,
                ),

                title: const Text(
                  "Abrir Galería",
                ),

                onTap: () async {

                  final photo =
                      await picker.pickImage(
                    source:
                        ImageSource.gallery,
                    imageQuality: 70,
                  );

                  Navigator.pop(
                    this.context,
                    photo,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (image == null) return;

    /// ✅ GUARDAR LOCALMENTE
    final directory =
        await getApplicationDocumentsDirectory();

    final savedImage =
        await File(image.path).copy(
      '${directory.path}/${user!.email}.jpg',
    );

    setState(() {
      localImage = savedImage;
    });

      await _profileRepository
          .savePhotoUrl(
        user!.email!,
        savedImage.path,
      );

    setState(() {
      localImage = savedImage;
      photoUrl = savedImage.path;
    });
    if (!mounted) return;

    ScaffoldMessenger.of(this.context)
        .showSnackBar(
   
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
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(

        title: const Text(
          "Mi Perfil",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(
              height: 20,
            ),

            /// 📷 FOTO PERFIL
            GestureDetector(

              onTap: changePhoto,

              child: CircleAvatar(

                radius: 70,

                backgroundColor:
                    Colors.white,

                backgroundImage:

                    localImage != null

                        ? FileImage(localImage!)

                        : photoUrl != null

                            ? NetworkImage(
                                photoUrl!,
                              )

                            : null,

                child:

                    localImage == null &&
                            photoUrl == null

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
                fontSize: 14,
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
                    Text(studentName),
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
                    Text(email),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            /// ⭐ ESTRELLAS
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
                  Icons.star,
                  color: Colors.amber,
                ),

                title: const Text(
                  "Estrellas Totales",
                ),

                subtitle: Text(
                  "$totalStars ⭐",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}