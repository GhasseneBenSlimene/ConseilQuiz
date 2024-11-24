import 'package:flutter/material.dart';
import '../question_model.dart';


class SingleChoiceQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const SingleChoiceQuestion({
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...question.options!.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedOption,
            onChanged: (value) => onOptionSelected(value!),
          );
        }).toList(),
      ],
    );
  }
}