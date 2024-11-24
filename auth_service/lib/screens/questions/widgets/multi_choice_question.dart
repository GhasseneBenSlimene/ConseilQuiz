import 'package:flutter/material.dart';
import '../question_model.dart';

class MultiChoiceQuestion extends StatelessWidget {
  final Question question;
  final List<String> selectedOptions;
  final Function(List<String>) onOptionsSelected;

  const MultiChoiceQuestion({
    required this.question,
    required this.selectedOptions,
    required this.onOptionsSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> currentSelection = List<String>.from(selectedOptions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...question.options!.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: currentSelection.contains(option),
            onChanged: (value) {
              if (value == true) {
                currentSelection.add(option);
              } else {
                currentSelection.remove(option);
              }
              onOptionsSelected(currentSelection);
            },
          );
        }).toList(),
        ElevatedButton(
          onPressed: () => onOptionsSelected(currentSelection),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
