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
  List<String> questionHistory = []; // Historique des questions
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion(currentQuestionId!);
  }

  // Charger une question par ID
  Future<void> _loadQuestion(String questionId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final question = await _questionService.getQuestion(questionId);
      setState(() {
        currentQuestion = question;
        currentQuestionId = questionId;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement de la question : $e");
      setState(() {
        currentQuestion = null;
        currentQuestionId = null;
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Sauvegarder une réponse
  Future<void> _saveAnswer(String answer) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      userAnswers[currentQuestionId!] = answer; // Met à jour localement immédiatement
    });

    await _questionService.saveUserAnswer(user.uid, currentQuestionId!, answer);
  }

  // Charger la question suivante
  Future<void> _nextQuestion() async {
    if (!questionHistory.contains(currentQuestionId!)) {
      questionHistory.add(currentQuestionId!);
    }

    final nextQuestionId =
        currentQuestion?.next?[userAnswers[currentQuestionId!] ?? ''] ??
            currentQuestion?.next?['default'];

    if (nextQuestionId != null) {
      await _loadQuestion(nextQuestionId);
    } else {
      Navigator.pushReplacementNamed(context, '/end');
    }
  }

  // Charger la question précédente
  Future<void> _previousQuestion() async {
    if (questionHistory.isEmpty) return;

    final previousQuestionId = questionHistory.removeLast();

    if (previousQuestionId != null) {
      await _loadQuestion(previousQuestionId);
    }
  }

  // Construire une question en fonction de son type
  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: (value) => _saveAnswer(value),
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
          onOptionSelected: (value) => _saveAnswer(value),
        );
      case 'dropdown':
        return DropdownQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: (value) => _saveAnswer(value),
        );
      case 'matrix_table':
        return MatrixTableQuestion(
          question: question,
          responses: userAnswers[question.id] != null
              ? Map.fromEntries(
                  (userAnswers[question.id]!.split(';')).map((entry) {
                    final parts = entry.split(':');
                    return MapEntry(parts[0], parts[1]);
                  }),
                )
              : {}, // Si pas de réponse, initialiser un map vide
          onResponsesSubmitted: (responses) {
            final formattedResponse = responses.entries
                .map((entry) => '${entry.key}:${entry.value}')
                .join(';');
            _saveAnswer(formattedResponse);
          },
        );
      default:
        return const Text('Type de question non pris en charge');
    }
  }

  // Vérifier si c'est la dernière question
  bool isLastQuestion(Question? question) {
    if (question == null) return false;
    return question.next != null && question.next!['default'] == "end";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: questionHistory.isEmpty
                                    ? null
                                    : _previousQuestion,
                                child: const Text('Précédent'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (isLastQuestion(currentQuestion)) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/companies',
                                      arguments: userAnswers, // Passer les réponses utilisateur
                                    );
                                  } else {
                                    _nextQuestion(); // Naviguer à la question suivante
                                  }
                                },
                                child: Text(isLastQuestion(currentQuestion) ? 'Voir les recommandations' : 'Suivant'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }
}