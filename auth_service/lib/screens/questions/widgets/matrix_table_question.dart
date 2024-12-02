import 'package:flutter/material.dart';
import '../question_model.dart';

class MatrixTableQuestion extends StatefulWidget {
  final Question question;
  final Map<String, String> responses; // Réponses sauvegardées
  final Function(Map<String, String>) onResponsesSubmitted;

  const MatrixTableQuestion({
    Key? key,
    required this.question,
    required this.responses,
    required this.onResponsesSubmitted,
  }) : super(key: key);

  @override
  _MatrixTableQuestionState createState() => _MatrixTableQuestionState();
}

class _MatrixTableQuestionState extends State<MatrixTableQuestion> {
  late Map<String, String> _responses;

  @override
  void initState() {
    super.initState();
    // Initialiser les réponses avec celles existantes (si disponibles)
    _responses = Map<String, String>.from(widget.responses);
  }

  void _updateResponse(String critere, String value) {
    setState(() {
      _responses[critere] = value;
    });
    widget.onResponsesSubmitted(_responses); // Sauvegarder immédiatement
  }

  @override
  Widget build(BuildContext context) {
    final matrixOptions = widget.question.matrixOptions!;
    final criteres = matrixOptions['Critères']!;
    final echelle = matrixOptions['Échelle']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FlexColumnWidth(2),
            for (int i = 1; i <= echelle.length; i++) i: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Critères', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...echelle.map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e, textAlign: TextAlign.center),
                    )),
              ],
            ),
            ...criteres.map((critere) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(critere),
                  ),
                  ...echelle.map((option) {
                    return Radio<String>(
                      value: option,
                      groupValue: _responses[critere], // Charger la réponse sauvegardée
                      onChanged: (value) {
                        _updateResponse(critere, value!);
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
