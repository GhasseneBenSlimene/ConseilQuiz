import 'package:flutter/material.dart';
import '../question_model.dart';

class DropdownQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const DropdownQuestion({
    Key? key,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
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
        DropdownButton<String>(
          isExpanded: true,
          value: selectedOption,
          hint: const Text("Sélectionnez une option"),
          items: question.options!
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) => onOptionSelected(value!),
        ),
      ],
    );
  }
}
