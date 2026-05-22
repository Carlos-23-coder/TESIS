class RewardModel {

  final String id;

  final String name;

  final String category;

  final String imagePath;

  final int requiredStars;

  RewardModel({

    required this.id,

    required this.name,

    required this.category,

    required this.imagePath,

    required this.requiredStars,
  });

  Map<String, dynamic> toMap() {

    return {

      "id": id,

      "name": name,

      "category": category,

      "imagePath": imagePath,

      "requiredStars": requiredStars,
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
    );
  }
}