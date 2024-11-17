class Question {
  final String id;
  final String text;
  final List<String> options;
  final Map<String, String>? next;

  Question({
    required this.id,
    required this.text,
    required this.options,
    this.next,
  });

  // Méthode pour convertir un document Firestore en modèle Question
  factory Question.fromMap(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      text: data['text'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      next: Map<String, String>.from(data['next'] ?? {}),
    );
  }
}
