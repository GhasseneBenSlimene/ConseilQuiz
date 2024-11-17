import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_service.dart';
import 'question_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentQuestionId; // ID de la question actuelle
  Question? currentQuestion; // Détails de la question actuelle
  Map<String, String> userAnswers = {}; // Stocke les réponses utilisateur
  bool isLoading = true; // Indique si l'application charge une question

  @override
  void initState() {
    super.initState();
    loadLastQuestion(); // Charger la dernière question sauvegardée
  }

  // Charger la dernière question sauvegardée ou commencer par q1
  Future<void> loadLastQuestion() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('user_answers').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      setState(() {
        currentQuestionId = data?['currentQuestionId'] ?? 'q1';
        userAnswers = Map<String, String>.from(data?['answers'] ?? {});
      });
    } else {
      setState(() {
        currentQuestionId = 'q1'; // Si aucune donnée, commencer par q1
      });
    }
    await loadQuestion(currentQuestionId!);
  }

  // Charger une question à partir de son ID
  Future<void> loadQuestion(String questionId) async {
    setState(() {
      isLoading = true;
    });

    final question = await _questionService.getQuestion(questionId);
    setState(() {
      currentQuestion = question;
      currentQuestionId = questionId;
      isLoading = false;
    });
  }

  // Sauvegarder la réponse et la progression dans Firestore
  Future<void> saveProgress(String questionId, String answer, String? nextQuestionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    userAnswers[questionId] = answer;

    await _firestore.collection('user_answers').doc(user.uid).set({
      'answers': userAnswers,
      'currentQuestionId': nextQuestionId ?? questionId,
    });
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
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        final nextQuestionId = currentQuestion!.next?[option];

                        // Sauvegarder la réponse et la progression
                        await saveProgress(currentQuestionId!, option, nextQuestionId);

                        // Rediriger ou charger la question suivante
                        if (isLastQuestion(currentQuestion!)) {
                          Navigator.pushReplacementNamed(context, '/companies', arguments: userAnswers);
                        } else if (nextQuestionId != null) {
                          await loadQuestion(nextQuestionId);
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
