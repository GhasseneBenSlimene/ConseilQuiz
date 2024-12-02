import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_service.dart';

class CompanyListScreen extends StatefulWidget {
  final Map<String, String> userAnswers;

  const CompanyListScreen({Key? key, required this.userAnswers}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final CompanyService _companyService = CompanyService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> companies = [];
  bool isLoading = true;
  List<String> wishlist = []; // Liste des entreprises favoris

  @override
  void initState() {
    super.initState();
    loadCompanies();
    loadWishlist();
  }

  Future<void> loadCompanies() async {
    final sortedCompanies = await _companyService.getSortedCompanies(widget.userAnswers);
    setState(() {
      companies = sortedCompanies;
      isLoading = false;
    });
  }

  Future<void> loadWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final wishlistDoc = await _firestore.collection('wishlist').doc(user.uid).get();
    if (wishlistDoc.exists) {
      setState(() {
        wishlist = List<String>.from(wishlistDoc['companyIds'] ?? []);
      });
    }
  }

  Future<void> toggleWishlist(String companyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      if (wishlist.contains(companyId)) {
        wishlist.remove(companyId);
      } else {
        wishlist.add(companyId);
      }
    });

    await _firestore.collection('wishlist').doc(user.uid).set({
      'companyIds': wishlist,
    });
  }

  void showCompanyDetails(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isFavorite = wishlist.contains(company['company']); // Vérifier si c'est dans les favoris
        return AlertDialog(
          title: Text(
            company['company'] ?? 'Détails de l\'entreprise',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Titre", company['title'] ?? 'Non spécifié', isBold: true),
                _buildDetailRow("Localisation", company['location'] ?? 'Non spécifiée'),
                _buildDetailRow("Salaire", "${company['compensation'] ?? 'Non spécifié'} €"),
                _buildDetailRow("Date de publication", company['date']?.split('T')[0] ?? 'Non spécifiée'),
                _buildDetailRow("Niveau d'expérience requis", "${company['company_xp'] ?? 'Non spécifié'} ans"),
                _buildDetailRow("Expérience totale recommandée", "${company['total_xp'] ?? 'Non spécifié'} ans"),
                _buildDetailRow("Télétravail", company['remote'] ?? 'Non spécifié'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                toggleWishlist(company['company']);
                Navigator.of(context).pop();
              },
              child: Text(
                isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises suggérées'),
        backgroundColor: Colors.blueAccent,
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
          : ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                final isFavorite = wishlist.contains(company['company']);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      company['company'] ?? 'Nom de l\'entreprise',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Localisation : ${company['location'] ?? 'N/A'}"),
                        Text("Salaire : ${company['compensation'] ?? 'N/A'} €"),
                        Text("Expérience requise : ${company['company_xp'] ?? 'N/A'} ans"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            toggleWishlist(company['company']);
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                      ],
                    ),
                    onTap: () => showCompanyDetails(company),
                  ),
                );
              },
            ),
    );
  }
}
