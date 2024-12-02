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

    // Ajouter des points en fonction de la localisation
    if (userAnswers['q5'] == company['location']) {
      score += 10;
    }

    // Ajouter des points en fonction de l'expérience totale requise
    if (company['total_xp'] != null) {
      int userXp = _parseExperience(userAnswers['q11'] ?? '0-0 ans');
      if (userXp >= company['total_xp']) {
        score += 5;
      }
    }
    print("scoreeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:$score");
    // Ajoutez plus de conditions ici en fonction des besoins
    return score;
  }

  // Méthode pour analyser l'expérience utilisateur
  int _parseExperience(String experience) {
    final match = RegExp(r'(\d+)-(\d+) ans').firstMatch(experience);
    if (match != null) {
      int minXp = int.parse(match.group(1)!);
      int maxXp = int.parse(match.group(2)!);
      return (minXp + maxXp) ~/ 2; // Retourner la moyenne de l'expérience
    }
    return 0;
  }
}