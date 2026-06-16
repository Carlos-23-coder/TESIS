import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/story_image.dart';
import '../../data/models/story_override_model.dart';
import '../../data/repositories/story_repository.dart';

class StoryEditScreen extends StatefulWidget {
  final String tutorEmail;
  final String game;
  final int level;
  final bool isNewLevel;

  const StoryEditScreen({
    super.key,
    required this.tutorEmail,
    required this.game,
    required this.level,
    this.isNewLevel = false,
  });

  @override
  State<StoryEditScreen> createState() => _StoryEditScreenState();
}

class _StoryEditScreenState extends State<StoryEditScreen> {
  final StoryRepository _repository = StoryRepository();

  final ImagePicker _picker = ImagePicker();

  final titleController = TextEditingController();
  final storyController = TextEditingController();
  final questionController = TextEditingController();

  final List<TextEditingController> optionControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> questionControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<List<TextEditingController>> rapidOptionControllers =
      List.generate(5, (_) => List.generate(4, (_) => TextEditingController()));

  final List<int> rapidCorrectAnswers = List.generate(5, (_) => 0);

  File? selectedImage;
  String currentImagePath = '';
  int correctAnswer = 0;
  bool loading = true;
  bool hasDefault = false;

  bool get isIdeaPrincipal => widget.game == StoryGameType.ideaPrincipal;

