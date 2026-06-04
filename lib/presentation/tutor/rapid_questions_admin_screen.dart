import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/rapid_question_model.dart';
import '../../data/repositories/rapid_questions_repository.dart';

class RapidQuestionsAdminScreen extends StatefulWidget {
  const RapidQuestionsAdminScreen({
    super.key,
  });

  @override
  State<RapidQuestionsAdminScreen> createState() =>
      _RapidQuestionsAdminScreenState();
}

class _RapidQuestionsAdminScreenState
    extends State<RapidQuestionsAdminScreen> {

  String imageUrl = "";

  final RapidQuestionsRepository
      _repository =
          RapidQuestionsRepository();

  File? selectedImage;

  final ImagePicker _picker =
      ImagePicker();

  List<RapidQuestionModel>
      levels = [];

  bool isEditing = false;

  final TextEditingController
      levelController =
          TextEditingController();

  final TextEditingController
      titleController =
          TextEditingController();

  final TextEditingController
      storyController =
          TextEditingController();

  List<TextEditingController>
      questionControllers =
          List.generate(
    5,
    (_) => TextEditingController(),
  );

  List<List<TextEditingController>>
      optionControllers =
          List.generate(
    5,
    (_) => List.generate(
      4,
      (_) => TextEditingController(),
    ),
  );

  List<int> correctAnswers =
      List.generate(
    5,
    (_) => 0,
  );

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> pickImage() async {
    
    final XFile? image =
        await _picker.pickImage(
      source:
          ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      selectedImage =
          File(image.path);
    });
  }

  Future<void> loadLevels() async {

    levels =
        await _repository
            .getAllLevels();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> saveLevel() async {

    if (levelController.text
            .isEmpty ||
        titleController.text
            .isEmpty ||
        storyController.text
            .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          backgroundColor:
              Colors.red,
          content: Text(
            "Complete todos los campos",
          ),
        ),
      );

      return;
    }

    final int levelNumber =
        int.parse(
      levelController.text,
    );

    final existingLevel =
        await _repository
            .getLevel(
      levelNumber,
    );

    if (existingLevel !=
            null &&
        !isEditing) {

      final confirm =
          await showDialog<bool>(

        context: context,

        builder: (context) {

          return AlertDialog(

            title: const Text(
              "Nivel existente",
            ),

            content:
                const Text(
              "Ya existe una historia para este nivel.\n\n¿Desea modificarla?",
            ),

            actions: [

              TextButton(
                onPressed: () {

                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child:
                    const Text(
                  "Cancelar",
                ),
              ),

              ElevatedButton(
                onPressed: () {

                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child:
                    const Text(
                  "Modificar",
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return;
      }

      isEditing = true;
    }

    String uploadedImageUrl =
        imageUrl;

    if (selectedImage !=
        null) {

      uploadedImageUrl =
          await _repository
              .uploadImage(
        levelNumber,
        selectedImage!,
      );
    }

    List<Map<String, dynamic>>
        questions = [];

    for (
      int i = 0;
      i < 5;
      i++
      ) {

      questions.add({

        "question":
            questionControllers[
                    i]
                .text,

        "options": [

          optionControllers[
                  i][0]
              .text,

          optionControllers[
                  i][1]
              .text,

          optionControllers[
                  i][2]
              .text,

          optionControllers[
                  i][3]
              .text,
        ],

        "correctAnswer":
            correctAnswers[
                i],
      });
    }

    final level =
        RapidQuestionModel(

      level: levelNumber,

      title:
          titleController.text
              .trim(),

      story:
          storyController.text
              .trim(),

      audioUrl: "",

      imageUrl:
          uploadedImageUrl,

      questions:
          questions,
    );

    await _repository
        .saveLevel(
      level,
    );

    await loadLevels();

    clearForm();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        backgroundColor:
            Colors.green,
        content: Text(
          "✅ Nivel guardado correctamente",
        ),
      ),
    );
  }

  void loadLevelForEdit(
    RapidQuestionModel
        level,
  ) {

    levelController.text =
        level.level.toString();

    titleController.text =
        level.title;

    storyController.text =
        level.story;

    imageUrl =
        level.imageUrl;

    for (int i = 0;
        i < level.questions.length;
        i++) {

      questionControllers[i]
              .text =
          level.questions[i]
              ["question"];

      final options =
          List<String>.from(
        level.questions[i]
            ["options"],
      );

      for (int j = 0;
          j < 4;
          j++) {

        optionControllers[i]
                [j]
            .text =
            options[j];
      }

      correctAnswers[i] =
          level.questions[i]
              ["correctAnswer"];
    }

    setState(() {
      isEditing = true;
    });
  }

  void clearForm() {

    levelController.clear();

    titleController.clear();

    storyController.clear();

    imageUrl = "";

    selectedImage = null;

    for (int i = 0;
        i < 5;
        i++) {

      questionControllers[i]
          .clear();

      for (int j = 0;
          j < 4;
          j++) {

        optionControllers[i]
                [j]
            .clear();
      }

      correctAnswers[i] = 0;
    }

    setState(() {
      isEditing = false;
    });
  }

  Widget buildTextField({
    required TextEditingController
        controller,
    required String label,
    int maxLines = 1,
    TextInputType?
        keyboardType,
  }) {

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          keyboardType,
      decoration:
          InputDecoration(
        labelText: label,
        filled: true,
        fillColor:
            Colors.white,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
            18,
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(
    int index,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),

      decoration:
          BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          25,
        ),

        boxShadow: const [

          BoxShadow(
            color:
                Colors.black12,
            blurRadius: 6,
            offset:
                Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Row(

              children: [

                const Icon(
                  Icons.quiz,
                  color:
                      Colors.purple,
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  "Pregunta ${index + 1}",
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            buildTextField(
              controller:
                  questionControllers[
                      index],
              label:
                  "Pregunta",
            ),

            const SizedBox(
              height: 15,
            ),

            for (
              int i = 0;
              i < 4;
              i++
            )

              Padding(

                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),

                child:
                    buildTextField(
                  controller:
                      optionControllers[
                          index][i],
                  label:
                      "Opción ${i + 1}",
                ),
              ),

            const SizedBox(
              height: 10,
            ),

            DropdownButtonFormField<
                int>(

              value:
                  correctAnswers[
                      index],

              decoration:
                  InputDecoration(

                filled: true,

                fillColor:
                    Colors.grey
                        .shade100,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),
              ),

              items:
                  List.generate(

                4,

                (i) =>
                    DropdownMenuItem(

                  value: i,

                  child: Text(
                    "Respuesta correcta: ${i + 1}",
                  ),
                ),
              ),

              onChanged:
                  (value) {

                setState(() {

                  correctAnswers[
                      index] = value!;
                });
              },
            ),
          ],
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isEditing)
  Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.only(
      bottom: 15,
    ),
    decoration: BoxDecoration(
      color: Colors.orange.shade100,
      borderRadius:
          BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.edit,
          color: Colors.orange,
        ),
        SizedBox(width: 10),
        Text(
          "Modo edición",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
            /// HEADER
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                25,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    Colors.blueAccent,
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    35,
                  ),
                  bottomRight:
                      Radius.circular(
                    35,
                  ),
                ),
              ),
              child: const Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Icon(
                    Icons.quiz,
                    size: 70,
                    color:
                        Colors.white,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Preguntas Rápidas",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Crea cuentos y preguntas para tus alumnos",
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      20,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        25,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Colors.black12,
                          blurRadius:
                              6,
                          offset:
                              Offset(
                            0,
                            3,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildTextField(
                          controller:
                              levelController,
                          label:
                              "Nivel",
                          keyboardType:
                              TextInputType
                                  .number,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        buildTextField(
                          controller:
                              titleController,
                          label:
                              "Título",
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        buildTextField(
                          controller:
                              storyController,
                          label:
                              "Cuento o lectura",
                          maxLines: 8,
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(
                            Icons.image,
                          ),
                          label: const Text(
                            "Seleccionar Imagen",
                          ),
                        ),

                    const SizedBox(
                      height: 10,
                    ),

                    if (selectedImage != null)
                      Image.file(
                        selectedImage!,
                        height: 180,
                      )
                    else if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        height: 180,
                      ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  for (
                    int i = 0;
                    i < 5;
                    i++
                  )
                    buildQuestion(i),

                  const SizedBox(
                    height: 15,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 60,
                    child:
                        ElevatedButton
                            .icon(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.green,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                      onPressed:
                          saveLevel,
                      icon:
                          const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      label: Text(
                        isEditing
                            ? "Actualizar Nivel"
                            : "Guardar Nivel",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Historias Guardadas",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(
  height: 15,
),

ListView.builder(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
  itemCount: levels.length,
  itemBuilder: (context, index) {

    final level = levels[index];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            level.level.toString(),
          ),
        ),
        title: Text(
          level.title,
        ),
        subtitle: Text(
          "Nivel ${level.level}",
        ),
        trailing: const Icon(
          Icons.edit,
        ),
        onTap: () {
          loadLevelForEdit(level);
        },
      ),
    );
  },
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
void dispose() {

  levelController.dispose();
  titleController.dispose();
  storyController.dispose();

  for (final controller
      in questionControllers) {
    controller.dispose();
  }

  for (final list
      in optionControllers) {

    for (final controller
        in list) {
      controller.dispose();
    }
  }

  super.dispose();
}
}