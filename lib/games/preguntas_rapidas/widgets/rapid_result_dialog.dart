import 'package:flutter/material.dart';

class RapidResultDialog
    extends StatelessWidget {

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
  Widget build(
    BuildContext context,
  ) {

    final bool perfect =
        earnedStars == 3;

    return Dialog(

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Container(

        padding:
            const EdgeInsets.all(30),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            /// 🎉 EMOJI
            Text(

              perfect
                  ? "🎉"
                  : "✅",

              style: const TextStyle(
                fontSize: 60,
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 RESULTADO
            Text(

              "$correctAnswers de $totalQuestions",

              style:
                  const TextStyle(

                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// ⭐ ESTRELLAS
            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .center,

              children:
                  List.generate(

                3,

                (index) => Padding(

                  padding:
                      const EdgeInsets
                          .symmetric(
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

            /// 🔘 BOTONES
            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

              children: [

                /// REINTENTAR
                ElevatedButton.icon(

                  onPressed: onRetry,

                  icon: const Icon(
                    Icons.refresh,
                  ),

                  label: const Text(
                    "Reintentar",
                  ),

                  style:
                      ElevatedButton
                          .styleFrom(

                    backgroundColor:
                        Colors.orange,
                  ),
                ),

                /// VOLVER
                ElevatedButton.icon(

                  onPressed: onBack,

                  icon: const Icon(
                    Icons.arrow_back,
                  ),

                  label: const Text(
                    "Volver",
                  ),

                  style:
                      ElevatedButton
                          .styleFrom(

                    backgroundColor:
                        Colors.blue,
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