import 'package:cloud_firestore/cloud_firestore.dart';
import './question_model.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Charger une question par ID avec gestion des erreurs
  Future<Question> getQuestion(String id) async {
    try {
      final doc = await _firestore.collection('questions').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception("Question avec l'ID $id introuvable.");
      }
      final data = doc.data()!;
      return Question.fromFirestore(doc.id, data);
    } catch (e) {
      throw Exception("question_service: Erreur lors du chargement de la question : $e");
    }
  }

  // Charger toutes les questions
  Future<List<Question>> getAllQuestions() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      return snapshot.docs
          .map((doc) => Question.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erreur lors du chargement des questions : $e");
    }
  }

  // Enregistrer les réponses utilisateur
  Future<void> saveUserAnswer(
      String userId, String questionId, String answer) async {
    try {
      final userDoc = _firestore.collection('user_answers').doc(userId);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        await userDoc.update({
          'answers.$questionId': answer,
        });
      } else {
        await userDoc.set({
          'answers': {questionId: answer},
        });
      }
    } catch (e) {
      throw Exception("Erreur lors de la sauvegarde de la réponse : $e");
    }
  }
}