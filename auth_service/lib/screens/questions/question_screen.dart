import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../companies/company_list_screen.dart';
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
  int totalQuestions = 0; // Nombre total de questions pour la progression

  @override
  void initState() {
    super.initState();
    loadLastQuestion(); // Charger la dernière question sauvegardée
    loadTotalQuestions(); // Charger le nombre total de questions
  }

  // Charger la dernière question sauvegardée ou commencer par q1
  Future<void> loadLastQuestion() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
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
    } catch (e) {
      print('Erreur lors du chargement de la progression : $e');
      setState(() {
        currentQuestionId = 'q1';
      });
    }
  }

  // Charger le nombre total de questions pour la barre de progression
  Future<void> loadTotalQuestions() async {
    try {
      final questionsSnapshot = await _firestore.collection('questions').get();
      setState(() {
        totalQuestions = questionsSnapshot.docs.length;
      });
    } catch (e) {
      print('Erreur lors du chargement du nombre total de questions : $e');
    }
  }

  // Charger une question à partir de son ID
  Future<void> loadQuestion(String questionId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final question = await _questionService.getQuestion(questionId);
      setState(() {
        currentQuestion = question;
        currentQuestionId = questionId;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement de la question : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sauvegarder la réponse et la progression dans Firestore
  Future<void> saveProgress(String questionId, String answer, String? nextQuestionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      userAnswers[questionId] = answer;

      await _firestore.collection('user_answers').doc(user.uid).set({
        'answers': userAnswers,
        'currentQuestionId': nextQuestionId ?? questionId,
      });
    } catch (e) {
      print('Erreur lors de la sauvegarde de la progression : $e');
    }
  }

  // Vérifie si c'est la dernière question
  bool isLastQuestion(Question question) {
    // Vérifie si toutes les valeurs du champ `next` sont null ou si `next` est null
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
          : currentQuestion == null
              ? const Center(child: Text('Aucune question disponible.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Barre de progression
                      if (totalQuestions > 0)
                        LinearProgressIndicator(
                          value: userAnswers.length / totalQuestions,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blue,
                        ),
                      const SizedBox(height: 16),
                      // Texte de la question
                      Text(
                        currentQuestion?.text ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Options de réponse
                      ...?currentQuestion?.options.map((option) {
                        return ElevatedButton(
                          onPressed: () async {
                            final nextQuestionId = currentQuestion?.next?[option];

                            if (isLastQuestion(currentQuestion!)) {
                              // Sauvegarde finale et redirection
                              await saveProgress(currentQuestionId!, option, null);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanyListScreen(userAnswers: userAnswers),
                                ),
                              );
                            } else if (nextQuestionId != null) {
                              // Sauvegarder la progression et charger la prochaine question
                              await saveProgress(currentQuestionId!, option, nextQuestionId);
                              await loadQuestion(nextQuestionId);
                            } else {
                              // Si next est null, sauvegarder et rediriger vers les entreprises
                              await saveProgress(currentQuestionId!, option, null);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanyListScreen(userAnswers: userAnswers),
                                ),
                              );
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
