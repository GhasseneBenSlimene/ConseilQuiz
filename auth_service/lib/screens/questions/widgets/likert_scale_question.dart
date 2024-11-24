import 'package:flutter/material.dart';
import '../question_model.dart';

class LikertScaleQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const LikertScaleQuestion({
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
        ...question.scale!.map((scaleOption) {
          return RadioListTile<String>(
            title: Text(scaleOption),
            value: scaleOption,
            groupValue: selectedOption,
            onChanged: (value) => onOptionSelected(value!),
          );
        }).toList(),
      ],
    );
  }
}
