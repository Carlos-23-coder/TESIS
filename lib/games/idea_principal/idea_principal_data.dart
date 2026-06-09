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

  /// ⭐ NIVEL 1
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

  /// ⭐ NIVEL 2
  IdeaLevel(
    level: 2,

    story:
        "María y su hermano Luis fueron al parque una tarde soleada. "
        "Mientras caminaban, observaron que muchos niños jugaban felices "
        "en los columpios y resbaladeras. María llevaba una pelota roja y "
        "Luis una cometa azul. Decidieron jugar primero con la pelota, pero "
        "de pronto comenzó a soplar un viento muy fuerte. Entonces Luis tuvo "
        "la idea de volar su cometa. Los dos corrieron por el césped mientras "
        "la cometa subía cada vez más alto en el cielo. Después de un rato, "
        "se sentaron bajo un árbol para comer unas galletas y beber jugo. "
        "Antes de regresar a casa, ayudaron a recoger la basura que otras "
        "personas habían dejado en el parque.",

    image: 'assets/images/cuento2.png',

    question:
        "¿Cuál es la idea principal de la historia?",

    options: [

      "María y Luis disfrutaron jugando y ayudando en el parque.",

      "La cometa azul podía volar muy alto.",

      "Los niños comieron galletas debajo de un árbol.",
    ],

    correctAnswer: 0,
  ),
  /// ⭐ NIVEL 3
IdeaLevel(
  level: 3,

  story:
      "Ana estaba preocupada porque el patio de su escuela "
      "tenía muchos papeles y botellas tiradas en el suelo. "
      "Decidió hablar con sus compañeros para organizar una "
      "jornada de limpieza. Todos participaron recogiendo "
      "basura y separando los residuos reciclables. "
      "Al finalizar, el patio quedó limpio y ordenado. "
      "Los estudiantes se sintieron orgullosos de haber "
      "trabajado juntos para cuidar su escuela.",

  image: 'assets/images/cuento3.png',

  question:
      "¿Cuál es la idea principal de la historia?",

  options: [

    "Los estudiantes trabajaron juntos para limpiar y cuidar su escuela.",

    "Ana encontró muchas botellas en el patio.",

    "Los alumnos aprendieron a reciclar.",

  ],

  correctAnswer: 0,
),

];