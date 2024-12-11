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
    if (question.scale == null || question.scale!.isEmpty) {
      return const Text(
        "Erreur : Échelle Likert non disponible.",
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: question.scale!.map((option) {
            final isSelected = selectedOption == option;

            return GestureDetector(
              onTap: () {
                onOptionSelected(option);
              },
              child: Column(
                children: [
                  Text(option),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
