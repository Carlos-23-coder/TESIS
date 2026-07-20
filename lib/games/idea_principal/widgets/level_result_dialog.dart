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
        borderRadius: BorderRadius.circular(20),
      ),

      child: Container(

        padding: const EdgeInsets.all(30),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            /// ✅ EMOJI RESULTADO
            Text(

              success ? "✅" : "❌",

              style: const TextStyle(
                fontSize: 60,
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 TÍTULO
            Text(

              success
                  ? "¡Excelente!"
                  : "¡Vuelve a intentar!",

              style: TextStyle(

                fontSize: 28,
                fontWeight: FontWeight.bold,

                color: success
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 15),

            /// 📝 MENSAJE
            Text(

              success
                  ? "Comprendiste correctamente la lectura."
                  : "Lee el texto más cuidadosamente e inténtalo otra vez.",

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            /// ⭐ ESTRELLAS
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

            /// 🔘 BOTONES
            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

              children: [

                /// VOLVER/REINTENTAR
                ElevatedButton.icon(

                  onPressed: success
                      ? onMap
                      : onRetry,

                  icon: Icon(
                    success
                        ? Icons.arrow_back
                        : Icons.refresh,
                  ),

                  label: Text(
                    success
                        ? "Volver"
                        : "Reintentar",
                  ),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue,
                  ),
                ),

                /// SIGUIENTE
                if (success)
                  ElevatedButton.icon(

                    onPressed: onNextLevel,

                    icon: const Icon(
                      Icons.arrow_forward,
                    ),

                    label: const Text(
                      "Siguiente",
                    ),

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.green,
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