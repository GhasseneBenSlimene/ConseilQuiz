class Question {
  final String id;
  final String text;
  final String type;
  final List<String>? options;
  final Map<String, String>? next;
  final List<String>? scale;
  final Map<String, List<String>>? matrixOptions;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.next,
    this.scale,
    this.matrixOptions,
  });

  // Convertir un document Firestore en Question avec validation
  factory Question.fromFirestore(String id, Map<String, dynamic> data) {
    if (!data.containsKey('type') || data['type'] == null) {
      throw Exception("Type manquant ou null dans les données Firebase.");
    }
    if (!data.containsKey('text') || data['text'] == null) {
      throw Exception("Texte de la question manquant ou null.");
    }

    return Question(
      id: id,
      text: data['text'],
      type: data['type'],
      options: List<String>.from(data['options'] ?? []),
      next: Map<String, String>.from(data['next'] ?? {}),
      scale: List<String>.from(data['scale'] ?? []),
      matrixOptions: data['matrixOptions'] != null
          ? Map<String, List<String>>.from((data['matrixOptions'] as Map)
              .map((key, value) => MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}