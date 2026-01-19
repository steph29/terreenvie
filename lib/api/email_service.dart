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
  static const int _whereInLimit = 10;

  /* ----------------------------------------------------
     1) EMAIL SIMPLE
  ---------------------------------------------------- */

  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    Map<String, dynamic>? attachment, // ⚡ pièce jointe optionnelle
  }) async {
    try {
      final callable = _functions.httpsCallable('sendEmail');

      final result = await callable.call({
        'to': to,
        'subject': subject,
        'body': body,
        'attachment': attachment,
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
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié.');
      }

      final callable = _functions.httpsCallable('sendBulkEmails');

      final result = await callable.call({
        'emails': emails,
        'subject': subject,
        'body': body,
        'attachment': attachment,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendBulkEmails error: $e');
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
    Map<String, dynamic>? attachment,
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
        'attachment': attachment,
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
    Map<String, dynamic>? attachment,
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
        'attachment': attachment,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendPersonalizedToSpecificUsers error: $e');
      return false;
    }
  }

  /* ----------------------------------------------------
     5) RÉSUMÉ D'INSCRIPTIONS - SÉLECTION
  ---------------------------------------------------- */

  Future<bool> sendRegistrationSummaryToSpecificUsers({
    required List<String> userIds,
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final users = await _getUsersByIds(userIds);
      if (users.isEmpty) return false;

      final usersJson = <Map<String, dynamic>>[];
      for (final user in users) {
        final userId = user['id'] as String;
        final creneaux = await _templateService.getUserCreneaux(userId);
        final creneauxText = _buildCreneauxText(creneaux);

        usersJson.add({
          'email': user['email'] ?? '',
          'prenom': user['prenom'] ?? '',
          'nom': user['nom'] ?? '',
          'profil': user['profil'] ?? '',
          'creneauxText': creneauxText,
        });
      }

      final callable = _functions.httpsCallable('sendPersonalizedEmails');
      final result = await callable.call({
        'users': usersJson,
        'subject': subject,
        'bodyTemplate': bodyTemplate,
        'attachment': attachment,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendRegistrationSummaryToSpecificUsers error: $e');
      return false;
    }
  }

  /* ----------------------------------------------------
     6) RÉSUMÉ D'INSCRIPTIONS - TOUS
  ---------------------------------------------------- */

  Future<bool> sendRegistrationSummaryToAllUsers({
    required String subject,
    required String bodyTemplate,
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final users = usersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      final usersJson = <Map<String, dynamic>>[];
      for (final user in users) {
        final userId = user['id'] as String;
        final creneaux = await _templateService.getUserCreneaux(userId);
        final creneauxText = _buildCreneauxText(creneaux);

        usersJson.add({
          'email': user['email'] ?? '',
          'prenom': user['prenom'] ?? '',
          'nom': user['nom'] ?? '',
          'profil': user['profil'] ?? '',
          'creneauxText': creneauxText,
        });
      }

      final callable = _functions.httpsCallable('sendPersonalizedEmails');
      final result = await callable.call({
        'users': usersJson,
        'subject': subject,
        'bodyTemplate': bodyTemplate,
        'attachment': attachment,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('❌ sendRegistrationSummaryToAllUsers error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _getUsersByIds(List<String> userIds) async {
    final List<Map<String, dynamic>> users = [];
    if (userIds.isEmpty) return users;

    for (var i = 0; i < userIds.length; i += _whereInLimit) {
      final chunk =
          userIds.sublist(i, (i + _whereInLimit).clamp(0, userIds.length));
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        users.add({
          'id': doc.id,
          ...doc.data(),
        });
      }
    }

    return users;
  }

  String _buildCreneauxText(List<Map<String, dynamic>> creneaux) {
    if (creneaux.isEmpty) {
      return 'Aucun créneau enregistré.';
    }
    final lines = creneaux.map((c) {
      final jour = c['jour'] ?? '';
      final poste = c['poste'] ?? '';
      final debut = c['debut'] ?? '';
      final fin = c['fin'] ?? '';
      final horaires =
          (debut.toString().isNotEmpty || fin.toString().isNotEmpty)
              ? '$debut - $fin'
              : '';
      return '- $jour | $poste | $horaires';
    }).toList();

    return lines.join('\n');
  }

  /* ----------------------------------------------------
     7) EMAIL DE BIENVENUE
  ---------------------------------------------------- */

  Future<bool> sendWelcomeEmail({
    required String email,
    required String prenom,
    required String nom,
    Map<String, dynamic>? attachment,
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
        attachment: attachment,
      );
    } catch (e) {
      print('❌ sendWelcomeEmail error: $e');
      return false;
    }
  }
}
