class RewardClaimStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
}

class RewardClaimModel {
  final String id;
  final String studentEmail;
  final String studentName;
  final String rewardId;
  final String rewardName;
  final String tutorEmail;
  final String status;
  final String date;
  final int synced;

  RewardClaimModel({
    required this.id,
    required this.studentEmail,
    required this.studentName,
    required this.rewardId,
    required this.rewardName,
    required this.tutorEmail,
    required this.status,
    required this.date,
    this.synced = 0,
  });

  static String buildId(
    String studentEmail,
    String rewardId,
  ) {
    return '${studentEmail}_$rewardId';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentEmail': studentEmail,
      'studentName': studentName,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'tutorEmail': tutorEmail,
      'status': status,
      'date': date,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      ...toMap(),
      'synced': synced,
    };
  }

  factory RewardClaimModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return RewardClaimModel(
      id: map['id'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      studentName: map['studentName'] ?? '',
      rewardId: map['rewardId'] ?? '',
      rewardName: map['rewardName'] ?? '',
      tutorEmail: map['tutorEmail'] ?? '',
      status: map['status'] ?? RewardClaimStatus.pending,
      date: map['date'] ?? DateTime.now().toIso8601String(),
      synced: map['synced'] ?? 0,
    );
  }

  RewardClaimModel copyWith({
    String? status,
    int? synced,
  }) {
    return RewardClaimModel(
      id: id,
      studentEmail: studentEmail,
      studentName: studentName,
      rewardId: rewardId,
      rewardName: rewardName,
      tutorEmail: tutorEmail,
      status: status ?? this.status,
      date: date,
      synced: synced ?? this.synced,
    );
  }
}
