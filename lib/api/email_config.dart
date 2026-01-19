// Configuration pour l'envoi d'emails
//
// IMPORTANT: Pour que les emails fonctionnent, vous devez :
//
// 1. Activer l'authentification à 2 facteurs sur votre compte Gmail
// 2. Générer un mot de passe d'application :
//    - Allez dans les paramètres de votre compte Google
//    - Sécurité > Connexion à Google > Mots de passe d'application
//    - Générez un mot de passe pour "Mail"
// 3. Remplacez 'votre_mot_de_passe_d_application' par le vrai mot de passe généré
//
// Alternative : Utiliser OAuth2 (plus sécurisé mais plus complexe)

class EmailConfig {
  // Configuration SMTP Gmail
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String username = 'benevole@terreenvie.com';
  static const String password =
      'votre_mot_de_passe_d_application'; // À remplacer
  static const bool ssl = false;
  static const bool allowInsecure = true;

  // Configuration de l'expéditeur
  static const String senderEmail = 'benevole@terreenvie.com';
  static const String senderName = 'Terre en Vie';

  // Configuration des templates d'emails
  static const Map<String, Map<String, String>> emailTemplates = {
    'Rappel créneau': {
      'subject': 'Rappel - Votre créneau Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nCeci est un rappel pour votre créneau de bénévolat.\n\nCordialement,\nL\'équipe Terre en Vie',
    },
    'Confirmation inscription': {
      'subject': 'Confirmation d\'inscription - Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nVotre inscription a été confirmée avec succès.\n\nMerci de votre engagement !\nL\'équipe Terre en Vie',
    },
    'Annulation créneau': {
      'subject': 'Annulation de créneau - Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nVotre créneau a été annulé.\n\nNous vous remercions de votre compréhension.\nL\'équipe Terre en Vie',
    },
    'Bienvenue': {
      'subject': 'Bienvenue chez Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nBienvenue dans notre communauté de bénévoles !\n\nNous sommes ravis de vous compter parmi nous.\nL\'équipe Terre en Vie',
    },
    'Remerciement': {
      'subject': 'Merci pour votre engagement - Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nMerci pour votre engagement et votre dévouement.\n\nVotre contribution est précieuse pour notre association.\nL\'équipe Terre en Vie',
    },
    'Résumé inscriptions': {
      'subject': 'Résumé de vos inscriptions - Terre en Vie',
      'body':
          'Bonjour {prenom},\n\nVoici le résumé de vos inscriptions :\n{creneaux}\n\nÀ bientôt,\nL\'équipe Terre en Vie',
    },
  };
}
