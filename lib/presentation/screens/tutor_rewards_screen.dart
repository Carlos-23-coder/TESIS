import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/reward_model.dart';
import '../../data/repositories/reward_repository.dart';

class TutorRewardsScreen extends StatefulWidget {
  const TutorRewardsScreen({super.key});

  @override
  State<TutorRewardsScreen> createState() => _TutorRewardsScreenState();
}

class _TutorRewardsScreenState extends State<TutorRewardsScreen> {
  final RewardRepository _rewardRepository = RewardRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _starsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<RewardModel> _rewards = [];
  String category = "Comida";
  String? _currentTutorEmail;
  RewardModel? _editingReward;
  File? selectedImage;
  bool _isLoadingRewards = true;

  @override
  void initState() {
    super.initState();
    _loadTutorRewards();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _loadTutorRewards() async {
    final User? currentUser = _auth.currentUser;
    _currentTutorEmail = currentUser?.email;

    if (_currentTutorEmail == null) {
      if (!mounted) return;
      setState(() {
        _rewards = [];
        _isLoadingRewards = false;
      });
      return;
    }

    final rewards = await _rewardRepository.getRewardsByTutor(
      _currentTutorEmail!,
    );

    if (!mounted) return;

    setState(() {
      _rewards = rewards;
      _isLoadingRewards = false;
    });
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _startEditingReward(RewardModel reward) {
    setState(() {
      _editingReward = reward;
      _nameController.text = reward.name;
      _starsController.text = reward.requiredStars.toString();
      category = reward.category;

      final imageFile = File(reward.imagePath);
      selectedImage = imageFile.existsSync() ? imageFile : null;
    });
  }

  void _clearForm() {
    _nameController.clear();
    _starsController.clear();

    setState(() {
      selectedImage = null;
      category = "Comida";
      _editingReward = null;
    });
  }

  Future<void> saveReward() async {
    final tutorEmail = _currentTutorEmail;

    if (tutorEmail == null) {
      return;
    }

    final name = _nameController.text.trim();
    final stars = int.tryParse(_starsController.text.trim());

    if (name.isEmpty || stars == null) {
      return;
    }

    String imagePath =
    _editingReward?.imagePath ?? "";

      if (selectedImage != null) {

        final directory =
            await getApplicationDocumentsDirectory();

        final savedImage =
            await File(
              selectedImage!.path,
            ).copy(
          '${directory.path}/reward_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        imagePath = savedImage.path;
      }

    final reward = RewardModel(
      id: _editingReward?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      imagePath: imagePath,
      requiredStars: stars,
      tutorEmail: tutorEmail,
    );

    if (_editingReward == null) {
      await _rewardRepository.addReward(reward);
    } else {
      await _rewardRepository.updateReward(reward);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          _editingReward == null
              ? "🎉 Recompensa agregada"
              : "✅ Recompensa actualizada",
        ),
      ),
    );

    _clearForm();
    await _loadTutorRewards();
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildPreviewImage() {
    final String? imagePath = selectedImage?.path ?? _editingReward?.imagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.blueAccent,
          ),
          SizedBox(height: 15),
          Text("Agregar imagen"),
        ],
      );
    }

    final file = File(imagePath);

    if (!file.existsSync()) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.blueAccent,
          ),
          SizedBox(height: 15),
          Text("Imagen no disponible"),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      ),
    );
  }

  Widget _rewardThumbnail(RewardModel reward) {
    final file = File(reward.imagePath);

    if (reward.imagePath.isNotEmpty && file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          file,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.card_giftcard,
        color: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text("Recompensas"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTutorRewards,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_editingReward != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Editando recompensa creada por ti",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearForm,
                      child: const Text("Cancelar"),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: _buildPreviewImage(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Galería"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Cámara"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: inputStyle("Nombre recompensa"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: category,
              decoration: inputStyle("Categoría"),
              items: const [
                DropdownMenuItem(
                  value: "Comida",
                  child: Text("🍔 Comida"),
                ),
                DropdownMenuItem(
                  value: "Videojuego",
                  child: Text("🎮 Videojuego"),
                ),
                DropdownMenuItem(
                  value: "Juguete",
                  child: Text("🧸 Juguete"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  category = value ?? "Comida";
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _starsController,
              keyboardType: TextInputType.number,
              decoration: inputStyle("Estrellas necesarias"),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: saveReward,
                child: Text(
                  _editingReward == null
                      ? "Guardar recompensa"
                      : "Actualizar recompensa",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Mis recompensas creadas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingRewards)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_rewards.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "Todavía no has creado recompensas.",
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rewards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reward = _rewards[index];

                  return InkWell(
                    onTap: () => _startEditingReward(reward),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _rewardThumbnail(reward),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reward.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${reward.category} · ${reward.requiredStars} estrellas",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _startEditingReward(reward),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}