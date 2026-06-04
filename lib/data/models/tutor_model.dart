class TutorModel {

  final String id;

  final String name;

  final String email;

  final String photoUrl;

  final int totalStudents;

  TutorModel({

    required this.id,

    required this.name,

    required this.email,

    required this.photoUrl,

    required this.totalStudents,
  });

  Map<String, dynamic> toMap() {

    return {

      "id": id,

      "name": name,

      "email": email,

      "photoUrl": photoUrl,

      "totalStudents":
          totalStudents,
    };
  }

  factory TutorModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return TutorModel(

      id:
          map["id"] ?? "",

      name:
          map["name"] ?? "",

      email:
          map["email"] ?? "",

      photoUrl:
          map["photoUrl"] ?? "",

      totalStudents:
          (map["totalStudents"] ?? 0)
              as int,
    );
  }
}