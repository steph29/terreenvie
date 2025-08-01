# 🔥 Configuration Firebase Functions pour l'envoi d'emails

## 📋 Prérequis

1. **Firebase CLI installé** :

   ```bash
   npm install -g firebase-tools
   ```

2. **Node.js 18+** installé sur votre machine

3. **Projet Firebase configuré** avec les services Firestore et Functions activés

## 🚀 Installation et déploiement

### 1. Initialiser Firebase Functions

```bash
# Dans le répertoire racine du projet
firebase init functions
```

Répondez aux questions :

- ✅ **Functions** : Yes
- ✅ **JavaScript** : Yes
- ✅ **ESLint** : No (optionnel)
- ✅ **Install dependencies** : Yes

### 2. Configurer les variables d'environnement

```bash
# Configurer les variables pour l'email
firebase functions:config:set email.user="communication.terreenvie@gmail.com"
firebase functions:config:set email.password="dernierWE09"
```

### 3. Déployer les fonctions

```bash
# Déployer uniquement les fonctions
firebase deploy --only functions
```

### 4. Récupérer l'URL de votre projet

Après le déploiement, notez l'URL de votre projet :

```
https://us-central1-VOTRE_PROJET_ID.cloudfunctions.net
```

### 5. Mettre à jour l'URL dans le code

Dans `lib/api/email_service.dart`, remplacez :

```dart
static const String _baseUrl = 'https://us-central1-terreenvie-xxxxx.cloudfunctions.net';
```

Par votre URL réelle :

```dart
static const String _baseUrl = 'https://us-central1-VOTRE_PROJET_ID.cloudfunctions.net';
```

## 🔧 Configuration Gmail

### 1. Activer l'authentification à 2 facteurs

- Allez dans les paramètres de votre compte Google
- Activez l'authentification à 2 facteurs

### 2. Générer un mot de passe d'application

- Allez dans "Sécurité" > "Mots de passe d'application"
- Sélectionnez "Autre (nom personnalisé)"
- Entrez "Terre en Vie App"
- Copiez le mot de passe généré

### 3. Configurer Firebase Functions

```bash
firebase functions:config:set email.password="VOTRE_MOT_DE_PASSE_APPLICATION"
```

## 🧪 Test des fonctions

### Test local (optionnel)

```bash
# Démarrer l'émulateur
firebase emulators:start --only functions

# Tester avec curl
curl -X POST http://localhost:5001/VOTRE_PROJET_ID/us-central1/sendEmail \
  -H "Content-Type: application/json" \
  -d '{
    "to": "test@example.com",
    "subject": "Test",
    "body": "Test email"
  }'
```

### Test après déploiement

```bash
curl -X POST https://us-central1-VOTRE_PROJET_ID.cloudfunctions.net/sendEmail \
  -H "Content-Type: application/json" \
  -d '{
    "to": "test@example.com",
    "subject": "Test",
    "body": "Test email"
  }'
```

## 📊 Fonctions disponibles

### 1. `sendEmail`

- **URL** : `POST /sendEmail`
- **Paramètres** : `to`, `subject`, `body`, `fromName` (optionnel)
- **Usage** : Envoi d'un email simple

### 2. `sendBulkEmails`

- **URL** : `POST /sendBulkEmails`
- **Paramètres** : `recipients[]`, `subject`, `body`, `fromName` (optionnel)
- **Usage** : Envoi d'emails en lot

### 3. `sendPersonalizedEmails`

- **URL** : `POST /sendPersonalizedEmails`
- **Paramètres** : `emails[]`, `subject`, `bodyTemplate`, `fromName` (optionnel)
- **Usage** : Envoi d'emails personnalisés avec variables

## 🔒 Sécurité

### Variables d'environnement

Les credentials email sont stockés dans Firebase Functions Config :

```bash
# Voir la configuration actuelle
firebase functions:config:get

# Supprimer une variable
firebase functions:config:unset email.password
```

### CORS

Les fonctions sont configurées pour accepter les requêtes depuis Flutter Web.

## 🐛 Dépannage

### Erreur "Function not found"

- Vérifiez que les fonctions sont déployées : `firebase functions:list`
- Vérifiez l'URL dans le code Dart

### Erreur d'authentification Gmail

- Vérifiez que l'authentification à 2 facteurs est activée
- Régénérez le mot de passe d'application
- Mettez à jour la configuration : `firebase functions:config:set email.password="NOUVEAU_MOT_DE_PASSE"`

### Erreur CORS

- Les fonctions incluent déjà la gestion CORS
- Vérifiez que l'origine de votre app Flutter Web est autorisée

## 📱 Intégration Flutter

L'application Flutter utilise maintenant :

- **Flutter Web** : API Firebase Functions
- **Flutter Mobile** : SMTP direct

Le service `EmailService` détecte automatiquement la plateforme et utilise la méthode appropriée.

## 🎯 Avantages

✅ **Envoi réel d'emails** sur Flutter Web  
✅ **Sécurité** avec Firebase Functions  
✅ **Scalabilité** automatique  
✅ **Monitoring** intégré Firebase  
✅ **Logs** détaillés  
✅ **Gestion d'erreurs** robuste

## 📞 Support

En cas de problème :

1. Vérifiez les logs : `firebase functions:log`
2. Testez les fonctions individuellement
3. Vérifiez la configuration Gmail
4. Consultez la documentation Firebase Functions
