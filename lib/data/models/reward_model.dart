class RewardModel {

  final String id;

  final String name;

  final String category;

  final String imagePath;

  final int requiredStars;

  final String tutorEmail;

  RewardModel({

    required this.id,

    required this.name,

    required this.category,

    required this.imagePath,

    required this.requiredStars,

    required this.tutorEmail,
  });

  Map<String, dynamic> toMap() {

    return {

      "id": id,

      "name": name,

      "category": category,

      "imagePath": imagePath,

      "requiredStars": requiredStars,

      "tutorEmail": tutorEmail,
    };
  }

  factory RewardModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return RewardModel(

      id: map["id"],

      name: map["name"],

      category: map["category"],

      imagePath: map["imagePath"],

      requiredStars: map["requiredStars"],

      tutorEmail: map["tutorEmail"] ?? "",
    );
  }
}