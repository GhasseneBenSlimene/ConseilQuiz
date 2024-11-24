import 'package:flutter/material.dart';
import '../question_model.dart';

class DropdownQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const DropdownQuestion({
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: const Text('Choisissez une option'),
      value: selectedOption,
      onChanged: (value) => onOptionSelected(value!),
      items: question.options!.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }
}
