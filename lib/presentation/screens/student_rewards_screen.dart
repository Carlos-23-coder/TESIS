import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/reward_claim_model.dart';
import '../../data/models/reward_model.dart';
import '../../data/repositories/reward_claim_repository.dart';
import '../../data/repositories/reward_repository.dart';
import '../../data/services/local_session_service.dart';
import '../../data/services/tutor_resolver.dart';

class StudentRewardsScreen extends StatefulWidget {
  final int userStars;

  const StudentRewardsScreen({super.key, required this.userStars});

  @override
  State<StudentRewardsScreen> createState() => _StudentRewardsScreenState();
}

class _StudentRewardsScreenState extends State<StudentRewardsScreen> {
  final RewardClaimRepository _claimRepository = RewardClaimRepository();
  final RewardRepository _rewardRepository = RewardRepository();

  String? studentEmail;
  String studentName = 'Alumno';
  bool loadingProfile = true;
  Future<_RewardData>? _rewardDataFuture;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final localSession = LocalSessionService.instance;

    if (user == null && !localSession.hasUser) {
      setState(() {
        loadingProfile = false;
      });
      return;
    }

    studentEmail = user?.email?.trim().toLowerCase() ?? localSession.email;
    studentName = user?.displayName ?? localSession.username ?? 'Alumno';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentEmail!)
          .get();

      if (doc.exists) {
        studentName = doc.data()?['username'] ?? studentName;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        loadingProfile = false;
        _rewardDataFuture = _loadRewardData();
      });
    }
  }

  Future<_RewardData> _loadRewardData() async {
    final email = studentEmail;

    if (email == null || email.isEmpty) {
      return const _RewardData(rewards: [], claims: []);
    }

    final rewards = await _rewardRepository.getRewards();
    final claims = await _claimRepository.getStudentClaims(email);

    return _RewardData(rewards: rewards, claims: claims);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.orange,
        content: Text('Solicitud enviada. Espera la aprobacion de tu tutor.'),
      ),
    );

    setState(() {
      _rewardDataFuture = _loadRewardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF1D4ED8) : Colors.blueAccent;

    if (loadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (studentEmail == null || studentEmail!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No se pudo identificar al alumno.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: headerColor,
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
                colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 35),
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
            child: FutureBuilder<_RewardData>(
              future: _rewardDataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rewards = snapshot.data!.rewards;
                final claims = snapshot.data!.claims;

                if (rewards.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay recompensas disponibles',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final rewardId = reward.id;
                    final neededStars = reward.requiredStars;
                    final unlocked = widget.userStars >= neededStars;
                    final claimStatus = _claimStatusForReward(
                      rewardId,
                      claims,
                    );

                    final obtained =
                        claimStatus == RewardClaimStatus.approved;
                    final pending =
                        claimStatus == RewardClaimStatus.pending;

                    Color buttonColor = Colors.red;

                    if (obtained) {
                      buttonColor = Colors.grey;
                    } else if (pending) {
                      buttonColor = Colors.orange;
                    } else if (unlocked) {
                      buttonColor = Colors.green;
                    }

                    String buttonText = 'Bloqueada';

                    if (obtained) {
                      buttonText = 'Obtenido';
                    } else if (pending) {
                      buttonText = 'Pendiente';
                    } else if (unlocked) {
                      buttonText = 'Obtener';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.26)
                                : Colors.blue.withValues(alpha: 0.12),
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
                              color: isDark
                                  ? Colors.blueAccent.withValues(alpha: 0.18)
                                  : Colors.blue.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            child: reward.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                    ),
                                    child: Image.file(
                                      File(reward.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reward.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.blueAccent.withValues(
                                            alpha: 0.18,
                                          )
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    reward.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$neededStars estrellas',
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                      ),
                                    ),
                                    onPressed:
                                        unlocked && !obtained && !pending
                                        ? () async {
                                            String tutorEmail =
                                                reward.tutorEmail;

                                            if (tutorEmail.isEmpty) {
                                              tutorEmail = await TutorResolver
                                                  .resolveTutorEmail();
                                            }

                                            await _requestReward(
                                              rewardId: rewardId,
                                              rewardName: reward.name,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardData {
  final List<RewardModel> rewards;
  final List<RewardClaimModel> claims;

  const _RewardData({
    required this.rewards,
    required this.claims,
  });
}
