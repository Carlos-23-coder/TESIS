import 'package:flutter/material.dart';

class RapidResultDialog extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int earnedStars;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const RapidResultDialog({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedStars,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bool success = earnedStars > 0;

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
                    color:
                        success ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "$correctAnswers de $totalQuestions respuestas correctas",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding:
                          const EdgeInsets.symmetric(
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

               const SizedBox(height: 30),

                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Reintentar",
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

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Volver",
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}