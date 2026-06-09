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

    title: "La panadería de la abuela",

    story:
        "Valentina despertó muy temprano un sábado porque "
        "había prometido ayudar a su abuela Rosa en la panadería "
        "del barrio. Al llegar, el aroma del pan recién horneado "
        "llenaba todo el local. Rosa le explicó que ese día "
        "prepararían bollos, empanadas y galletas para una fiesta "
        "escolar. Valentina lavó sus manos, se puso un delantal "
        "y comenzó a amasar la masa mientras escuchaba atentamente "
        "las instrucciones de su abuela. "
        "Más tarde, organizó las bandejas, etiquetó cada producto "
        "con su precio y atendió amablemente a los primeros clientes. "
        "Cuando la panadería cerró, Rosa abrazó a Valentina y le "
        "dijo que gracias a su ayuda habían terminado a tiempo. "
        "Valentina regresó a casa orgullosa de haber aprendido "
        "a trabajar en equipo y a ser responsable.",

    image: "assets/images/rapidas1.png",

    questions: [

      {
        "question":
            "¿A quién ayudó Valentina?",

        "options": [
          "A su abuela Rosa",
          "A su maestra",
          "A un vecino",
          "A su hermano",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué prepararon en la panadería?",

        "options": [
          "Bollos, empanadas y galletas",
          "Solo tortas",
          "Helados y jugos",
          "Pizza y pasta",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué aprendió Valentina al final?",

        "options": [
          "A trabajar en equipo y ser responsable",
          "A manejar una bicicleta",
          "A nadar en la piscina",
          "A tocar la guitarra",
        ],

        "correctAnswer": 0,
      },
    ],
  ),

  /// NIVEL 2

  PreguntaRapidaLevel(

    level: 2,

    title: "El experimento de Diego",

    story:
        "Diego era un niño curioso que adoraba la ciencia. "
        "Un día, su escuela anunció una feria de experimentos "
        "y cada alumno debía presentar un proyecto creativo. "
        "Diego decidió investigar cómo crecen las plantas con "
        "distintas cantidades de luz. Plantó tres semillas iguales "
        "en macetas diferentes: una cerca de la ventana, otra "
        "en un lugar con poca luz y la tercera en la oscuridad. "
        "Durante dos semanas, regó las plantas con la misma "
        "cantidad de agua y anotó en su cuaderno los cambios "
        "que observaba cada mañana. "
        "El día de la feria, Diego explicó con claridad sus "
        "resultados ante sus compañeros y profesores. "
        "Demostró que la planta con más luz creció mejor, "
        "mientras que la que estuvo en la oscuridad se debilitó. "
        "Su maestra felicitó el esfuerzo de Diego y destacó "
        "que había aprendido a observar, registrar datos "
        "y sacar conclusiones.",

    image: "assets/images/rapidas2.png",

    questions: [

      {
        "question":
            "¿Qué tipo de evento organizó la escuela?",

        "options": [
          "Una feria de experimentos",
          "Un partido de fútbol",
          "Una excursión al zoológico",
          "Un concurso de dibujo",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué investigó Diego?",

        "options": [
          "Cómo crecen las plantas con distinta luz",
          "Cómo volar cometas",
          "Cómo construir robots",
          "Cómo cocinar sopas",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué planta creció mejor?",

        "options": [
          "La que recibió más luz",
          "La que estuvo en la oscuridad",
          "La que no recibió agua",
          "Ninguna creció",
        ],

        "correctAnswer": 0,
      },
    ],
  ),

  /// NIVEL 3

  PreguntaRapidaLevel(

    level: 3,

    title: "La biblioteca del barrio",

    story:
        "Sofía amaba leer, pero en su barrio la biblioteca "
        "estaba cerrada desde hacía meses por falta de voluntarios. "
        "Una tarde, reunió a sus amigos Mateo y Camila para "
        "proponerles reabrirla los fines de semana. "
        "Los tres hablaron con la directora del colegio, "
        "quien les prestó estantes, libros donados y cartulinas "
        "para hacer afiches. "
        "Durante varias semanas, limpiaron las mesas, "
        "ordenaron los libros por temas y prepararon "
        "una pequeña actividad de lectura en voz alta "
        "para los niños más pequeños. "
        "El primer sábado de apertura, más de quince familias "
        "asistieron. Sofía leyó un cuento sobre amistad "
        "y al final invitó a todos a elegir un libro "
        "para llevar a casa. "
        "Al ver el entusiasmo de la comunidad, los adultos "
        "del barrio se ofrecieron a colaborar cada semana. "
        "Sofía comprendió que con organización, "
        "perseverancia y ayuda mutua "
        "es posible transformar un espacio olvidado "
        "en un lugar lleno de aprendizaje.",

    image: "assets/images/rapidas3.png",

    questions: [

      {
        "question":
            "¿Por qué estaba cerrada la biblioteca?",

        "options": [
          "Por falta de voluntarios",
          "Porque no había libros",
          "Porque llovía mucho",
          "Porque se mudó el barrio",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué hicieron Sofía y sus amigos?",

        "options": [
          "La reabrieron los fines de semana",
          "La vendieron",
          "La pintaron de azul",
          "La convirtieron en tienda",
        ],

        "correctAnswer": 0,
      },

      {
        "question":
            "¿Qué aprendió Sofía al final?",

        "options": [
          "Que con organización y ayuda mutua se puede lograr mucho",
          "Que leer es aburrido",
          "Que los libros no sirven",
          "Que es mejor no compartir",
        ],

        "correctAnswer": 0,
      },
    ],
  ),
];
