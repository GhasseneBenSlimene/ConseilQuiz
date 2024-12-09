import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAnswersScreen extends StatelessWidget {
  final String userId;

  const UserAnswersScreen({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, Map<String, dynamic>>> getQuestionsFromFirebase() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('questions').get();
    final questions = <String, Map<String, dynamic>>{};
    for (var doc in querySnapshot.docs) {
      questions[doc.id] = {
        'text': doc['text'] as String,
      };
    }
    return questions;
  }

  Future<Map<String, List<String>>> getQuestionOptionsFromFirebase() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('question_options').get();
    final questionOptions = <String, List<String>>{};
    for (var doc in querySnapshot.docs) {
      questionOptions[doc.id] = List<String>.from(doc['options'] as List);
    }
    return questionOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réponses de l\'utilisateur'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('user_answers').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final answers = data['answers'] as Map<String, dynamic>;

            return FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: getQuestionsFromFirebase(),
              builder: (context, questionSnapshot) {
                if (!questionSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final questionMap = questionSnapshot.data!;

                return FutureBuilder<Map<String, List<String>>>(
                  future: getQuestionOptionsFromFirebase(),
                  builder: (context, optionsSnapshot) {
                    if (!optionsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final optionsMap = optionsSnapshot.data!;

                    return ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final questionId = answers.keys.elementAt(index);
                        final question = questionMap[questionId] ?? {'text': 'Question inconnue'};
                        final questionText = question['text'];
                        final userAnswer = answers[questionId] ?? 'Non spécifié';
                        final options = optionsMap[questionId] ?? [];

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.white,
                          shadowColor: Colors.lightBlue,
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              questionText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            subtitle: Text(
                              'Réponse: $userAnswer',
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            leading: const Icon(
                              Icons.question_answer,
                              color: Colors.lightBlue,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(questionText),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: options.map((option) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: option == userAnswer
                                                ? Colors.greenAccent.withOpacity(0.5)
                                                : Colors.white,
                                            border: Border.all(
                                              color: option == userAnswer
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              color: option == userAnswer
                                                  ? Colors.black
                                                  : Colors.black54,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Fermer'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
