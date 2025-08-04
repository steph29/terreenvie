# Guide du Développeur - Terre en Vie

## 🚀 Configuration de l'environnement

### Prérequis

- Flutter SDK 3.0+
- Dart SDK
- Android Studio / VS Code
- Git

### Configuration Firebase

1. Créer un projet Firebase
2. Activer Authentication, Firestore, Cloud Messaging
3. Télécharger les fichiers de configuration :
   - `google-services.json` pour Android
   - `GoogleService-Info.plist` pour iOS

## 📁 Structure du Projet

```
lib/
├── api/                    # Services API
│   ├── firebase_api.dart   # Configuration Firebase
│   ├── fcm_service.dart    # Service notifications
│   └── template_service.dart # Templates notifications
├── controller/             # Pages et widgets
│   ├── Analyse.dart        # Page analytics
│   ├── RadarChartScreen.dart # Graphe radar
│   ├── RadarchartWidget.dart # Widget radar
│   ├── kikeou.dart         # Page "Ki ké où?"
│   ├── BenevoleListWidgetState.dart # PDF bénévoles
│   └── ...
├── model/                  # Modèles de données
│   ├── MyUser.dart         # Modèle utilisateur
│   ├── Poste.dart          # Modèle poste
│   └── ...
└── main.dart               # Point d'entrée
```

## 🔧 Architecture

### Pattern utilisé

- **MVC** avec séparation claire des responsabilités
- **Provider** pour la gestion d'état globale
- **GetX** pour la navigation et l'injection de dépendances

### Gestion des données

- **Firestore** comme base de données principale
- **Chargement centralisé** pour optimiser les performances
- **Cache local** pour réduire les appels réseau

## 📊 Fonctionnalités Clés

### Graphe Radar

```dart
// RadarChartScreen.dart
class _RadarChartScreenState extends State<RadarChartScreen> {
  List<double> _dataValues = [];
  List<String> _postes = [];

  void _computeRadarData() {
    // Calcul des pourcentages de remplissage
    // Filtrage par jour et créneau
  }
}
```

### Génération PDF

```dart
// BenevoleListWidgetState.dart
Future<void> _createPDF() async {
  final pdf = pw.Document();
  // Création du PDF avec logo et tableau
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
```

### Notifications

```dart
// FCMService
class FCMService {
  Future<void> sendPersonalizedToAllUsers(String title, String body) async {
    // Envoi de notifications personnalisées
  }
}
```

## 🧪 Tests

### Tests unitaires

```bash
flutter test
```

### Tests d'intégration

```bash
flutter test integration_test/
```

### Tests de performance

```bash
flutter run --profile
```

## 🔍 Debugging

### Logs Firebase

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Firebase.initializeApp();
  // Logs automatiques pour les erreurs
}
```

### Debug Web

```bash
flutter run -d chrome --web-renderer html
```

### Debug Mobile

```bash
flutter run -d <device-id>
```

## 📦 Déploiement

### Web

```bash
flutter build web
# Déployer le dossier build/web
```

### Android

```bash
flutter build apk --release
# Ou pour App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
# Ouvrir dans Xcode pour finaliser
```

## 🐛 Résolution de Problèmes

### Erreurs courantes

#### "Helvetica has no Unicode support"

**Solution** : Utiliser `PdfFontFamily.timesRoman` au lieu d'Helvetica

#### "Assets not found"

**Solution** : Vérifier le fichier `pubspec.yaml` et les chemins d'assets

#### "Firebase not initialized"

**Solution** : S'assurer que `Firebase.initializeApp()` est appelé dans `main.dart`

### Performance

#### Optimisations recommandées

- Utiliser `const` constructors quand possible
- Éviter les rebuilds inutiles
- Centraliser le chargement des données
- Utiliser `ListView.builder` pour les listes longues

## 📚 Ressources

### Documentation officielle

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf)

### Outils utiles

- [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)

## 🤝 Contribution

### Standards de code

- Suivre les conventions Dart/Flutter
- Commenter le code complexe
- Utiliser des noms de variables explicites
- Tester les nouvelles fonctionnalités

### Processus de contribution

1. Créer une branche feature
2. Développer et tester
3. Créer une Pull Request
4. Code review
5. Merge après validation

## 📞 Support

Pour toute question technique :

- Créer une issue sur GitHub
- Consulter la documentation
- Contacter l'équipe de développement

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2024
