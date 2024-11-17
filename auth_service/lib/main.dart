import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/questions/question_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  checkFirebase();
  
  // Décommenter les lignes ci-dessous pour ajouter des questions
  // final seeder = QuestionSeeder();
  // await seeder.seedQuestions();

  runApp(const MyApp());
}

void checkFirebase() {
  print("Firebase initialisé : ${Firebase.apps.isNotEmpty}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Auth & Questions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Écran initial de l'application
      initialRoute: '/login',
      // Définition des routes globales
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/questions': (context) => const QuestionScreen(),
        // '/companies': (context) => const CompanyListScreen(),
      },
    );
  }
}

// Classe utilisée pour l'ajout des questions à Firebase
class QuestionSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedQuestions() async {
    final questions = [
      {
        "id": "q3",
        "text": "Quel domaine des réseaux vous intéresse le plus ?",
        "options": ["Sécurité", "Administration", "Télécommunications"],
        "next": {
          "Sécurité": "q8",
          "Administration": "q9",
          "Télécommunications": "q10"
        }
      },
      {
        "id": "q4",
        "text": "Quel domaine de l’IA souhaitez-vous explorer ?",
        "options": ["Vision par ordinateur", "Traitement du langage naturel", "Robots"],
        "next": {
          "Vision par ordinateur": "q11",
          "Traitement du langage naturel": "q12",
          "Robots": "q13"
        }
      },
      {
        "id": "q5",
        "text": "Quelle technologie utilisez-vous ?",
        "options": ["React", "Angular", "Vue.js"],
        "next": {"React": null, "Angular": null, "Vue.js": null}
      }
    ];

    for (var question in questions) {
      await _firestore.collection('questions').doc(question['id'] as String?).set({
        "text": question["text"],
        "options": question["options"],
        "next": question["next"],
      });
      print("Added question: ${question['id']}");
    }

    print("All questions added successfully!");
  }
}
