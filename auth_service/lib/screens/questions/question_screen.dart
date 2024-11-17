import 'package:flutter/material.dart';
import 'question_service.dart';
import 'question_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_service/services/auth_service.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final QuestionService _questionService = QuestionService();
  final AuthService _authService = AuthService();
  String? currentQuestionId = 'q1'; // ID de la première question
  Question? currentQuestion;
  Map<String, String> userAnswers = {}; // Stocke les réponses utilisateur
  bool isLoading = true; // Indique si une opération est en cours

  // Charger une question à partir de son ID
  Future<void> loadQuestion(String questionId) async {
    setState(() {
      isLoading = true; // Activer le chargement
    });

    final question = await _questionService.getQuestion(questionId);
    setState(() {
      currentQuestion = question;
      currentQuestionId = questionId;
      isLoading = false; // Désactiver le chargement
    });
  }

  @override
  void initState() {
    super.initState();
    loadQuestion(currentQuestionId!);
  }

  // Vérifie si c'est la dernière question
  bool isLastQuestion(Question question) {
    return question.next == null || question.next!.values.every((value) => value == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Affiche le chargement
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentQuestion!.text,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...currentQuestion!.options.map((option) {
                    return ElevatedButton(
                      onPressed: () async {
                        // Stocker la réponse utilisateur
                        userAnswers[currentQuestionId!] = option;

                        if (isLastQuestion(currentQuestion!)) {
                          // Rediriger vers les suggestions si c'est la dernière question
                          if (!Navigator.of(context).canPop()) {
                            Navigator.pushReplacementNamed(context, '/companies', arguments: userAnswers);
                          }
                        } else {
                          // Charger la question suivante
                          final nextQuestionId = currentQuestion!.next![option];
                          if (nextQuestionId != null) {
                            await loadQuestion(nextQuestionId);
                          }
                        }
                      },
                      child: Text(option),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
