class IdeaLevel {

  final int level;
  final String story;
  final String image;
  final String question;
  final List<String> options;
  final int correctAnswer;

  IdeaLevel({
    required this.level,
    required this.story,
    required this.image,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

final List<IdeaLevel> ideaLevels = [

  IdeaLevel(
    level: 1,

    story:
        "Lucas encontró un perrito perdido en el parque. "
        "El perrito tenía hambre y frío. "
        "Lucas decidió llevarlo a casa y cuidarlo hasta encontrar a su dueño.",

    image: 'assets/images/cuento1.png',

    question:
        "¿Cuál es la idea principal de la historia?",

    options: [
      "Lucas encontró y ayudó a un perrito perdido",
      "Lucas fue a jugar al parque",
      "El perro quería dormir",
    ],

    correctAnswer: 0,
  ),

];