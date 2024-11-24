import 'package:flutter/material.dart';
import '../question_model.dart';

class MatrixTableQuestion extends StatelessWidget {
  final Question question;
  final Map<String, String> responses;
  final Function(Map<String, String>) onResponsesSubmitted;

  const MatrixTableQuestion({
    Key? key,
    required this.question,
    required this.responses,
    required this.onResponsesSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Critères"),
                ),
                ...question.scale!.map((scale) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(scale),
                  );
                }).toList(),
              ],
            ),
            ...question.matrixOptions!.entries.map((entry) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entry.key),
                  ),
                  ...entry.value.map((option) {
                    return Radio<String>(
                      value: option,
                      groupValue: responses[entry.key],
                      onChanged: (value) {
                        responses[entry.key] = value!;
                        onResponsesSubmitted(responses);
                      },
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
