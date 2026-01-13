import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'template_service.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final TemplateService _templateService = TemplateService();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /* ----------------------------------------------------
     1) EMAIL SIMPLE
  ---------------------------------------------------- */

  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendEmail');

      final result = await callable.call({
        'to': to,
        'subject': subject,
        'body': body,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendEmail error: $e');
      return false;
    }
  }

  /* ----------------------------------------------------
     2) EMAILS EN MASSE
  ---------------------------------------------------- */

  Future<bool> sendBulkEmails({
    required List<String> emails,
    required String subject,
    required String body,
  }) async {
    try {
      // Vérifier l'authentification avant l'appel
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
            'Utilisateur non authentifié. Veuillez vous connecter.');
      }

      print('📧 Appel de sendBulkEmails avec ${emails.length} emails');
      print('📧 Utilisateur authentifié: ${user.uid}');

      final callable = _functions.httpsCallable('sendBulkEmails');

      final result = await callable.call({
        'emails': emails,
        'subject': subject,
        'body': body,
      });

      print('📧 Résultat reçu: ${result.data}');
      return result.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      print('❌ Firebase Functions error:');
      print('❌ Code: ${e.code}');
      print('❌ Message: ${e.message}');
      print('❌ Details: ${e.details}');
      throw Exception('Erreur Firebase Functions (${e.code}): ${e.message}');
    } catch (e) {
      print('❌ sendBulkEmails error: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /* ----------------------------------------------------
     3) EMAILS PERSONNALISÉS - TOUS
  ---------------------------------------------------- */

  Future<bool> sendPersonalizedToAllUsers({
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? creneauData,
  }) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final users = usersSnapshot.docs.map((doc) => doc.data()).toList();

      final usersJson = users
          .map((user) => {
                'email': user['email'] ?? '',
                'prenom': user['prenom'] ?? '',
                'nom': user['nom'] ?? '',
                'profil': user['profil'] ?? '',
              })
          .toList();

      final callable = _functions.httpsCallable('sendPersonalizedEmails');

      final result = await callable.call({
        'users': usersJson,
        'subject': subject,
        'bodyTemplate': bodyTemplate,
        'creneauData': creneauData,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendPersonalizedToAllUsers error: $e');
      return false;
    }
  }

  /* ----------------------------------------------------
     4) EMAILS PERSONNALISÉS - SÉLECTION
  ---------------------------------------------------- */

  Future<bool> sendPersonalizedToSpecificUsers({
    required List<String> selectedEmails,
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? creneauData,
  }) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: selectedEmails)
          .get();

      final users = usersSnapshot.docs.map((doc) => doc.data()).toList();

      final usersJson = users
          .map((user) => {
                'email': user['email'] ?? '',
                'prenom': user['prenom'] ?? '',
                'nom': user['nom'] ?? '',
                'profil': user['profil'] ?? '',
              })
          .toList();

      final callable = _functions.httpsCallable('sendPersonalizedEmails');

      final result = await callable.call({
        'users': usersJson,
        'subject': subject,
        'bodyTemplate': bodyTemplate,
        'creneauData': creneauData,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendPersonalizedToSpecificUsers error: $e');
      return false;
    }
  }

  /* ----------------------------------------------------
     5) EMAIL DE BIENVENUE
  ---------------------------------------------------- */

  Future<bool> sendWelcomeEmail({
    required String email,
    required String prenom,
    required String nom,
  }) async {
    try {
      final template = TemplateService.predefinedTemplates['bienvenue'];
      if (template == null) return false;

      final userData = {
        'email': email,
        'prenom': prenom,
        'nom': nom,
        'profil': 'ben',
      };

      final subject =
          _templateService.replaceVariables(template['title']!, userData, null);
      final body =
          _templateService.replaceVariables(template['body']!, userData, null);

      return await sendEmail(
        to: email,
        subject: subject,
        body: body,
      );
    } catch (e) {
      print('❌ sendWelcomeEmail error: $e');
      return false;
    }
  }
}
