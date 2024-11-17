import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow; // Lancer une exception en cas d'erreur
    }
  }

  // Vérifier si un utilisateur est connecté
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
