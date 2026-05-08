import 'package:flutter/material.dart';

class LevelResultDialog extends StatelessWidget {

  final bool success;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final VoidCallback onMap;

  const LevelResultDialog({
    super.key,
    required this.success,
    required this.onRetry,
    required this.onNextLevel,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {

    return Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            /// CARITA
            Icon(
              success
                  ? Icons.sentiment_very_satisfied
                  : Icons.sentiment_dissatisfied,

              color: success
                  ? Colors.green
                  : Colors.red,

              size: 100,
            ),

            const SizedBox(height: 20),

            /// TÍTULO
            Text(
              success
                  ? "¡Excelente!"
                  : "¡Ups!",

              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: success
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 15),

            /// MENSAJE
            Text(
              success
                  ? "Comprendiste correctamente la lectura."
                  : "Vuelve a leer el texto e inténtalo otra vez.",

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            /// ESTRELLAS
            if (success)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: const [

                  Icon(Icons.star,
                      color: Colors.amber,
                      size: 40),

                  Icon(Icons.star,
                      color: Colors.amber,
                      size: 40),

                  Icon(Icons.star,
                      color: Colors.amber,
                      size: 40),
                ],
              ),

            const SizedBox(height: 30),

            /// BOTONES
            Row(
              children: [

                /// MAPA
                Expanded(
                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),

                    onPressed: onMap,

                    child: const Text(
                      "Mapa",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                /// SIGUIENTE / REINTENTAR
                Expanded(
                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: success
                          ? Colors.green
                          : Colors.orange,

                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),

                    onPressed: success
                        ? onNextLevel
                        : onRetry,

                    child: Text(
                      success
                          ? "Siguiente"
                          : "Reintentar",

                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}