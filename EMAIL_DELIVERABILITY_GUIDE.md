# Guide d'amélioration de la délivrabilité des emails

## Problème : Les emails tombent dans les spams

### Solutions mises en place

#### 1. **Configuration SMTP améliorée**

- Utilisation de l'adresse `communication.terreenvie@gmail.com` comme expéditeur principal
- Configuration des variables d'environnement pour la sécurité
- Utilisation de mots de passe d'application Gmail

#### 2. **Templates d'emails personnalisés**

- Emails avec contenu personnalisé et professionnel
- Signature claire avec l'adresse d'expédition
- Structure HTML/text claire et lisible

#### 3. **Système de tokens sécurisés**

- Génération de tokens uniques pour la réinitialisation
- Expiration automatique après 24h
- Validation côté serveur

### Améliorations supplémentaires recommandées

#### 1. **Configuration DNS (SPF, DKIM, DMARC)**

Ajoutez ces enregistrements DNS à votre domaine `terreenvie.fr` :

```txt
# SPF Record
v=spf1 include:_spf.google.com ~all

# DKIM Record (à configurer dans Google Workspace)
# DMARC Record
v=DMARC1; p=quarantine; rua=mailto:dmarc@terreenvie.fr
```

#### 2. **Configuration Google Workspace**

1. **Activez l'authentification à 2 facteurs** sur `communication.terreenvie@gmail.com`
2. **Générez un mot de passe d'application** spécifique pour l'application
3. **Configurez DKIM** dans les paramètres Google Workspace

#### 3. **Amélioration du contenu des emails**

```dart
// Exemple d'email amélioré
final emailContent = '''
Bonjour $userName,

Vous avez demandé la réinitialisation de votre mot de passe pour votre compte Terre en Vie.

Pour réinitialiser votre mot de passe, cliquez sur le lien suivant :
$resetLink

⚠️  IMPORTANT : Ce lien est valable pendant 24 heures uniquement.

Si vous n'avez pas demandé cette réinitialisation, vous pouvez ignorer cet email en toute sécurité.

Cordialement,
L'équipe Terre en Vie
Association Terre en Vie
Email: communication.terreenvie@gmail.com
Site web: https://terreenvie.fr

---
Cet email a été envoyé automatiquement depuis communication.terreenvie@gmail.com
Pour toute question, contactez-nous directement.
''';
```

#### 4. **Configuration Firebase Functions**

Mettez à jour `functions/index.js` :

```javascript
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
  // Améliorations pour la délivrabilité
  secure: false,
  tls: {
    rejectUnauthorized: false,
    ciphers: "SSLv3",
  },
  // Headers pour améliorer la délivrabilité
  headers: {
    "X-Priority": "1",
    "X-MSMail-Priority": "High",
    Importance: "high",
  },
});

// Configuration des options d'email
const mailOptions = {
  from: {
    name: "Terre en Vie",
    address: process.env.EMAIL_USER,
  },
  to: to,
  subject: subject,
  text: body,
  // Headers supplémentaires
  headers: {
    "List-Unsubscribe": "<mailto:unsubscribe@terreenvie.fr>",
    Precedence: "bulk",
    "X-Auto-Response-Suppress": "OOF, AutoReply",
  },
};
```

#### 5. **Monitoring et suivi**

Ajoutez un système de suivi des emails :

```dart
// Dans EmailService
Future<bool> sendEmailWithTracking({
  required String to,
  required String subject,
  required String body,
}) async {
  try {
    // Enregistrer l'envoi dans Firestore
    await FirebaseFirestore.instance
        .collection('email_logs')
        .add({
      'to': to,
      'subject': subject,
      'sentAt': DateTime.now(),
      'status': 'sent',
      'type': 'password_reset'
    });

    // Envoyer l'email
    final result = await sendEmail(to: to, subject: subject, body: body);

    // Mettre à jour le statut
    if (result) {
      await FirebaseFirestore.instance
          .collection('email_logs')
          .doc(/* document ID */)
          .update({'status': 'delivered'});
    }

    return result;
  } catch (e) {
    print('Erreur envoi email: $e');
    return false;
  }
}
```

### Actions immédiates à effectuer

1. **Vérifiez la configuration Gmail** :

   - Activez l'authentification à 2 facteurs
   - Générez un nouveau mot de passe d'application
   - Mettez à jour `functions/.env`

2. **Testez l'envoi d'emails** :

   - Envoyez un email de test à votre propre adresse
   - Vérifiez qu'il arrive en boîte de réception (pas en spam)

3. **Configurez les enregistrements DNS** :

   - Contactez votre hébergeur pour ajouter SPF, DKIM, DMARC

4. **Surveillez les logs** :
   - Vérifiez les logs Firebase Functions
   - Surveillez les taux de délivrabilité

### Commandes utiles

```bash
# Redéployer les fonctions Firebase
firebase deploy --only functions

# Vérifier les logs
firebase functions:log

# Tester l'envoi d'email
curl -X POST https://sendemail-7mzwe64jha-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{"to":"test@example.com","subject":"Test","body":"Test email"}'
```

### Contacts pour support

- **Email technique** : communication.terreenvie@gmail.com
- **Hébergeur DNS** : Contactez votre fournisseur d'hébergement
- **Google Workspace** : Console d'administration Google

---

_Ce guide doit être mis à jour régulièrement selon les bonnes pratiques de délivrabilité email._
