class CBTMicroLesson {
  final String id;
  final String text;

  CBTMicroLesson({required this.id, required this.text});

  factory CBTMicroLesson.fromJson(Map<String, dynamic> json) {
    return CBTMicroLesson(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }
}
