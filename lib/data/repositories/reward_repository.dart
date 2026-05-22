import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reward_model.dart';

class RewardRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 🔥 GUARDAR RECOMPENSA
  Future<void> addReward(
    RewardModel reward,
  ) async {

    await _firestore
        .collection("rewards")
        .doc(reward.id)
        .set(
          reward.toMap(),
        );
  }

  /// 📚 OBTENER RECOMPENSAS
  Future<List<RewardModel>>
      getRewards() async {

    final snapshot = await _firestore
        .collection("rewards")
        .get();

    return snapshot.docs.map((doc) {

      return RewardModel.fromMap(
        doc.data(),
      );
    }).toList();
  }
}