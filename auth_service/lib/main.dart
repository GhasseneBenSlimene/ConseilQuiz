import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/questions/question_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  checkFirebase();
  
  // Décommenter les lignes ci-dessous pour ajouter des questions
  // final seeder = QuestionSeeder();
  // await seeder.seedQuestions();

  // Décommenter les lignes ci-dessous pour ajouter des entreprises
  // final seeder = CompanySeeder();
  // await seeder.seedCompanies();

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
        "id": "q1",
        "text": "Quel secteur d'activité préférez-vous ?",
        "type": "single_choice",
        "options": ["Développement", "Réseaux", "IA"],
        "next": {
            "Développement": "q2",
            "Réseaux": "q2",
            "IA": "q3"
        }
    },
    {
        "id": "q2",
        "text": "Quel type de projet préférez-vous ?",
        "type": "single_choice",
        "options": ["Projets d’équipe", "Travail individuel", "Recherche"],
        "next": {
            "default": "q4"
        }
    },
    {
        "id": "q3",
        "text": "Quel domaine de l'IA souhaitez-vous explorer ?",
        "type": "single_choice",
        "options": ["Vision par ordinateur", "Traitement du langage naturel", "Robots"],
        "next": {
            "default": "q2"
        }
    },
    {
        "id": "q4",
        "text": "Préférez-vous travailler sur site, en télétravail complet, ou hybride ?",
        "type": "single_choice",
        "options": ["Sur site", "Hybride", "Télétravail complet"],
        "next": {
            "Sur site": "q5",
            "Hybride": "q5",
            "Télétravail complet": "q6"
        }
    },
    {
        "id": "q5",
        "text": "Dans quelle localisation souhaitez-vous travailler ?",
        "type": "dropdown",
        "options": ["Paris", "Bordeaux", "Lyon", "Toulouse", "Remote"],
        "next": {
            "default": "q7"
        }
    },
    {
        "id": "q6",
        "text": "Quelle est votre priorité pour le télétravail ?",
        "type": "single_choice",
        "options": ["Flexibilité horaire", "Outils collaboratifs efficaces", "Primes liées au télétravail"],
        "next": {
            "default": "q7"
        }
    },
    {
        "id": "q7",
        "text": "Quel niveau de poste recherchez-vous ?",
        "type": "single_choice",
        "options": ["Junior", "Mid-Level", "Senior"],
        "next": {
            "default": "q8"
        }
    },
    {
        "id": "q8",
        "text": "Quel intitulé de poste recherchez-vous ?",
        "type": "single_choice",
        "options": ["Développeur FullStack", "Ingénieur Réseaux", "Data Scientist", "Autre"],
        "next": {
            "default": "q9"
        }
    },
    {
        "id": "q9",
        "text": "Quel est votre salaire brut minimum attendu (€ / an) ?",
        "type": "single_choice",
        "options": ["< 30 000 €", "30 000 € - 50 000 €", "> 50 000 €"],
        "next": {
            "default": "q10"
        }
    },
    {
        "id": "q10",
        "text": "Quelle est votre expérience totale en années ?",
        "type": "likert_scale",
        "scale": ["0 ans", "1-2 ans", "3-5 ans", "6-10 ans", "10+ ans"],
        "next": {
            "default": "q11"
        }
    },
    {
        "id": "q11",
        "text": "Combien d'années d'expérience en entreprise avez-vous ?",
        "type": "likert_scale",
        "scale": ["0 ans", "1-2 ans", "3-5 ans", "6-10 ans", "10+ ans"],
        "next": {
            "default": "q12"
        }
    },
    {
        "id": "q12",
        "text": "Quelle est votre spécialisation principale ?",
        "type": "single_choice",
        "options": ["Gestion de projets", "Développement avancé", "Recherche et innovation"],
        "next": {
            "default": "q13"
        }
    },
    {
        "id": "q13",
        "text": "Quelles compétences souhaitez-vous développer dans votre prochain poste ?",
        "type": "multi_choice",
        "options": ["Leadership", "Techniques avancées", "Travail collaboratif"],
        "next": {
            "default": "q14"
        }
    },
    {
        "id": "q14",
        "text": "Comment évaluez-vous les critères suivants en termes d'importance pour votre poste idéal ?",
        "type": "matrix_table",
        "matrixOptions": {
            "Critères": ["Localisation", "Rémunération", "Télétravail", "Opportunités de carrière", "Ambiance de travail"],
            "Échelle": ["Pas important", "Peu important", "Important", "Très important", "Essentiel"]
        },
        "next": {
            "default": "q15"
        }
    },
    {
        "id": "q15",
        "text": "Quel critère est le plus important pour vous ?",
        "type": "single_choice",
        "options": ["Localisation", "Salaire", "Poste souhaité", "Télétravail"],
        "next": {
            "default": "q16"
        }
    },
    {
        "id": "q16",
        "text": "Quelle modalité supplémentaire améliorerait votre bien-être au travail ?",
        "type": "multi_choice",
        "options": ["Horaires flexibles", "Formation continue", "Soutien pour le télétravail"],
        "next": {
            "default": "end"
        }
    }
];

    for (var question in questions) {
      await _firestore.collection('questions').doc(question['id'] as String?).set({
        "text": question["text"],
        "options": question["options"],
        "type": question["type"],
        "next": question["next"],
        "matrixOptions": question["matrixOptions"],
        "scale": question["scale"],
      });
      print("Added question: ${question['id']}");
    }

    print("All questions added successfully!");
  }
}

class CompanySeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedCompanies() async {
    final companies = [
      {
        "company": "ASE2I",
        "title": null,
        "location": "Entzheim",
        "compensation": 30000,
        "date": "2022-07-05T00:00:00.000Z",
        "level": null,
        "company_xp": 0,
        "total_xp": 0,
        "remote": null
      },
      // Ajoutez les autres entreprises ici
    ];

    for (var company in companies) {
      await _firestore.collection('companies').add(company);
    }

    print("Companies added successfully!");
  }
}