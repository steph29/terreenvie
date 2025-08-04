# 🔧 Dépannage des erreurs d'email

## ❌ Erreur "Instance of 'NotInitializedError'"

Cette erreur indique que les variables d'environnement ne sont pas chargées correctement.

### 🔍 Diagnostic

1. **Vérifiez que le fichier `.env` existe** :

   ```bash
   ls -la .env
   ```

2. **Vérifiez le contenu du fichier `.env`** :

   ```bash
   cat .env
   ```

3. **Vérifiez que le fichier `.env` est bien formaté** :
   ```env
   # Configuration Email - Terre en Vie
   EMAIL_SMTP_SERVER=smtp.gmail.com
   EMAIL_SMTP_PORT=587
   EMAIL_USERNAME=communication.terreenvie@gmail.com
   EMAIL_PASSWORD=votre_vrai_mot_de_passe_d_application
   EMAIL_SENDER_NAME=Terre en Vie
   ```

### 🛠️ Solutions

#### Solution 1 : Recréer le fichier `.env`

```bash
# Supprimer l'ancien fichier
rm .env

# Recréer depuis l'exemple
cp env.example .env

# Éditer le fichier avec votre mot de passe
nano .env
```

#### Solution 2 : Vérifier le chargement dans `main.dart`

Le fichier `lib/main.dart` doit contenir :

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  try {
    // Pour Flutter Web, on utilise le chemin asset
    if (kIsWeb) {
      await dotenv.load(fileName: "assets/.env");
    } else {
      await dotenv.load(fileName: ".env");
    }
    print('✅ Variables d\'environnement chargées avec succès');
  } catch (e) {
    print('⚠️ Erreur lors du chargement du fichier .env: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ...
}
```

#### Solution 3 : Configuration pour Flutter Web

Pour Flutter Web, le fichier `.env` doit être dans le dossier `assets/` :

1. **Ajouter dans `pubspec.yaml`** :

   ```yaml
   flutter:
     assets:
       - assets/
       - assets/fonts/OpenSans-Regular.ttf
       - .env # Ajouter cette ligne
   ```

2. **Copier le fichier `.env` dans `assets/`** :

   ```bash
   cp .env assets/.env
   ```

3. **Relancer l'application** :
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

#### Solution 4 : Vérifier les dépendances

```bash
flutter pub get
flutter clean
flutter pub get
```

#### Solution 5 : Test manuel

Ajoutez ce code temporaire dans `main.dart` pour déboguer :

```dart
// Après dotenv.load()
print('🔧 Test des variables d\'environnement:');
print('EMAIL_SMTP_SERVER: ${dotenv.env['EMAIL_SMTP_SERVER']}');
print('EMAIL_USERNAME: ${dotenv.env['EMAIL_USERNAME']}');
print('EMAIL_PASSWORD: ${dotenv.env['EMAIL_PASSWORD']?.substring(0, 3)}...');
```

### 🎯 Vérifications finales

1. **Le fichier `.env` existe à la racine du projet**
2. **Le fichier `.env` existe dans `assets/` (pour Flutter Web)**
3. **Le fichier `.env` contient le bon mot de passe d'application**
4. **Le fichier `.env` est dans `pubspec.yaml` comme asset**
5. **L'application affiche "✅ Variables d'environnement chargées avec succès"**
6. **L'application affiche "✅ EMAIL_PASSWORD configuré"**

### 🌐 Spécificités Flutter Web

- **Flutter Web** ne peut pas accéder directement aux fichiers du système
- Le fichier `.env` doit être déclaré comme asset dans `pubspec.yaml`
- Le fichier `.env` doit être copié dans le dossier `assets/`
- Le chemin de chargement doit être `"assets/.env"` pour Flutter Web

### 📞 Support

Si le problème persiste :

1. Vérifiez les logs de l'application
2. Testez avec un mot de passe d'application différent
3. Vérifiez que l'authentification 2FA est activée sur Gmail
4. Contactez : communication.terreenvie@gmail.com
