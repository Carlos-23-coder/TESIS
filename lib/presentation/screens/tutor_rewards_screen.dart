import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/reward_model.dart';
import '../../data/repositories/reward_repository.dart';

class TutorRewardsScreen
    extends StatefulWidget {

  const TutorRewardsScreen({
    super.key,
  });

  @override
  State<TutorRewardsScreen>
      createState() =>
          _TutorRewardsScreenState();
}

class _TutorRewardsScreenState
    extends State<TutorRewardsScreen> {

  final RewardRepository
      _rewardRepository =
          RewardRepository();

  final _nameController =
      TextEditingController();

  final _starsController =
      TextEditingController();

  String category = "Comida";

  File? selectedImage;

  final ImagePicker _picker =
      ImagePicker();

  Future<void> pickImage() async {

    final XFile? image =
        await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        selectedImage =
            File(image.path);
      });
    }
  }

  Future<void> takePhoto() async {

    final XFile? image =
        await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {

      setState(() {

        selectedImage =
            File(image.path);
      });
    }
  }

  Future<void> saveReward() async {

    if (_nameController.text.isEmpty ||
        _starsController.text.isEmpty) {

      return;
    }

    final reward = RewardModel(

      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      name:
          _nameController.text.trim(),

      category: category,

      imagePath:
          selectedImage?.path ?? "",

      requiredStars:
          int.parse(
        _starsController.text,
      ),
    );

    await _rewardRepository
        .addReward(reward);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        backgroundColor:
            Colors.green,

        content: Text(
          "🎉 Recompensa agregada",
        ),
      ),
    );

    _nameController.clear();

    _starsController.clear();

    setState(() {

      selectedImage = null;

      category = "Comida";
    });
  }

  InputDecoration inputStyle(
    String label,
  ) {

    return InputDecoration(

      labelText: label,

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        borderSide: BorderSide.none,
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
          "Recompensas",
        ),

        backgroundColor:
            Colors.orange,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            /// 🖼️ IMAGEN
            GestureDetector(

              onTap: pickImage,

              child: Container(

                height: 220,

                width: double.infinity,

                decoration: BoxDecoration(

                  color:
                      Colors.orange.shade100,

                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),

                  boxShadow: const [

                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),

                child: selectedImage == null

                    ? const Column(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Icon(
                            Icons.card_giftcard,
                            size: 80,
                            color: Colors.orange,
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Text(
                            "Agregar imagen",
                          ),
                        ],
                      )

                    : ClipRRect(

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),

                        child: Image.file(

                          selectedImage!,

                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Row(

              children: [

                Expanded(

                  child:
                      ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.blueAccent,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),

                    onPressed:
                        pickImage,

                    icon: const Icon(
                      Icons.photo,
                    ),

                    label: const Text(
                      "Galería",
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child:
                      ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.orange,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),

                    onPressed:
                        takePhoto,

                    icon: const Icon(
                      Icons.camera_alt,
                    ),

                    label: const Text(
                      "Cámara",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            /// 📝 NOMBRE
            TextField(

              controller:
                  _nameController,

              decoration:
                  inputStyle(
                "Nombre recompensa",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /// 📂 CATEGORÍA
            DropdownButtonFormField<String>(

              value: category,

              decoration:
                  inputStyle(
                "Categoría",
              ),

              items: const [

                DropdownMenuItem(
                  value: "Comida",
                  child: Text(
                    "🍔 Comida",
                  ),
                ),

                DropdownMenuItem(
                  value: "Videojuego",
                  child: Text(
                    "🎮 Videojuego",
                  ),
                ),

                DropdownMenuItem(
                  value: "Juguete",
                  child: Text(
                    "🧸 Juguete",
                  ),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  category = value!;
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),

            /// ⭐ ESTRELLAS
            TextField(

              controller:
                  _starsController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  inputStyle(
                "Estrellas necesarias",
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.green,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                onPressed:
                    saveReward,

                child: const Text(

                  "Guardar recompensa",

                  style: TextStyle(
                    fontSize: 16,
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