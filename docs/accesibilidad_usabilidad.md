# Accesibilidad y usabilidad en LectoPlay

LectoPlay adopta como referencia principal las Pautas de Accesibilidad para el Contenido Web WCAG 2.2 en nivel AA y la norma ISO 9241-11:2018 para usabilidad. Estas normas se aplican al prototipo movil como guia de diseno, implementacion y evaluacion funcional.

## Normas aplicadas

- WCAG 2.2 AA: se usa para orientar contraste, escalado de texto, legibilidad, navegacion comprensible, retroalimentacion perceptible y controles operables.
- ISO 9241-11:2018: se usa para evaluar usabilidad mediante eficacia, eficiencia y satisfaccion en el contexto de uso de ninos de 8 a 12 anos con TDAH, tutores y administrador.
- ISO/IEC 25010:2011: se usa como apoyo para relacionar la usabilidad con atributos de calidad del software, como adecuacion, aprendizaje, operabilidad, proteccion frente a errores y accesibilidad.

## Criterios implementados

- Modo oscuro y modo de alto contraste para reducir fatiga visual y mejorar la percepcion de los elementos.
- Escalado de texto configurable hasta 200%, alineado con el criterio WCAG 1.4.4.
- Controles con etiquetas visibles, iconos reconocibles y tamanos tactiles amplios.
- Botones de respuesta con altura flexible para evitar cortes cuando aumenta el tamano de letra.
- Retroalimentacion inmediata mediante color, sonido, dialogos y mensajes.
- Actividades breves, niveles progresivos, recompensas y seguimiento de progreso para favorecer la atencion y la motivacion.
- Narrador de texto en la actividad de preguntas rapidas como apoyo a la lectura.

## Evidencia en el proyecto

- `lib/core/accessibility/accessibility_controller.dart`: guarda preferencias por usuario para modo oscuro, alto contraste, tamano de letra, musica y volumen.
- `lib/main.dart`: aplica tema, contraste y escalado global del texto.
- `lib/presentation/screens/settings_screen.dart`: permite configurar accesibilidad y muestra las normas usadas.
- `lib/games/idea_principal/idea_principal_level.dart`: usa botones de respuesta adaptables al texto.
- `lib/games/preguntas_rapidas/preguntas_rapidas_level.dart`: integra narrador, temporizador, progreso visual y botones adaptables.

## Texto sugerido para el objetivo especifico 2

Disenar la aplicacion movil incorporando principios de accesibilidad basados en WCAG 2.2 nivel AA, usabilidad segun ISO 9241-11:2018 y estrategias de gamificacion para potenciar la atencion y el aprendizaje significativo en ninos de 8 a 12 anos con TDAH.
