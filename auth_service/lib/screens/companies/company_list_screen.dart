import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './company_service.dart';

class CompanyListScreen extends StatefulWidget {
  final Map<String, String> userAnswers;

  const CompanyListScreen({Key? key, required this.userAnswers}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final CompanyService _companyService = CompanyService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> companies = [];
  List<String> wishlist = []; // Entreprises favorites
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      final sortedCompanies = await _companyService.getSortedCompanies(widget.userAnswers);
      final user = _auth.currentUser;

      if (user != null) {
        final wishlistDoc = await FirebaseFirestore.instance.collection('wishlist').doc(user.uid).get();
        setState(() {
          companies = sortedCompanies;
          wishlist = wishlistDoc.exists ? List<String>.from(wishlistDoc['companyIds'] ?? []) : [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des recommandations : $e");
      setState(() {
        isLoading = false;
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

        // Déplacer l'entreprise en haut de la liste
        final company = companies.firstWhere((c) => c['company'] == companyId, orElse: () => {});
        if (company.isNotEmpty) {
          companies.remove(company);
          companies.insert(0, company);
        }
      }
    });

    await FirebaseFirestore.instance.collection('wishlist').doc(user.uid).set({
      'companyIds': wishlist,
    });
  }

  void showCompanyDetails(Map<String, dynamic> company) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final isFavorite = wishlist.contains(company['company']);
          return AlertDialog(
            title: Text(
              company['company'] ?? 'Détails de l\'entreprise',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Titre", company['title']),
                  _buildDetailRow("Localisation", company['location']),
                  _buildDetailRow("Salaire", company['compensation']),
                  _buildDetailRow("Date de publication", company['date']?.split('T')[0]),
                  _buildDetailRow("Niveau d'expérience requis", company['company_xp']),
                  _buildDetailRow("Expérience totale recommandée", company['total_xp']),
                  _buildDetailRow("Télétravail", company['remote']),
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
    } catch (e) {
      print("Erreur lors de l'affichage des détails : $e");
    }
  }

Widget _buildDetailRow(String label, dynamic value, {bool isBold = false}) {
  final displayValue = value is String
      ? value
      : value != null
          ? value.toString()
          : 'Non spécifié';

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
            displayValue,
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
        title: const Text('Recommandations d\'entreprises',style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/users');
            },
            tooltip: 'Voir la liste des utilisateurs',
            color: Colors.white,
            iconSize: 30,
            splashColor: Colors.lightBlueAccent,
            splashRadius: 25,
          ),
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
