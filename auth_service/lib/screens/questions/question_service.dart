import 'package:cloud_firestore/cloud_firestore.dart';
import './question_model.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer une question par son ID
  Future<Question?> getQuestion(String questionId) async {
    final doc = await _firestore.collection('questions').doc(questionId).get();

    if (doc.exists) {
      return Question.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
