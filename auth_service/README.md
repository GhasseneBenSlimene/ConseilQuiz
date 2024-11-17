
### **Structure du Projet**
```
lib/
├── main.dart                  # Point d'entrée de l'application.
├── app/
│   ├── app.dart               # Configuration globale (thème, routes).
│   ├── routes.dart            # Définition des routes de navigation.
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart  # Écran de connexion.
│   │   ├── register_screen.dart # Écran d'inscription.
│   │   └── auth_controller.dart # Gestion de l'authentification.
│   ├── questions/
│   │   ├── question_screen.dart # Gestion de l'arbre des questions.
│   │   ├── question_controller.dart # Logique pour gérer les questions.
│   │   └── question_model.dart    # Modèle des questions.
│   ├── companies/
│   │   ├── company_list_screen.dart # Écran affichant les entreprises suggérées.
│   │   ├── company_controller.dart  # Logique pour gérer les suggestions.
│   │   └── company_model.dart       # Modèle des entreprises.
├── services/
│   ├── firebase_service.dart  # Configuration Firebase (Auth, Firestore, etc.).
│   ├── auth_service.dart      # Service pour l'authentification Firebase.
│   ├── question_service.dart  # Service pour interagir avec Firestore (questions).
│   └── company_service.dart   # Service pour interagir avec Firestore (entreprises).
├── widgets/
│   ├── custom_button.dart     # Widget pour les boutons réutilisables.
│   ├── custom_textfield.dart  # Widget pour les champs de texte réutilisables.
│   └── loading_indicator.dart # Widget pour les chargements.
└── utils/
    ├── constants.dart         # Constantes globales (couleurs, styles).
    └── helpers.dart           # Fonctions utilitaires (validation, navigation).
```

---

### **Détails des Composants**

#### **1. main.dart**
- Point d’entrée de l’application.
- Configure Firebase et initialise l’application.
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

---

#### **2. app/app.dart**
- Contient la configuration globale de l'application (thème, navigation).
```dart
import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: appRoutes,
    );
  }
}
```

---

#### **3. app/routes.dart**
- Définit les routes et la navigation entre les écrans.
```dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/questions/question_screen.dart';
import '../screens/companies/company_list_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/questions': (context) => const QuestionScreen(),
  '/companies': (context) => const CompanyListScreen(),
};
```

---

#### **4. screens/auth/**
- Contient les écrans liés à l'authentification.

- **login_screen.dart** :
  - Affiche un formulaire de connexion et appelle `AuthService` pour authentifier l'utilisateur.
- **register_screen.dart** :
  - Permet aux utilisateurs de s'inscrire et de sauvegarder leurs données dans Firestore.

---

#### **5. screens/questions/**
- Gère l’arbre des questions.

- **question_screen.dart** :
  - Affiche une question, ses options et récupère les réponses.
  - Passe à la question suivante en fonction des réponses.

- **question_controller.dart** :
  - Gère la logique pour récupérer les questions depuis Firestore et sauvegarder les réponses utilisateur.

---

#### **6. screens/companies/**
- Affiche les entreprises suggérées.

- **company_list_screen.dart** :
  - Liste les entreprises filtrées en fonction des réponses utilisateur.
  - Permet à l'utilisateur de sélectionner une entreprise.

- **company_controller.dart** :
  - Filtre les entreprises en utilisant les réponses utilisateur.

---

#### **7. services/**
- Contient les interactions avec Firebase.

- **firebase_service.dart** :
  - Configure Firebase Authentication, Firestore et Storage.
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
}
```

- **auth_service.dart** :
  - Gère les appels liés à l'authentification (inscription, connexion).
- **question_service.dart** :
  - Récupère les questions depuis Firestore et sauvegarde les réponses.
- **company_service.dart** :
  - Filtre les entreprises basées sur les réponses utilisateur.

---

#### **8. widgets/**
- Regroupe des composants réutilisables pour simplifier le développement.

- **custom_button.dart** :
  - Bouton réutilisable avec différentes couleurs et styles.
- **custom_textfield.dart** :
  - Champ de texte réutilisable pour les formulaires.

---

#### **9. utils/**
- Contient les constantes globales et les fonctions utilitaires.

- **constants.dart** :
  - Définit les couleurs, tailles, et styles utilisés dans toute l'application.
- **helpers.dart** :
  - Contient des fonctions d'aide (validation des emails, gestion des erreurs).

---

### **Étapes pour Intégrer le Travail de l'Équipe**

1. **Configuration Firebase** :
   - Partagez les fichiers `google-services.json` (Android) et `GoogleService-Info.plist` (iOS) entre les membres.
   - Configurez Firebase Authentication et Firestore.

2. **Modularité** :
   - Chaque membre travaille sur un module spécifique (`auth`, `questions`, ou `companies`).
   - Utilisez des interfaces claires (comme les services `auth_service`, `question_service`, et `company_service`) pour garantir que les modules s’intègrent facilement.

3. **Réunification** :
   - Une fois chaque module terminé, intégrez-les via les routes définies dans `routes.dart`.
   - Testez les interactions entre les modules (authentification → questions → suggestions d'entreprises).
