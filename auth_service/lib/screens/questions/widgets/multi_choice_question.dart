import 'package:flutter/material.dart';
import '../question_model.dart';

class MultiChoiceQuestion extends StatefulWidget {
  final Question question;
  final List<String> selectedOptions;
  final Function(List<String>) onOptionsSelected;

  const MultiChoiceQuestion({
    Key? key,
    required this.question,
    required this.selectedOptions,
    required this.onOptionsSelected,
  }) : super(key: key);

  @override
  _MultiChoiceQuestionState createState() => _MultiChoiceQuestionState();
}

class _MultiChoiceQuestionState extends State<MultiChoiceQuestion> {
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget.selectedOptions;
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
    widget.onOptionsSelected(_selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.question.options!.map((option) {
        return CheckboxListTile(
          title: Text(option),
          value: _selectedOptions.contains(option),
          onChanged: (value) => _toggleOption(option),
        );
      }).toList(),
    );
  }
}