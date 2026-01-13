# Configuration de l'envoi d'emails - Terre en Vie

## 🚀 Configuration Gmail pour l'envoi d'emails

### Étape 1 : Activer l'authentification à 2 facteurs

1. Allez sur [myaccount.google.com](https://myaccount.google.com)
2. Cliquez sur "Sécurité"
3. Activez "Connexion à Google" > "Validation en 2 étapes"

### Étape 2 : Générer un mot de passe d'application

1. Dans "Sécurité" > "Connexion à Google" > "Mots de passe d'application"
2. Sélectionnez "Mail" comme application
3. Cliquez sur "Générer"
4. **Copiez le mot de passe généré** (16 caractères)

### Étape 3 : Configurer le fichier .env

1. **Copiez le fichier d'exemple** :

   ```bash
   cp env.example .env
   ```

2. **Modifiez le fichier `.env`** :

   ```env
   # Configuration Email - Terre en Vie
   EMAIL_SMTP_SERVER=smtp.gmail.com
   EMAIL_SMTP_PORT=587
   EMAIL_USERNAME=benevole@terreenvie.com
   EMAIL_PASSWORD=votre_vrai_mot_de_passe_d_application
   EMAIL_SENDER_NAME=Terre en Vie
   ```

3. **Remplacez `votre_vrai_mot_de_passe_d_application`** par le mot de passe généré à l'étape 2

### Étape 4 : Vérifier la sécurité

- ✅ Le fichier `.env` est dans `.gitignore` (ne sera pas commité)
- ✅ Les variables sensibles sont sécurisées
- ✅ Le fichier `env.example` sert de modèle

### Étape 5 : Tester l'envoi

1. Lancez l'application
2. Allez dans "Communication" > "Emails"
3. Envoyez un email de test

## 🔧 Configuration alternative (OAuth2)

Pour une sécurité maximale, vous pouvez utiliser OAuth2 :

### Étape 1 : Créer un projet Google Cloud

1. Allez sur [console.cloud.google.com](https://console.cloud.google.com)
2. Créez un nouveau projet
3. Activez l'API Gmail

### Étape 2 : Créer des identifiants OAuth2

1. Dans "APIs & Services" > "Credentials"
2. Créez des identifiants OAuth2
3. Téléchargez le fichier JSON

### Étape 3 : Configurer dans l'application

1. Placez le fichier JSON dans `assets/`
2. Modifiez `lib/api/email_service.dart` pour utiliser OAuth2

## 📧 Templates d'emails disponibles

- **Rappel créneau** : Rappel pour les créneaux de bénévolat
- **Confirmation inscription** : Confirmation d'inscription
- **Annulation créneau** : Notification d'annulation
- **Bienvenue** : Message de bienvenue pour nouveaux bénévoles
- **Remerciement** : Remerciements pour l'engagement

## 🔒 Sécurité

- ✅ **Variables d'environnement** : Les mots de passe ne sont plus dans le code
- ✅ **Fichier .env ignoré** : Ne sera jamais commité dans Git
- ✅ **Mot de passe d'application** : Plus sécurisé que le mot de passe principal
- ✅ **Authentification 2FA** : Obligatoire pour les mots de passe d'application

## 🐛 Dépannage

### Erreur "Invalid credentials"

- Vérifiez que le mot de passe d'application est correct dans `.env`
- Assurez-vous que l'authentification à 2 facteurs est activée

### Erreur "Connection timeout"

- Vérifiez votre connexion internet
- Vérifiez que le port 587 n'est pas bloqué

### Erreur "Authentication failed"

- Régénérez un nouveau mot de passe d'application
- Vérifiez que l'email dans `.env` est correct

### Erreur "File .env not found"

- Vérifiez que le fichier `.env` existe à la racine du projet
- Copiez `env.example` vers `.env` si nécessaire

## 📞 Support

Pour toute question, contactez : communication.terreenvie@gmail.com