  String get gameTitle =>
      isIdeaPrincipal ? 'Idea Principal' : 'Preguntas Rápidas';

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  Future<void> loadContent() async {
    final content = await _repository.getEditableContent(
      tutorEmail: widget.tutorEmail,
      game: widget.game,
      level: widget.level,
    );

    hasDefault = _repository.hasDefaultLevel(widget.game, widget.level);

    if (content != null) {
      titleController.text = content.title;
      storyController.text = content.story;
      currentImagePath = content.imagePath.isNotEmpty
          ? content.imagePath
          : content.imageUrl;

      if (isIdeaPrincipal) {
        questionController.text = content.question;

        for (int i = 0; i < optionControllers.length; i++) {
          if (i < content.options.length) {
            optionControllers[i].text = content.options[i];
          }
        }

        correctAnswer = content.correctAnswer;
      } else {
        for (int i = 0; i < content.questions.length && i < 5; i++) {
          questionControllers[i].text = content.questions[i]['question'] ?? '';

          final options = List<String>.from(
            content.questions[i]['options'] ?? [],
          );

          for (int j = 0; j < 4; j++) {
            if (j < options.length) {
              rapidOptionControllers[i][j].text = options[j];
            }
          }

          rapidCorrectAnswers[i] = content.questions[i]['correctAnswer'] ?? 0;
        }
      }
    } else if (widget.isNewLevel) {
      titleController.text = 'Nivel ${widget.level}';
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> save() async {
    if (storyController.text.trim().isEmpty) {
      _showMessage('La historia no puede estar vacía.');
      return;
    }

    if (isIdeaPrincipal) {
      if (questionController.text.trim().isEmpty) {
        _showMessage('Agrega la pregunta principal.');
        return;
      }

      for (final controller in optionControllers) {
        if (controller.text.trim().isEmpty) {
          _showMessage('Completa todas las opciones.');
          return;
        }
      }
    } else {
      if (titleController.text.trim().isEmpty) {
        _showMessage('Agrega un título.');
        return;
      }

      for (int i = 0; i < 5; i++) {
        final text = questionControllers[i].text.trim();

        if (text.isEmpty) {
          continue;
        }

        for (final controller in rapidOptionControllers[i]) {
          if (controller.text.trim().isEmpty) {
            _showMessage('Completa las 4 opciones de cada pregunta.');
            return;
          }
        }
      }

      final hasQuestion = questionControllers.any(
        (controller) => controller.text.trim().isNotEmpty,
      );

      if (!hasQuestion) {
        _showMessage('Agrega al menos una pregunta.');
        return;
      }
    }

    final override = StoryOverrideModel(
      id: StoryOverrideModel.buildId(
        widget.tutorEmail,
        widget.game,
        widget.level,
      ),
      tutorEmail: widget.tutorEmail,
      game: widget.game,
      level: widget.level,
      title: isIdeaPrincipal
          ? (titleController.text.trim().isEmpty
                ? 'Nivel ${widget.level}'
                : titleController.text.trim())
          : titleController.text.trim(),
      story: storyController.text.trim(),
      imagePath: currentImagePath,
      question: questionController.text.trim(),
      options: optionControllers
          .map((controller) => controller.text.trim())
          .toList(),
      correctAnswer: correctAnswer,
      questions: _buildRapidQuestions(),
      isNewLevel:
          widget.isNewLevel ||
          !_repository.hasDefaultLevel(widget.game, widget.level),
      date: DateTime.now().toIso8601String(),
    );

    await _repository.saveOverride(override: override, newImage: selectedImage);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  List<Map<String, dynamic>> _buildRapidQuestions() {
    final questions = <Map<String, dynamic>>[];

    for (int i = 0; i < 5; i++) {
      final text = questionControllers[i].text.trim();

      if (text.isEmpty) continue;

      questions.add({
        'question': text,
        'options': rapidOptionControllers[i]
            .map((controller) => controller.text.trim())
            .toList(),
        'correctAnswer': rapidCorrectAnswers[i],
      });
    }

    return questions;
  }

  Future<void> restoreDefault() async {
    if (!hasDefault) {
      await _repository.deleteLevel(
        tutorEmail: widget.tutorEmail,
        game: widget.game,
        level: widget.level,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar original'),
        content: const Text(
          '¿Quieres volver al contenido predeterminado de este nivel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repository.restoreDefault(
      tutorEmail: widget.tutorEmail,
      game: widget.game,
      level: widget.level,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  Future<void> deleteLevel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nivel'),
        content: const Text('¿Seguro que quieres eliminar este nivel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repository.deleteLevel(
      tutorEmail: widget.tutorEmail,
      game: widget.game,
      level: widget.level,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildIdeaPrincipalFields() {
    return Column(
      children: [
        _textField(controller: titleController, label: 'Título (opcional)'),
        const SizedBox(height: 16),
        _textField(controller: storyController, label: 'Historia', maxLines: 8),
        const SizedBox(height: 16),
        _textField(controller: questionController, label: 'Pregunta principal'),
        const SizedBox(height: 16),
        for (int i = 0; i < optionControllers.length; i++) ...[
          _textField(
            controller: optionControllers[i],
            label: 'Opción ${i + 1}',
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<int>(
          value: correctAnswer,
          decoration: InputDecoration(
            labelText: 'Respuesta correcta',
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1F2937)
                : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: List.generate(
            3,
            (index) => DropdownMenuItem(
              value: index,
              child: Text('Opción ${index + 1}'),
            ),
          ),
          onChanged: (value) {
            setState(() {
              correctAnswer = value ?? 0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRapidQuestion(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          _textField(controller: questionControllers[index], label: 'Pregunta'),
          const SizedBox(height: 12),
          for (int i = 0; i < 4; i++) ...[
            _textField(
              controller: rapidOptionControllers[index][i],
              label: 'Opción ${i + 1}',
            ),
            const SizedBox(height: 8),
          ],
          DropdownButtonFormField<int>(
            value: rapidCorrectAnswers[index],
            decoration: InputDecoration(
              labelText: 'Respuesta correcta',
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1F2937)
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: List.generate(
              4,
              (optionIndex) => DropdownMenuItem(
                value: optionIndex,
                child: Text('Opción ${optionIndex + 1}'),
              ),
            ),
            onChanged: (value) {
              setState(() {
                rapidCorrectAnswers[index] = value ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text('$gameTitle · Nivel ${widget.level}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!isIdeaPrincipal)
                    _textField(controller: titleController, label: 'Título'),
                  if (!isIdeaPrincipal) const SizedBox(height: 16),
                  if (isIdeaPrincipal) _buildIdeaPrincipalFields(),
                  if (!isIdeaPrincipal) ...[
                    _textField(
                      controller: storyController,
                      label: 'Historia',
                      maxLines: 8,
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < 5; i++) _buildRapidQuestion(i),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Cambiar imagen'),
                  ),
                  const SizedBox(height: 12),
                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        selectedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (currentImagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: StoryImage(
                        imagePath: currentImagePath,
                        height: 180,
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: save,
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (hasDefault) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: restoreDefault,
                        child: const Text('Restaurar original'),
                      ),
                    ),
                  ],
                  if (widget.isNewLevel || !hasDefault) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: deleteLevel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Eliminar nivel'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    storyController.dispose();
    questionController.dispose();

    for (final controller in optionControllers) {
      controller.dispose();
    }

    for (final controller in questionControllers) {
      controller.dispose();
    }

    for (final list in rapidOptionControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }

    super.dispose();
  }
}
