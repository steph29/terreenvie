import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'template_service.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TemplateService _templateService = TemplateService();

  // Sauvegarder le token FCM d'un utilisateur
  Future<void> saveUserToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('Token FCM sauvegardé pour l\'utilisateur: $userId');
    } catch (e) {
      print('Erreur lors de la sauvegarde du token FCM: $e');
    }
  }

  // Récupérer tous les tokens FCM des utilisateurs
  Future<List<String>> getAllUserTokens() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      List<String> tokens = [];
      for (var doc in querySnapshot.docs) {
        String? token = doc.data()['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          tokens.add(token);
        }
      }

      print('Nombre de tokens FCM récupérés: ${tokens.length}');
      return tokens;
    } catch (e) {
      print('Erreur lors de la récupération des tokens FCM: $e');
      return [];
    }
  }

  // Récupérer les tokens FCM d'utilisateurs spécifiques
  Future<List<String>> getSpecificUserTokens(List<String> userIds) async {
    try {
      List<String> tokens = [];

      for (String userId in userIds) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          String? token = doc.data()?['fcmToken'] as String?;
          if (token != null && token.isNotEmpty) {
            tokens.add(token);
          }
        }
      }

      print(
          'Nombre de tokens FCM récupérés pour les utilisateurs spécifiques: ${tokens.length}');
      return tokens;
    } catch (e) {
      print('Erreur lors de la récupération des tokens FCM spécifiques: $e');
      return [];
    }
  }

  // Envoyer une notification simple à tous les utilisateurs
  Future<void> sendToAllUsers(String title, String body) async {
    try {
      final tokens = await getAllUserTokens();
      if (tokens.isEmpty) {
        print('Aucun token FCM trouvé pour envoyer la notification');
        return;
      }

      await _simulateNotificationSending(tokens, title, body);
      print('Notification envoyée à ${tokens.length} utilisateurs');
    } catch (e) {
      print(
          'Erreur lors de l\'envoi de la notification à tous les utilisateurs: $e');
    }
  }

  // Envoyer une notification simple à des utilisateurs spécifiques
  Future<void> sendToSpecificUsers(
      List<String> userIds, String title, String body) async {
    try {
      final tokens = await getSpecificUserTokens(userIds);
      if (tokens.isEmpty) {
        print('Aucun token FCM trouvé pour les utilisateurs spécifiés');
        return;
      }

      await _simulateNotificationSending(tokens, title, body);
      print('Notification envoyée à ${tokens.length} utilisateurs spécifiques');
    } catch (e) {
      print(
          'Erreur lors de l\'envoi de la notification aux utilisateurs spécifiques: $e');
    }
  }

  // Envoyer des notifications personnalisées à tous les utilisateurs
  Future<void> sendPersonalizedToAllUsers(
      String titleTemplate, String bodyTemplate) async {
    try {
      final notifications = await _templateService
          .generatePersonalizedNotifications(titleTemplate, bodyTemplate);

      if (notifications.isEmpty) {
        print('Aucune notification personnalisée générée');
        return;
      }

      await _simulatePersonalizedNotification(notifications);
      print(
          'Notifications personnalisées envoyées à ${notifications.length} utilisateurs');
    } catch (e) {
      print('Erreur lors de l\'envoi des notifications personnalisées: $e');
    }
  }

  // Envoyer des notifications personnalisées à des utilisateurs spécifiques
  Future<void> sendPersonalizedToSpecificUsers(
      List<String> userIds, String titleTemplate, String bodyTemplate) async {
    try {
      final notifications = await _templateService
          .generatePersonalizedNotifications(titleTemplate, bodyTemplate,
              userIds: userIds);

      if (notifications.isEmpty) {
        print(
            'Aucune notification personnalisée générée pour les utilisateurs spécifiés');
        return;
      }

      await _simulatePersonalizedNotification(notifications);
      print(
          'Notifications personnalisées envoyées à ${notifications.length} utilisateurs spécifiques');
    } catch (e) {
      print(
          'Erreur lors de l\'envoi des notifications personnalisées aux utilisateurs spécifiques: $e');
    }
  }

  // Simulation de l'envoi de notifications simples
  Future<void> _simulateNotificationSending(
      List<String> tokens, String title, String body) async {
    print('=== SIMULATION D\'ENVOI DE NOTIFICATIONS ===');
    print('Titre: $title');
    print('Corps: $body');
    print('Nombre de destinataires: ${tokens.length}');

    // Simulation d'un délai d'envoi
    await Future.delayed(Duration(seconds: 2));

    print('✅ Notifications envoyées avec succès (simulation)');
    print('==============================================');
  }

  // Simulation de l'envoi de notifications personnalisées
  Future<void> _simulatePersonalizedNotification(
      List<Map<String, String>> notifications) async {
    print('=== SIMULATION D\'ENVOI DE NOTIFICATIONS PERSONNALISÉES ===');

    for (int i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      print('Notification ${i + 1}:');
      print('  Titre: ${notification['title']}');
      print('  Corps: ${notification['body']}');
      print('  Token: ${notification['token']?.substring(0, 20)}...');
      print('');
    }

    // Simulation d'un délai d'envoi
    await Future.delayed(Duration(seconds: 2));

    print('✅ Notifications personnalisées envoyées avec succès (simulation)');
    print('==============================================================');
  }
}
