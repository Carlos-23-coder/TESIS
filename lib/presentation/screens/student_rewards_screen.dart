import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRewardsScreen extends StatefulWidget {

  final int userStars;

  const StudentRewardsScreen({
    super.key,
    required this.userStars,
  });

  @override
  State<StudentRewardsScreen> createState() =>
      _StudentRewardsScreenState();
}

class _StudentRewardsScreenState
    extends State<StudentRewardsScreen> {

  List<String> obtainedRewards = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            Colors.blueAccent,

        centerTitle: true,

        title: const Text(
          "Mis Recompensas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(

        children: [

          /// ⭐ ESTRELLAS DEL ALUMNO
          Container(

            width: double.infinity,

            margin:
                const EdgeInsets.all(16),

            padding:
                const EdgeInsets.all(18),

            decoration: BoxDecoration(

              gradient:
                  LinearGradient(

                colors: [

                  Color(0xFF64B5F6),
                    Color(0xFF1976D2),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                25,
              ),

              boxShadow: const [

                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 35,
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(

                  "${widget.userStars} estrellas",

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 LISTA
          Expanded(

            child:
                StreamBuilder<QuerySnapshot>(

              stream:
                  FirebaseFirestore.instance
                      .collection("rewards")
                      .snapshots(),

              builder:
                  (context, snapshot) {

                if (!snapshot.hasData) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final rewards =
                    snapshot.data!.docs;

                if (rewards.isEmpty) {

                  return const Center(

                    child: Text(

                      "No hay recompensas disponibles",

                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount:
                      rewards.length,

                  itemBuilder:
                      (context, index) {

                    final reward =
                        rewards[index];

                    final data =
                        reward.data()
                            as Map<String, dynamic>;

                    final rewardId =
                        reward.id;

                    /// ⭐ ESTRELLAS
                    final int neededStars =
                        data["requiredStars"] ?? 0;

                    /// 🔓 DESBLOQUEO
                    final bool unlocked =
                        widget.userStars >=
                            neededStars;

                    /// ✅ OBTENIDA
                    final bool obtained =
                        obtainedRewards
                            .contains(
                      rewardId,
                    );

                    return Container(

                      margin:
                          const EdgeInsets.only(
                        bottom: 20,
                      ),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),

                        boxShadow: [

                          BoxShadow(
                            color: Colors.blue.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          /// 🖼️ IMAGEN
                          Container(

                            height: 180,

                            width:
                                double.infinity,

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.blue
                                      .shade100,

                              borderRadius:
                                  const BorderRadius.only(

                                topLeft:
                                    Radius.circular(
                                  25,
                                ),

                                topRight:
                                    Radius.circular(
                                  25,
                                ),
                              ),
                            ),

                            child:
                                data["imagePath"] !=
                                            null &&
                                        data["imagePath"]
                                            .toString()
                                            .isNotEmpty

                                    ? ClipRRect(

                                        borderRadius:
                                            const BorderRadius.only(

                                          topLeft:
                                              Radius.circular(
                                            25,
                                          ),

                                          topRight:
                                              Radius.circular(
                                            25,
                                          ),
                                        ),

                                        child:
                                            Image.file(

                                              File(
                                                data["imagePath"],
                                              ),

                                              fit: BoxFit.cover,

                                              errorBuilder:
                                                  (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {

                                                return const Icon(

                                                  Icons.card_giftcard,

                                                  size: 80,

                                                  color: Colors.blue,
                                                );
                                              },
                                            )
                                      )

                                    : const Icon(

                                        Icons.card_giftcard,

                                        size: 80,

                                        color: Colors.blueAccent,
                                      ),
                          ),

                          Padding(

                            padding:
                                const EdgeInsets.all(
                              18,
                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                /// 🎁 NOMBRE
                                Text(

                                  data["name"] ?? "",

                                  style:
                                      const TextStyle(

                                    fontSize: 24,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                /// 📂 CATEGORÍA
                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors.blue
                                            .shade50,

                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                                  child: Text(

                                    "🎮 ${data["category"]}",

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                /// ⭐ ESTRELLAS
                                Text(

                                  "⭐ $neededStars estrellas",

                                  style:
                                      const TextStyle(

                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                /// 🔥 BOTÓN
                                SizedBox(

                                  width:
                                      double.infinity,

                                  child:
                                      ElevatedButton(

                                    style:
                                        ElevatedButton.styleFrom(

                                      elevation: 0,

                                      backgroundColor:
                                          obtained
                                              ? Colors.grey
                                              : unlocked
                                                  ? Colors.green
                                                  : Colors.red,

                                      padding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          16,
                                        ),
                                      ),
                                    ),

                                    onPressed:

                                        unlocked &&
                                                !obtained

                                            ? () {

                                                setState(() {

                                                  obtainedRewards
                                                      .add(
                                                    rewardId,
                                                  );
                                                });

                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(

                                                  SnackBar(

                                                    backgroundColor:
                                                        Colors.green,

                                                    content: Text(

                                                      "🎉 Recompensa obtenida: ${data["name"]}",
                                                    ),
                                                  ),
                                                );
                                              }

                                            : null,

                                    child: Text(

                                      obtained
                                          ? "✅ Obtenido"
                                          : unlocked
                                              ? "🎁 Obtener"
                                              : "🔒 Bloqueada",

                                      style:
                                          const TextStyle(

                                        fontSize: 16,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
