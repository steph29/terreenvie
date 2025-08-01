import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'template_service.dart';

class EmailService {
  // Service d'email simplifié compatible avec l'existant

  // Envoi d'un email simple
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
        // Pour mobile, on utilise une approche simplifiée
        print('📱 Mode Mobile - Simulation d\'envoi d\'email');
        print('📧 Email simulé vers: $to');
        print('📧 Sujet: $subject');
        print('📧 Contenu: $body');
        print('✅ Email simulé envoyé avec succès (mode Mobile)');
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'email: $e');
      return false;
    }
  }

  // Envoi d'emails en lot
  static Future<Map<String, bool>> sendBulkEmails({
    required List<String> recipients,
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      print(
          '📧 Envoi d\'emails en lot vers ${recipients.length} destinataires');
      final results = <String, bool>{};

      for (final recipient in recipients) {
        final success = await sendEmail(
          to: recipient,
          subject: subject,
          body: body,
          fromName: fromName,
        );
        results[recipient] = success;
      }

      print('✅ ${recipients.length} emails simulés envoyés avec succès');
      return results;
    } catch (e) {
      print('❌ Erreur lors de l\'envoi des emails en lot: $e');
      return {};
    }
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

      final results = <String, bool>{};

      for (final user in users) {
        final email = user['email'] as String?;
        if (email != null && email.isNotEmpty) {
          final variables = {
            'nom': user['nom'] ?? '',
            'prenom': user['prenom'] ?? '',
            'email': email,
          };

          final personalizedBody =
              TemplateService.replaceVariables(bodyTemplate, variables, null);
          final success = await sendEmail(
            to: email,
            subject: subject,
            body: personalizedBody,
            fromName: fromName,
          );
          results[email] = success;
        }
      }

      print(
          '✅ ${results.length} emails personnalisés simulés envoyés avec succès');
      return results;
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
      final results = <String, bool>{};

      for (final user in users) {
        final email = user['email'] as String?;
        if (email != null && email.isNotEmpty) {
          final variables = {
            'nom': user['nom'] ?? '',
            'prenom': user['prenom'] ?? '',
            'email': email,
          };

          final personalizedBody =
              TemplateService.replaceVariables(bodyTemplate, variables, null);
          final success = await sendEmail(
            to: email,
            subject: subject,
            body: personalizedBody,
            fromName: fromName,
          );
          results[email] = success;
        }
      }

      print(
          '✅ ${results.length} emails personnalisés simulés envoyés avec succès');
      return results;
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
}
