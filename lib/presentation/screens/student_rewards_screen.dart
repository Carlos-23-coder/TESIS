import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/reward_claim_model.dart';
import '../../data/repositories/reward_claim_repository.dart';
import '../../data/services/tutor_resolver.dart';

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

class _StudentRewardsScreenState extends State<StudentRewardsScreen> {
  final RewardClaimRepository _claimRepository =
      RewardClaimRepository();

  String? studentEmail;
  String studentName = 'Alumno';
  bool loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        loadingProfile = false;
      });
      return;
    }

    studentEmail = user.email;
    studentName = user.displayName ?? 'Alumno';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email!)
          .get();

      if (doc.exists) {
        studentName = doc.data()?['username'] ?? studentName;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  String? _claimStatusForReward(
    String rewardId,
    List<RewardClaimModel> claims,
  ) {
    for (final claim in claims) {
      if (claim.rewardId == rewardId) {
        return claim.status;
      }
    }

    return null;
  }

  Future<void> _requestReward({
    required String rewardId,
    required String rewardName,
    required String tutorEmail,
  }) async {
    if (studentEmail == null) return;

    final error = await _claimRepository.requestClaim(
      studentEmail: studentEmail!,
      studentName: studentName,
      rewardId: rewardId,
      rewardName: rewardName,
      tutorEmail: tutorEmail,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.orange,
        content: Text(
          'Solicitud enviada. Espera la aprobación de tu tutor.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile || studentEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          'Mis Recompensas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF64B5F6),
                  Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.userStars} estrellas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RewardClaimModel>>(
              stream: _claimRepository.watchStudentClaims(
                studentEmail!,
              ),
              builder: (context, claimsSnapshot) {
                final claims = claimsSnapshot.data ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rewards')
                      .snapshots(),
                  builder: (context, rewardsSnapshot) {
                    if (!rewardsSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final rewards = rewardsSnapshot.data!.docs;

                    if (rewards.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay recompensas disponibles',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        final data =
                            reward.data() as Map<String, dynamic>;
                        final rewardId = reward.id;
                        final neededStars =
                            data['requiredStars'] ?? 0;
                        final unlocked =
                            widget.userStars >= neededStars;
                        final claimStatus = _claimStatusForReward(
                          rewardId,
                          claims,
                        );

                        final bool obtained = claimStatus ==
                            RewardClaimStatus.approved;
                        final bool pending = claimStatus ==
                            RewardClaimStatus.pending;

                        Color buttonColor = Colors.red;

                        if (obtained) {
                          buttonColor = Colors.grey;
                        } else if (pending) {
                          buttonColor = Colors.orange;
                        } else if (unlocked) {
                          buttonColor = Colors.green;
                        }

                        String buttonText = '🔒 Bloqueada';

                        if (obtained) {
                          buttonText = '✅ Obtenido';
                        } else if (pending) {
                          buttonText = '⏳ Pendiente';
                        } else if (unlocked) {
                          buttonText = '🎁 Obtener';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                                child: data['imagePath'] != null &&
                                        data['imagePath']
                                            .toString()
                                            .isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        ),
                                        child: Image.file(
                                          File(data['imagePath']),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
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
                                        ),
                                      )
                                    : const Icon(
                                        Icons.card_giftcard,
                                        size: 80,
                                        color: Colors.blueAccent,
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '🎮 ${data['category']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '⭐ $neededStars estrellas',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: buttonColor,
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: unlocked &&
                                                !obtained &&
                                                !pending
                                            ? () async {
                                                String tutorEmail =
                                                    data['tutorEmail']
                                                            ?.toString() ??
                                                        '';

                                                if (tutorEmail.isEmpty) {
                                                  tutorEmail =
                                                      await TutorResolver
                                                          .resolveTutorEmail();
                                                }

                                                await _requestReward(
                                                  rewardId: rewardId,
                                                  rewardName:
                                                      data['name'] ?? '',
                                                  tutorEmail: tutorEmail,
                                                );
                                              }
                                            : null,
                                        child: Text(
                                          buttonText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
