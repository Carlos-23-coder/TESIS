class StudentModel {

  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final int totalStars;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.totalStars,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "imageUrl": imageUrl,
      "totalStars": totalStars,
    };
  }

  factory StudentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return StudentModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      totalStars: map["totalStars"] ?? 0,
    );
  }
}