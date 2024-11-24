import 'package:flutter/material.dart';
import '../question_model.dart';

class MatrixTableQuestion extends StatelessWidget {
  final Question question;
  final Map<String, String> responses;
  final Function(Map<String, String>) onResponsesSubmitted;

  const MatrixTableQuestion({
    required this.question,
    required this.responses,
    required this.onResponsesSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String> localResponses = Map<String, String>.from(responses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...question.matrixOptions!['Critères']!.map((criterion) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                criterion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: question.matrixOptions!['Échelle']!.map((option) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(option, style: const TextStyle(fontSize: 10)),
                      value: option,
                      groupValue: localResponses[criterion],
                      onChanged: (value) {
                        localResponses[criterion] = value!;
                        onResponsesSubmitted(localResponses);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
        ElevatedButton(
          onPressed: () => onResponsesSubmitted(localResponses),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
