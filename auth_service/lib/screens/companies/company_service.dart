import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les entreprises triées
  Future<List<Map<String, dynamic>>> getSortedCompanies(Map<String, String> userAnswers) async {
    final querySnapshot = await _firestore.collection('companies').get();

    // Filtrer et trier les entreprises
    final companies = querySnapshot.docs.map((doc) => doc.data()).toList();

    companies.sort((a, b) {
      int scoreA = _calculateScore(a, userAnswers);
      int scoreB = _calculateScore(b, userAnswers);
      return scoreB.compareTo(scoreA); // Trier par score décroissant
    });

    // Retourner les 20 premières entreprises
    return companies.take(20).toList();
  }

  // Calculer le score pour chaque entreprise en fonction des réponses utilisateur
  int _calculateScore(Map<String, dynamic> company, Map<String, String> userAnswers) {
    int score = 0;

    // Exemple : Ajouter des points en fonction de la localisation
    if (userAnswers['location'] == company['location']) {
      score += 10;
    }

    // Exemple : Ajouter des points en fonction de l'expérience totale requise
    if (company['total_xp'] != null && int.parse(userAnswers['experience'] ?? '0') >= company['total_xp']) {
      score += 5;
    }

    // Ajoutez plus de conditions ici en fonction des besoins
    return score;
  }
}
