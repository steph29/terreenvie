import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'template_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final TemplateService _templateService = TemplateService();

  // URLs des Firebase Functions
  static const String _sendEmailUrl =
      'https://sendemail-7mzwe64jha-uc.a.run.app';
  static const String _sendBulkEmailsUrl =
      'https://sendbulkemails-7mzwe64jha-uc.a.run.app';
  static const String _sendPersonalizedEmailsUrl =
      'https://sendpersonalizedemails-7mzwe64jha-uc.a.run.app';

  // Configuration SMTP
  SmtpServer get _smtpServer {
    final password = dotenv.env['EMAIL_PASSWORD'] ?? '';
    return gmail('communication.terreenvie@gmail.com', password);
  }

  // Envoyer un email simple
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      print('🚀 Début de sendEmail');
      print('🌐 kIsWeb: $kIsWeb');

      if (kIsWeb) {
        // Mode Web - Utiliser Firebase Functions
        print('🌐 Mode Web détecté - Utilisation des Firebase Functions');
        print('📧 URL: $_sendEmailUrl');
        print(
            '📧 Données à envoyer: {"to": "$to", "subject": "$subject", "body": "$body"}');

        final response = await http.post(
          Uri.parse(_sendEmailUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'to': to,
            'subject': subject,
            'body': body,
          }),
        );

        print('📧 Réponse reçue: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          print('✅ Email envoyé avec succès via Firebase Functions');
          return true;
        } else {
          print(
              '❌ Erreur Firebase Functions: ${response.statusCode} - ${response.body}');
          return false;
        }
      } else {
        // Mode Mobile - SMTP réel
        print('📱 Mode Mobile détecté - Utilisation SMTP');
        final message = Message()
          ..from = Address('communication.terreenvie@gmail.com', 'Terre en Vie')
          ..recipients.add(to)
          ..subject = subject
          ..text = body;

        final sendReport = await send(message, _smtpServer);
        print('✅ Email envoyé avec succès: ${sendReport.toString()}');
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'email: $e');
      return false;
    }
  }

  // Envoyer des emails en masse
  Future<bool> sendBulkEmails({
    required List<String> emails,
    required String subject,
    required String body,
  }) async {
    try {
      if (kIsWeb) {
        // Mode Web - Utiliser Firebase Functions
        print(
            '🌐 Mode Web détecté - Utilisation des Firebase Functions pour emails en masse');

        final response = await http.post(
          Uri.parse(_sendBulkEmailsUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'emails': emails,
            'subject': subject,
            'body': body,
          }),
        );

        if (response.statusCode == 200) {
          print('✅ Emails en masse envoyés avec succès via Firebase Functions');
          return true;
        } else {
          print(
              '❌ Erreur Firebase Functions: ${response.statusCode} - ${response.body}');
          return false;
        }
      } else {
        // Mode Mobile - SMTP réel
        final message = Message()
          ..from = Address('communication.terreenvie@gmail.com', 'Terre en Vie')
          ..recipients.addAll(emails)
          ..subject = subject
          ..text = body;

        final sendReport = await send(message, _smtpServer);
        print(
            '✅ Emails en masse envoyés avec succès: ${sendReport.toString()}');
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi d\'emails en masse: $e');
      return false;
    }
  }

  // Envoyer des emails personnalisés à tous les utilisateurs
  Future<bool> sendPersonalizedToAllUsers({
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? creneauData,
  }) async {
    try {
      // Récupérer tous les utilisateurs depuis Firestore
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final users = usersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (kIsWeb) {
        // Mode Web - Utiliser Firebase Functions
        print(
            '🌐 Mode Web détecté - Utilisation des Firebase Functions pour emails personnalisés');

        // Convertir les données en objets JSON simples
        final usersJson = users
            .map((user) => {
                  'email': user['email']?.toString() ?? '',
                  'prenom': user['prenom']?.toString() ?? '',
                  'nom': user['nom']?.toString() ?? '',
                  'profil': user['profil']?.toString() ?? '',
                })
            .toList();

        final response = await http.post(
          Uri.parse(_sendPersonalizedEmailsUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'users': usersJson,
            'subject': subject,
            'bodyTemplate': bodyTemplate,
            'creneauData': creneauData,
          }),
        );

        if (response.statusCode == 200) {
          print(
              '✅ Emails personnalisés envoyés avec succès via Firebase Functions');
          return true;
        } else {
          print(
              '❌ Erreur Firebase Functions: ${response.statusCode} - ${response.body}');
          return false;
        }
      } else {
        // Mode Mobile - SMTP réel
        for (Map<String, dynamic> user in users) {
          final personalizedBody = _templateService.replaceVariables(
              bodyTemplate, user, creneauData);
          await sendEmail(
            to: user['email'] as String,
            subject: subject,
            body: personalizedBody,
          );
        }
        print('✅ ${users.length} emails personnalisés envoyés avec succès');
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi d\'emails personnalisés: $e');
      return false;
    }
  }

  // Envoyer des emails personnalisés à des utilisateurs spécifiques
  Future<bool> sendPersonalizedToSpecificUsers({
    required List<String> selectedEmails,
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? creneauData,
  }) async {
    try {
      if (kIsWeb) {
        // Mode Web - Utiliser Firebase Functions
        print(
            '🌐 Mode Web détecté - Utilisation des Firebase Functions pour emails personnalisés spécifiques');

        // Récupérer les données utilisateur depuis Firestore
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: selectedEmails)
            .get();

        final users = usersSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Convertir les données en objets JSON simples
        final usersJson = users
            .map((user) => {
                  'email': user['email']?.toString() ?? '',
                  'prenom': user['prenom']?.toString() ?? '',
                  'nom': user['nom']?.toString() ?? '',
                  'profil': user['profil']?.toString() ?? '',
                })
            .toList();

        final response = await http.post(
          Uri.parse(_sendPersonalizedEmailsUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'users': usersJson,
            'subject': subject,
            'bodyTemplate': bodyTemplate,
            'creneauData': creneauData,
          }),
        );

        if (response.statusCode == 200) {
          print(
              '✅ Emails personnalisés spécifiques envoyés avec succès via Firebase Functions');
          return true;
        } else {
          print(
              '❌ Erreur Firebase Functions: ${response.statusCode} - ${response.body}');
          return false;
        }
      } else {
        // Mode Mobile - SMTP réel
        for (String email in selectedEmails) {
          // Récupérer les données utilisateur depuis Firestore
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          Map<String, dynamic> userData = {
            'email': email,
            'nom': '',
            'prenom': '',
            'profil': ''
          };
          if (userSnapshot.docs.isNotEmpty) {
            userData = userSnapshot.docs.first.data();
          }

          final personalizedBody = _templateService.replaceVariables(
              bodyTemplate, userData, creneauData);
          await sendEmail(
            to: email,
            subject: subject,
            body: personalizedBody,
          );
        }
        print(
            '✅ ${selectedEmails.length} emails personnalisés envoyés avec succès');
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi d\'emails personnalisés: $e');
      return false;
    }
  }

  // Méthodes de compatibilité pour l'interface existante
  Future<bool> sendToAllUsers(String subject, String body) async {
    return await sendPersonalizedToAllUsers(
      subject: subject,
      bodyTemplate: body,
    );
  }

  Future<bool> sendToSpecificUsers(
      List<String> userIds, String subject, String body) async {
    return await sendPersonalizedToSpecificUsers(
      selectedEmails: userIds,
      subject: subject,
      bodyTemplate: body,
    );
  }

  // Envoyer un email de bienvenue à un nouveau bénévole
  Future<bool> sendWelcomeEmail({
    required String email,
    required String prenom,
    required String nom,
  }) async {
    try {
      print('🎉 Envoi de l\'email de bienvenue à $email');

      // Récupérer le template de bienvenue
      final template = TemplateService.predefinedTemplates['bienvenue'];
      if (template == null) {
        print('❌ Template de bienvenue non trouvé');
        return false;
      }

      // Préparer les données utilisateur
      final userData = {
        'email': email,
        'prenom': prenom,
        'nom': nom,
        'profil': 'ben',
      };

      // Remplacer les variables dans le template
      final subject =
          _templateService.replaceVariables(template['title']!, userData, null);
      final body =
          _templateService.replaceVariables(template['body']!, userData, null);

      print('📧 Sujet: $subject');
      print('📧 Corps: $body');

      // Envoyer l'email
      return await sendEmail(
        to: email,
        subject: subject,
        body: body,
      );
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'email de bienvenue: $e');
      return false;
    }
  }
}
