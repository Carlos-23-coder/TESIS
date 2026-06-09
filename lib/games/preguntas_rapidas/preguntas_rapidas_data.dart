class PreguntaRapidaLevel {

  final int level;

  final String title;

  final String story;

  final String image;

  final List<Map<String, dynamic>> questions;

  PreguntaRapidaLevel({

    required this.level,
    required this.title,
    required this.story,
    required this.image,
    required this.questions,
  });
}

final List<PreguntaRapidaLevel> preguntasRapidasLevels = [

  /// NIVEL 1

  PreguntaRapidaLevel(

    level: 1,

    title: "El perrito perdido",

    story:
        "Lucas encontró un perrito perdido en el parque. "
        "El perrito tenía hambre y frío. "
        "Lucas decidió llevarlo a casa y cuidarlo hasta encontrar a su dueño.",

    image: "assets/images/cuento1.png",

    questions: [

      {
        "question":
            "¿Dónde encontró Lucas al perrito?",

        "options": [
          "En el parque",
          "En la escuela",
          "En la casa",
          "En la tienda",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Cómo estaba el perrito?",

        "options": [
          "Hambriento y con frío",
          "Muy feliz",
          "Durmiendo",
          "Corriendo",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué hizo Lucas?",

        "options": [
          "Lo ayudó",
          "Lo ignoró",
          "Lo vendió",
          "Lo escondió",
        ],

        "correctAnswer": 0,
      },
    ],
  ),

  /// NIVEL 2

  PreguntaRapidaLevel(

    level: 2,

    title: "María y Luis",

    story:
        "María y Luis fueron al parque para jugar con una pelota y una cometa. "
        "Después ayudaron a recoger la basura.",

    image: "assets/images/cuento2.png",

    questions: [

      {
        "question":
            "¿Qué llevaron al parque?",

        "options": [
          "Pelota y cometa",
          "Bicicleta",
          "Libros",
          "Patines",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué hicieron al final?",

        "options": [
          "Recogieron basura",
          "Se fueron corriendo",
          "Durmieron",
          "Compraron comida",
        ],

        "correctAnswer": 0,
      },
    ],
  ),

  /// NIVEL 3

  PreguntaRapidaLevel(

    level: 3,

    title: "La excursión",

    story:
        "Los alumnos realizaron una excursión al bosque para conocer plantas y animales.",

    image: "assets/images/cuento3.png",

    questions: [

      {
        "question":
            "¿A dónde fueron?",

        "options": [
          "Al bosque",
          "Al cine",
          "Al estadio",
          "Al hospital",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué observaron?",

        "options": [
          "Plantas y animales",
          "Autos",
          "Edificios",
          "Computadoras",
        ],

        "correctAnswer": 0,
      },
    ],
  ),
];