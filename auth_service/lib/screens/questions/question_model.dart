class Question {
  final String id;
  final String text;
  final String type;
  final List<String>? options; // Pour single_choice, multi_choice, dropdown
  final List<String>? scale; // Pour likert_scale
  final Map<String, List<String>>? matrixOptions; // Pour matrix_table
  final Map<String, String>? next;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.scale,
    this.matrixOptions,
    this.next,
  });

  factory Question.fromFirestore(id, Map<String, dynamic> data) {
    return Question(
      id: id as String,
      text: data['text'] as String,
      type: data['type'] as String,
      options: data['options'] != null
          ? List<String>.from(data['options'])
          : null,
      scale: data['scale'] != null
          ? List<String>.from(data['scale'])
          : null,
      matrixOptions: data['matrixOptions'] != null
          ? (data['matrixOptions'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                List<String>.from(value),
              ),
            )
          : null,
      next: data['next'] != null
          ? Map<String, String>.from(data['next'])
          : null,
    );
  }
}
