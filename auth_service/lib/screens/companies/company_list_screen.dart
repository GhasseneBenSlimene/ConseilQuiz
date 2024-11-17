import 'package:flutter/material.dart';
import 'company_service.dart';

class CompanyListScreen extends StatefulWidget {
  final Map<String, String> userAnswers;

  const CompanyListScreen({Key? key, required this.userAnswers}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final CompanyService _companyService = CompanyService();
  List<Map<String, dynamic>> companies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    final sortedCompanies = await _companyService.getSortedCompanies(widget.userAnswers);
    setState(() {
      companies = sortedCompanies;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entreprises suggérées')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  title: Text(company['company'] ?? 'N/A'),
                  subtitle: Text(
                      "Localisation: ${company['location'] ?? 'N/A'}, Salaire: ${company['compensation'] ?? 'N/A'}"),
                );
              },
            ),
    );
  }
}
