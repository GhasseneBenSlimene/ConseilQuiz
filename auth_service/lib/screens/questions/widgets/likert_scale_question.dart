import 'package:flutter/material.dart';
import '../question_model.dart';

class LikertScaleQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const LikertScaleQuestion({
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: question.scale!.map((option) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(option, textAlign: TextAlign.center),
                value: option,
                groupValue: selectedOption,
                onChanged: (value) => onOptionSelected(value!),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}