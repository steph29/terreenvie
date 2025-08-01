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
      if (kIsWeb) {
        // Mode Web - Utiliser une API externe ou simulation
        print('🌐 Mode Web détecté - Simulation d\'envoi d\'email');
        print('📧 Email simulé vers: $to');
        print('📧 Sujet: $subject');
        print('📧 Contenu: $body');
        print('✅ Email simulé envoyé avec succès (mode Web)');
        return true;
      } else {
        // Mode Mobile - SMTP réel
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
        // Mode Web - Simulation
        print('🌐 Mode Web détecté - Simulation d\'envoi d\'emails en masse');
        for (String email in emails) {
          print('📧 Email simulé vers: $email');
        }
        print(
            '✅ ${emails.length} emails simulés envoyés avec succès (mode Web)');
        return true;
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
      final emails = usersSnapshot.docs
          .map((doc) => doc.data()['email'] as String)
          .toList();

      if (kIsWeb) {
        // Mode Web - Simulation
        print('🌐 Mode Web détecté - Simulation d\'emails personnalisés');
        for (String email in emails) {
          final personalizedBody =
              _templateService.replaceVariables(bodyTemplate, creneauData);
          print('📧 Email personnalisé simulé vers: $email');
          print('📧 Contenu: $personalizedBody');
        }
        print(
            '✅ ${emails.length} emails personnalisés simulés envoyés avec succès (mode Web)');
        return true;
      } else {
        // Mode Mobile - SMTP réel
        for (String email in emails) {
          final personalizedBody =
              _templateService.replaceVariables(bodyTemplate, creneauData);
          await sendEmail(
            to: email,
            subject: subject,
            body: personalizedBody,
          );
        }
        print('✅ ${emails.length} emails personnalisés envoyés avec succès');
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
        // Mode Web - Simulation
        print('🌐 Mode Web détecté - Simulation d\'emails personnalisés');
        for (String email in selectedEmails) {
          final personalizedBody =
              _templateService.replaceVariables(bodyTemplate, creneauData);
          print('📧 Email personnalisé simulé vers: $email');
          print('📧 Contenu: $personalizedBody');
        }
        print(
            '✅ ${selectedEmails.length} emails personnalisés simulés envoyés avec succès (mode Web)');
        return true;
      } else {
        // Mode Mobile - SMTP réel
        for (String email in selectedEmails) {
          final personalizedBody =
              _templateService.replaceVariables(bodyTemplate, creneauData);
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
}
