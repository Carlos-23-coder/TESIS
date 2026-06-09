import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/reward_claim_model.dart';

class RewardClaimRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance;

  Stream<List<RewardClaimModel>> watchStudentClaims(
    String studentEmail,
  ) {
    return _firestore
        .collection('reward_claims')
        .where('studentEmail', isEqualTo: studentEmail)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => RewardClaimModel.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  Stream<List<RewardClaimModel>> watchPendingClaimsForTutor(
    String tutorEmail,
  ) {
    return _firestore
        .collection('reward_claims')
        .where('tutorEmail', isEqualTo: tutorEmail)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => RewardClaimModel.fromMap(doc.data()),
              )
              .where(
                (claim) =>
                    claim.status == RewardClaimStatus.pending,
              )
              .toList(),
        );
  }

  Future<RewardClaimModel?> getClaim(String id) async {
    try {
      final doc = await _firestore
          .collection('reward_claims')
          .doc(id)
          .get();

      if (doc.exists) {
        return RewardClaimModel.fromMap(doc.data()!);
      }
    } catch (_) {}

    final db = await _dbHelper.database;

    final results = await db.query(
      'reward_claims',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return RewardClaimModel.fromMap(results.first);
  }

  Future<String?> requestClaim({
    required String studentEmail,
    required String studentName,
    required String rewardId,
    required String rewardName,
    required String tutorEmail,
  }) async {
    final id = RewardClaimModel.buildId(
      studentEmail,
      rewardId,
    );

    final existing = await getClaim(id);

    if (existing?.status == RewardClaimStatus.approved) {
      return 'Ya obtuviste esta recompensa.';
    }

    if (existing?.status == RewardClaimStatus.pending) {
      return 'Esta recompensa ya está pendiente de aprobación.';
    }

    final claim = RewardClaimModel(
      id: id,
      studentEmail: studentEmail,
      studentName: studentName,
      rewardId: rewardId,
      rewardName: rewardName,
      tutorEmail: tutorEmail,
      status: RewardClaimStatus.pending,
      date: DateTime.now().toIso8601String(),
      synced: 0,
    );

    await _saveClaimOffline(claim);

    try {
      await _firestore
          .collection('reward_claims')
          .doc(id)
          .set(claim.toMap());

      final db = await _dbHelper.database;

      await db.update(
        'reward_claims',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}

    return null;
  }

  Future<void> approveClaim(String id) async {
    await _updateClaimStatus(
      id,
      RewardClaimStatus.approved,
    );
  }

  Future<void> rejectClaim(String id) async {
    await _updateClaimStatus(
      id,
      RewardClaimStatus.rejected,
    );
  }

  Future<void> _updateClaimStatus(
    String id,
    String status,
  ) async {
    final existing = await getClaim(id);

    if (existing == null) {
      return;
    }

    final updated = existing.copyWith(
      status: status,
      synced: 0,
    );

    await _saveClaimOffline(updated);

    try {
      await _firestore
          .collection('reward_claims')
          .doc(id)
          .update({'status': status});

      final db = await _dbHelper.database;

      await db.update(
        'reward_claims',
        {'status': status, 'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  Future<void> _saveClaimOffline(
    RewardClaimModel claim,
  ) async {
    final db = await _dbHelper.database;

    await db.insert(
      'reward_claims',
      claim.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
