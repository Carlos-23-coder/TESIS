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
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  success ? "✅" : "❌",
                  style: const TextStyle(
                    fontSize: 60,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  success
                      ? "¡Excelente!"
                      : "¡Vuelve a intentarlo!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        success ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 15),

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

                if (success)
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 40,
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 40,
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ],
                  ),

               const SizedBox(height: 30),

                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: success ? onMap : onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              success ? "Volver" : "Reintentar",
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (success) ...[
                      const SizedBox(width: 10),

                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: onNextLevel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Siguiente",
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}