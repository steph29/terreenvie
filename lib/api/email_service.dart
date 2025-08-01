import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'template_service.dart';

class EmailService {
  // URL des Firebase Functions (à remplacer par votre URL de déploiement)
  static const String _baseUrl =
      'https://us-central1-terreenvie-xxxxx.cloudfunctions.net';

  // Configuration SMTP pour les plateformes mobiles
  static SmtpServer _getSmtpServer() {
    final smtpServer = dotenv.env['EMAIL_SMTP_SERVER'] ?? 'smtp.gmail.com';
    final smtpPort =
        int.tryParse(dotenv.env['EMAIL_SMTP_PORT'] ?? '587') ?? 587;
    final username =
        dotenv.env['EMAIL_USERNAME'] ?? 'communication.terreenvie@gmail.com';
    final password =
        dotenv.env['EMAIL_PASSWORD'] ?? 'votre_mot_de_passe_d_application';

    print('🔧 Configuration SMTP:');
    print('   Serveur: $smtpServer');
    print('   Port: $smtpPort');
    print('   Username: $username');
    print(
        '   Password: ${password == 'votre_mot_de_passe_d_application' ? '❌ Non configuré' : '✅ Configuré'}');

    return SmtpServer(
      smtpServer,
      port: smtpPort,
      username: username,
      password: password,
      ssl: false,
      allowInsecure: true,
    );
  }

