class RapidQuestionModel {
  final int level;
  final String title;
  final String story;
  final String audioUrl;
  final String imageUrl;
  final List<Map<String, dynamic>> questions;

  RapidQuestionModel({
    required this.level,
    required this.title,
    required this.story,
    required this.audioUrl,
    required this.imageUrl,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      "level": level,
      "title": title,
      "story": story,
      "audioUrl": audioUrl,
      "imageUrl": imageUrl,
      "questions": questions,
    };
  }

  factory RapidQuestionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return RapidQuestionModel(
      level: map["level"] ?? 1,
      title: map["title"] ?? "",
      story: map["story"] ?? "",
      audioUrl: map["audioUrl"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      questions: List<Map<String, dynamic>>.from(
        map["questions"] ?? [],
      ),
    );
  }
}