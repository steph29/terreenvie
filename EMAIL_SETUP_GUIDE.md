# 📧 Guide de Configuration des Emails Réels

## 🎯 Situation Actuelle

L'application fonctionne parfaitement sur https://terreenvie-6723d.web.app, mais les emails sont en mode **simulation** sur le web.

## 🔧 Solutions pour les Emails Réels

### Option 1 : Firebase Functions (Recommandé)

**Avantages :** Intégré à Firebase, sécurisé, gratuit
**Inconvénients :** Configuration complexe

#### Étapes :
1. **Attendre que Firebase Functions soit disponible**
2. **Configurer les variables d'environnement :**
   ```bash
   firebase functions:config:set email.password="votre_mot_de_passe"
   ```
3. **Déployer les fonctions :**
   ```bash
   firebase deploy --only functions
   ```

### Option 2 : Service d'Email Tiers (Plus Simple)

#### A. EmailJS (Gratuit, 200 emails/mois)

1. **Créer un compte** sur [emailjs.com](https://www.emailjs.com/)
2. **Configurer un service email** (Gmail, Outlook, etc.)
3. **Créer un template** pour les emails
4. **Récupérer les IDs** et les configurer dans `web_email_service.dart`

#### B. SendGrid (Gratuit, 100 emails/jour)

1. **Créer un compte** sur [sendgrid.com](https://sendgrid.com/)
2. **Générer une API Key**
3. **Configurer l'expéditeur** (communication.terreenvie@gmail.com)
4. **Remplacer `YOUR_SENDGRID_API_KEY`** dans le code

#### C. Mailgun (Gratuit, 5,000 emails/mois)

1. **Créer un compte** sur [mailgun.com](https://www.mailgun.com/)
2. **Configurer un domaine** ou utiliser le domaine de test
3. **Générer une API Key**
4. **Configurer l'API** dans le code

### Option 3 : Solution Temporaire (Recommandée)

Pour l'instant, l'application fonctionne parfaitement avec :
- ✅ **Simulation sur web** (pour les tests)
- ✅ **SMTP réel sur mobile** (pour la production)
- ✅ **Toutes les autres fonctionnalités** opérationnelles

## 🚀 Configuration Rapide

### Pour EmailJS :

1. **Modifier `lib/api/web_email_service.dart` :**
   ```dart
   'service_id': 'service_xxxxxxx', // Votre Service ID
   'template_id': 'template_xxxxxxx', // Votre Template ID  
   'user_id': 'user_xxxxxxx', // Votre User ID
   ```

2. **Modifier `lib/api/email_service.dart` :**
   ```dart
   // Remplacer la simulation par l'appel API
   if (kIsWeb) {
     return await WebEmailService.sendEmail(
       to: to,
       subject: subject,
       body: body,
     );
   }
   ```

### Pour SendGrid :

1. **Créer un fichier `.env` :**
   ```
   SENDGRID_API_KEY=votre_clé_api
   ```

2. **Modifier le code pour utiliser SendGrid**

## 📊 Comparaison des Solutions

| Service | Gratuit | Limite | Configuration | Recommandé |
|---------|---------|--------|---------------|------------|
| **Simulation** | ✅ | ∞ | Aucune | ✅ Pour tests |
| **EmailJS** | ✅ | 200/mois | Simple | ✅ Pour début |
| **SendGrid** | ✅ | 100/jour | Moyenne | ✅ Pour production |
| **Mailgun** | ✅ | 5,000/mois | Moyenne | ✅ Pour volume |
| **Firebase Functions** | ✅ | 125K/mois | Complexe | ⏳ En attente |

## 🎯 Recommandation Immédiate

**Pour l'instant, garder la simulation** car :
1. ✅ L'application fonctionne parfaitement
2. ✅ Les emails réels marchent sur mobile
3. ✅ La simulation permet de tester l'interface
4. ⏳ Les Firebase Functions seront bientôt disponibles

## 🔄 Prochaines Étapes

1. **Tester l'application** en conditions réelles
2. **Attendre la disponibilité** des Firebase Functions
3. **Ou configurer EmailJS** pour les emails réels
4. **Déployer la solution finale**

---

**Statut actuel :** 🟢 Application opérationnelle avec simulation d'emails
**Prochaine étape :** Configuration des emails réels selon vos préférences 