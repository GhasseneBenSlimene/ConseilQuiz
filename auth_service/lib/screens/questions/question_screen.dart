import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './question_model.dart';
import './question_service.dart';
import './widgets/single_choice_question.dart';
import './widgets/multi_choice_question.dart';
import './widgets/likert_scale_question.dart';
import './widgets/matrix_table_question.dart';
import './widgets/dropdown_question.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentQuestionId = 'q1';
  Question? currentQuestion;
  Map<String, String> userAnswers = {};
  bool isLoading = true;
  bool hasError = false; // Indicateur d'erreur

  @override
  void initState() {
    super.initState();
    _loadQuestion(currentQuestionId!);
  }

  // Charger une question par ID avec gestion des erreurs
  Future<void> _loadQuestion(String questionId) async {
    setState(() {
      isLoading = true;
      hasError = false; // Réinitialiser l'état d'erreur
    });

    try {
      final question = await _questionService.getQuestion(questionId);
      setState(() {
        currentQuestion = question;
        currentQuestionId = questionId;
        isLoading = false;
      });
    } catch (e) {
      print("question_screen: Erreur lors du chargement de la question : $e");
      setState(() {
        currentQuestion = null;
        currentQuestionId = null;
        isLoading = false;
        hasError = true; // Définir l'état d'erreur
      });
    }
  }

  // Sauvegarder la réponse utilisateur
  Future<void> _saveAnswer(String answer) async {
    final user = _auth.currentUser;
    if (user == null) return;

    userAnswers[currentQuestionId!] = answer;

    await _questionService.saveUserAnswer(user.uid, currentQuestionId!, answer);

    String? nextQuestionId = currentQuestion?.next?[answer] ?? currentQuestion?.next?['default'];

    if (nextQuestionId != null) {
      await _loadQuestion(nextQuestionId);
    } else {
      Navigator.pushReplacementNamed(context, '/end');
    }
  }

  // Construire une question en fonction de son type
  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: _saveAnswer,
        );
      case 'multi_choice':
        return MultiChoiceQuestion(
          question: question,
          selectedOptions: userAnswers[question.id]?.split(',') ?? [],
          onOptionsSelected: (options) => _saveAnswer(options.join(',')),
        );
      case 'likert_scale':
        return LikertScaleQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: _saveAnswer,
        );
      case 'matrix_table':
        return MatrixTableQuestion(
          question: question,
          responses: {},
          onResponsesSubmitted: (responses) => _saveAnswer(
            responses.entries.map((e) => '${e.key}:${e.value}').join(';'),
          ),
        );
      case 'dropdown':
        return DropdownQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: _saveAnswer,
        );
      default:
        return const Text('Type de question non pris en charge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Erreur : Impossible de charger la question.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadQuestion(currentQuestionId ?? 'q1'),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : currentQuestion == null
                  ? const Center(
                      child: Text(
                        'Erreur : Question non disponible.',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            currentQuestion!.text,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildQuestion(currentQuestion!),
                        ],
                      ),
                    ),
    );
  }
}