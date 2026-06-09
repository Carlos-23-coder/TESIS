import 'package:flutter/material.dart';

class RapidResultDialog extends StatelessWidget {
  final bool success;
  final int correctAnswers;
  final int totalQuestions;
  final int earnedStars;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final VoidCallback onBack;

  const RapidResultDialog({
    super.key,
    required this.success,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedStars,
    required this.onRetry,
    required this.onNextLevel,
    required this.onBack,
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
                      ? "¡Nivel completado!"
                      : "¡Inténtalo de nuevo!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  success
                      ? "$correctAnswers de $totalQuestions respuestas correctas"
                      : "Lee la historia con atención e inténtalo otra vez.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),

                if (success) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Icon(
                          index < earnedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              success ? onBack : onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                success ? Colors.blue : Colors.orange,
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

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              success ? onNextLevel : onBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                success ? Colors.green : Colors.blue,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              success ? "Siguiente" : "Volver",
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