  // Envoi d'un email simple via API ou SMTP
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      if (kIsWeb) {
        // Simulation pour Flutter Web
        print('🌐 Mode Web détecté - Simulation d\'envoi d\'email');
        print('📧 Email simulé vers: $to');
        print('📧 Sujet: $subject');
        print('📧 Contenu: $body');
        print('✅ Email simulé envoyé avec succès (mode Web)');
        return true;
      } else {
        // Utiliser SMTP direct pour les plateformes mobiles
        return await _sendEmailViaSmtp(to, subject, body, fromName);
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'email: $e');
      return false;
    }
  }

  // Envoi d'emails en lot via API ou SMTP
  static Future<Map<String, bool>> sendBulkEmails({
    required List<String> recipients,
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      if (kIsWeb) {
        // Simulation pour Flutter Web
        print('🌐 Mode Web détecté - Simulation d\'envoi d\'emails en lot');
        final results = <String, bool>{};
        for (final recipient in recipients) {
          print('📧 Email simulé vers: $recipient');
          results[recipient] = true;
        }
        print(
            '✅ ${recipients.length} emails simulés envoyés avec succès (mode Web)');
        return results;
      } else {
        // Utiliser SMTP direct pour les plateformes mobiles
        return await _sendBulkEmailsViaSmtp(
            recipients, subject, body, fromName);
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi des emails en lot: $e');
      return {};
    }
  }

  // Méthodes API pour Flutter Web (pour utilisation future avec Firebase Functions)
  static Future<bool> _sendEmailViaApi(
      String to, String subject, String body, String? fromName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendEmail'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'body': body,
          'fromName': fromName,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Email envoyé via API: ${result['messageId']}');
        return true;
      } else {
        print('❌ Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'appel API: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> _sendBulkEmailsViaApi(
      List<String> recipients,
      String subject,
      String body,
      String? fromName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendBulkEmails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipients': recipients,
          'subject': subject,
          'body': body,
          'fromName': fromName,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Emails en lot envoyés via API: ${result['summary']}');
        return Map<String, bool>.from(
            result['results'].map((k, v) => MapEntry(k, v['success'])));
      } else {
        print('❌ Erreur API: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Erreur lors de l\'appel API: $e');
      return {};
    }
  }

  static Future<Map<String, bool>> _sendPersonalizedEmailsViaApi(
      List<Map<String, dynamic>> emails,
      String subject,
      String bodyTemplate,
      String? fromName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendPersonalizedEmails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emails': emails,
          'subject': subject,
          'bodyTemplate': bodyTemplate,
          'fromName': fromName,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Emails personnalisés envoyés via API: ${result['summary']}');
        return Map<String, bool>.from(
            result['results'].map((k, v) => MapEntry(k, v['success'])));
      } else {
        print('❌ Erreur API: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Erreur lors de l\'appel API: $e');
      return {};
    }
  }

  // Méthodes SMTP pour les plateformes mobiles
  static Future<bool> _sendEmailViaSmtp(
      String to, String subject, String body, String? fromName) async {
    final emailUsername =
        dotenv.env['EMAIL_USERNAME'] ?? 'communication.terreenvie@gmail.com';
    final emailPassword =
        dotenv.env['EMAIL_PASSWORD'] ?? 'votre_mot_de_passe_d_application';

    if (emailPassword == 'votre_mot_de_passe_d_application') {
      print('❌ Erreur: Mot de passe d\'application non configuré');
      print('📝 Veuillez configurer EMAIL_PASSWORD dans le fichier .env');
      return false;
    }

    final message = Message()
      ..from = Address(emailUsername,
          fromName ?? (dotenv.env['EMAIL_SENDER_NAME'] ?? 'Terre en Vie'))
      ..recipients.add(to)
      ..subject = subject
      ..html = _formatEmailBody(body);

    final sendReport = await send(message, _getSmtpServer());
    print('✅ Email envoyé avec succès: ${sendReport.toString()}');
    return true;
  }

  static Future<Map<String, bool>> _sendBulkEmailsViaSmtp(
      List<String> recipients,
      String subject,
      String body,
      String? fromName) async {
    final results = <String, bool>{};

    for (final recipient in recipients) {
      try {
        final success = await _sendEmailViaSmtp(
          recipient,
          subject,
          body,
          fromName,
        );
        results[recipient] = success;
      } catch (e) {
        print('❌ Erreur lors de l\'envoi à $recipient: $e');
        results[recipient] = false;
      }
    }

    return results;
  }

  // Méthodes d'instance pour l'interface utilisateur
  Future<Map<String, bool>> sendPersonalizedToAllUsers({
    required String subject,
    required String bodyTemplate,
    String? fromName,
  }) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final users = usersSnapshot.docs.map((doc) => doc.data()).toList();

      final emails = users
          .map((user) => {
                'email': user['email'] ?? '',
                'variables': {
                  'nom': user['nom'] ?? '',
                  'prenom': user['prenom'] ?? '',
                  'email': user['email'] ?? '',
                }
              })
          .where((email) => email['email'].isNotEmpty)
          .toList();

      if (kIsWeb) {
        // Simulation pour Flutter Web
        print(
            '🌐 Mode Web détecté - Simulation d\'envoi d\'emails personnalisés');
        final results = <String, bool>{};
        for (final emailData in emails) {
          final personalizedBody = TemplateService.replaceVariables(
              bodyTemplate, emailData['variables'], null);
          print('📧 Email personnalisé simulé vers: ${emailData['email']}');
          print('📧 Contenu personnalisé: $personalizedBody');
          results[emailData['email']] = true;
        }
        print(
            '✅ ${emails.length} emails personnalisés simulés envoyés avec succès (mode Web)');
        return results;
      } else {
        // Pour mobile, on utilise la méthode SMTP existante
        final results = <String, bool>{};
        for (final emailData in emails) {
          final personalizedBody = TemplateService.replaceVariables(
              bodyTemplate, emailData['variables'], null);
          final success = await _sendEmailViaSmtp(
            emailData['email'],
            subject,
            personalizedBody,
            fromName,
          );
          results[emailData['email']] = success;
        }
        return results;
      }
    } catch (e) {
      print(
          '❌ Erreur lors de l\'envoi personnalisé à tous les utilisateurs: $e');
      return {};
    }
  }

  Future<Map<String, bool>> sendPersonalizedToSpecificUsers({
    required List<String> selectedEmails,
    required String subject,
    required String bodyTemplate,
    String? fromName,
  }) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: selectedEmails)
          .get();

      final users = usersSnapshot.docs.map((doc) => doc.data()).toList();

      final emails = users
          .map((user) => {
                'email': user['email'] ?? '',
                'variables': {
                  'nom': user['nom'] ?? '',
                  'prenom': user['prenom'] ?? '',
                  'email': user['email'] ?? '',
                }
              })
          .where((email) => email['email'].isNotEmpty)
          .toList();

      if (kIsWeb) {
        // Simulation pour Flutter Web
        print(
            '🌐 Mode Web détecté - Simulation d\'envoi d\'emails personnalisés');
        final results = <String, bool>{};
        for (final emailData in emails) {
          final personalizedBody = TemplateService.replaceVariables(
              bodyTemplate, emailData['variables'], null);
          print('📧 Email personnalisé simulé vers: ${emailData['email']}');
          print('📧 Contenu personnalisé: $personalizedBody');
          results[emailData['email']] = true;
        }
        print(
            '✅ ${emails.length} emails personnalisés simulés envoyés avec succès (mode Web)');
        return results;
      } else {
        // Pour mobile, on utilise la méthode SMTP existante
        final results = <String, bool>{};
        for (final emailData in emails) {
          final personalizedBody = TemplateService.replaceVariables(
              bodyTemplate, emailData['variables'], null);
          final success = await _sendEmailViaSmtp(
            emailData['email'],
            subject,
            personalizedBody,
            fromName,
          );
          results[emailData['email']] = success;
        }
        return results;
      }
    } catch (e) {
      print(
          '❌ Erreur lors de l\'envoi personnalisé aux utilisateurs spécifiques: $e');
      return {};
    }
  }

  Future<Map<String, bool>> sendToAllUsers({
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final emails = usersSnapshot.docs
          .map((doc) => doc.data()['email'] as String?)
          .where((email) => email != null && email!.isNotEmpty)
          .cast<String>()
          .toList();

      return await sendBulkEmails(
        recipients: emails,
        subject: subject,
        body: body,
        fromName: fromName,
      );
    } catch (e) {
      print('❌ Erreur lors de l\'envoi à tous les utilisateurs: $e');
      return {};
    }
  }

  Future<Map<String, bool>> sendToSpecificUsers({
    required List<String> selectedEmails,
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      return await sendBulkEmails(
        recipients: selectedEmails,
        subject: subject,
        body: body,
        fromName: fromName,
      );
    } catch (e) {
      print('❌ Erreur lors de l\'envoi aux utilisateurs spécifiques: $e');
      return {};
    }
  }

  // Formatage du corps de l'email
  static String _formatEmailBody(String body) {
    return '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
          <h1 style="margin: 0;">Terre en Vie</h1>
        </div>
        <div style="padding: 20px; background-color: #f9f9f9;">
          $body
        </div>
        <div style="background-color: #333; color: white; padding: 15px; text-align: center; font-size: 12px;">
          © 2024 Terre en Vie - Tous droits réservés
        </div>
      </div>
    ''';
  }
}
