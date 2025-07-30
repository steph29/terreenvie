import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'template_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final TemplateService _templateService = TemplateService();

  // Récupérer tous les tokens FCM des utilisateurs
  Future<List<String>> getAllUserTokens() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<String> tokens = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['fcmToken'] != null &&
            data['fcmToken'].toString().isNotEmpty) {
          tokens.add(data['fcmToken']);
        }
      }

      print('Tokens FCM trouvés: ${tokens.length}');
      if (tokens.isEmpty) {
        print('Aucun token FCM trouvé dans la base de données');
        print(
            'Les utilisateurs doivent se connecter pour générer leur token FCM');
      }

      return tokens;
    } catch (e) {
      print('Erreur lors de la récupération des tokens: $e');
      return [];
    }
  }

  // Récupérer les tokens FCM d'utilisateurs spécifiques
  Future<List<String>> getUserTokens(List<String> userIds) async {
    try {
      List<String> tokens = [];

      for (String userId in userIds) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['fcmToken'] != null &&
              data['fcmToken'].toString().isNotEmpty) {
            tokens.add(data['fcmToken']);
          }
        }
      }

      print(
          'Tokens FCM trouvés pour les utilisateurs sélectionnés: ${tokens.length}');
      return tokens;
    } catch (e) {
      print('Erreur lors de la récupération des tokens: $e');
      return [];
    }
  }

  // Sauvegarder le token FCM d'un utilisateur
  Future<void> saveUserToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('Token FCM sauvegardé pour l\'utilisateur: $userId');
    } catch (e) {
      print('Erreur lors de la sauvegarde du token: $e');
    }
  }

  // Envoyer une notification personnalisée à tous les utilisateurs
  Future<void> sendPersonalizedToAllUsers(
      String titleTemplate, String bodyTemplate) async {
    try {
      print(
          'Génération de notifications personnalisées pour tous les utilisateurs...');

      final notifications = await _templateService
          .generatePersonalizedNotifications(titleTemplate, bodyTemplate);

      if (notifications.isEmpty) {
        throw Exception(
            'Aucune notification personnalisée générée. Vérifiez que les utilisateurs ont des tokens FCM.');
      }

      print('Envoi de ${notifications.length} notifications personnalisées...');

      // Simuler l'envoi de chaque notification personnalisée
      for (var notification in notifications) {
        await _simulatePersonalizedNotification(notification);
      }
    } catch (e) {
      print('Erreur lors de l\'envoi personnalisé à tous les utilisateurs: $e');
      rethrow;
    }
  }

  // Envoyer une notification personnalisée à des utilisateurs spécifiques
  Future<void> sendPersonalizedToSpecificUsers(
      List<String> userIds, String titleTemplate, String bodyTemplate) async {
    try {
      print(
          'Génération de notifications personnalisées pour les utilisateurs sélectionnés...');

      final notifications = await _templateService
          .generatePersonalizedNotifications(titleTemplate, bodyTemplate,
              selectedUserIds: userIds);

      if (notifications.isEmpty) {
        throw Exception(
            'Aucune notification personnalisée générée pour les utilisateurs sélectionnés.');
      }

      print('Envoi de ${notifications.length} notifications personnalisées...');

      // Simuler l'envoi de chaque notification personnalisée
      for (var notification in notifications) {
        await _simulatePersonalizedNotification(notification);
      }
    } catch (e) {
      print(
          'Erreur lors de l\'envoi personnalisé aux utilisateurs spécifiques: $e');
      rethrow;
    }
  }

  // Envoyer une notification simple à tous les utilisateurs (ancienne méthode)
  Future<void> sendToAllUsers(String title, String body,
      {Map<String, dynamic>? data}) async {
    try {
      List<String> tokens = await getAllUserTokens();
      if (tokens.isEmpty) {
        throw Exception(
            'Aucun token FCM trouvé. Les utilisateurs doivent se connecter pour générer leur token FCM.');
      }

      print('Envoi de notification à ${tokens.length} utilisateurs');
      print('Titre: $title');
      print('Corps: $body');

      // Simuler l'envoi (pour l'instant)
      await _simulateNotificationSending(tokens, title, body, data);
    } catch (e) {
      print('Erreur lors de l\'envoi à tous les utilisateurs: $e');
      rethrow;
    }
  }

  // Envoyer une notification simple à des utilisateurs spécifiques (ancienne méthode)
  Future<void> sendToSpecificUsers(
      List<String> userIds, String title, String body,
      {Map<String, dynamic>? data}) async {
    try {
      List<String> tokens = await getUserTokens(userIds);
      if (tokens.isEmpty) {
        throw Exception(
            'Aucun token FCM trouvé pour les utilisateurs sélectionnés. Les utilisateurs doivent se connecter pour générer leur token FCM.');
      }

      print(
          'Envoi de notification à ${tokens.length} utilisateurs sélectionnés');
      print('Titre: $title');
      print('Corps: $body');

      // Simuler l'envoi (pour l'instant)
      await _simulateNotificationSending(tokens, title, body, data);
    } catch (e) {
      print('Erreur lors de l\'envoi aux utilisateurs spécifiques: $e');
      rethrow;
    }
  }

  // Simuler l'envoi d'une notification personnalisée
  Future<void> _simulatePersonalizedNotification(
      Map<String, dynamic> notification) async {
    print('=== NOTIFICATION PERSONNALISÉE ===');
    print(
        'Utilisateur: ${notification['userData']['prenom']} ${notification['userData']['nom']}');
    if (notification['creneau'] != null) {
      print(
          'Créneau: ${notification['creneau']['poste']} - ${notification['creneau']['jour']} ${notification['creneau']['debut']}-${notification['creneau']['fin']}');
    }
    print('Titre: ${notification['title']}');
    print('Corps: ${notification['body']}');
    print('Token: ${notification['fcmToken']}');
    print('==================================');

    // Simuler un délai d'envoi
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Simuler l'envoi de notifications simples (ancienne méthode)
  Future<void> _simulateNotificationSending(List<String> tokens, String title,
      String body, Map<String, dynamic>? data) async {
    print('=== SIMULATION D\'ENVOI DE NOTIFICATIONS ===');
    print('Tokens: ${tokens.length}');
    print('Titre: $title');
    print('Corps: $body');
    print('Données: $data');

    // Vérifier si ce sont des tokens web ou mobiles
    bool hasWebTokens = tokens.any((token) => token.startsWith('WEB_TOKEN_'));
    bool hasMobileTokens =
        tokens.any((token) => !token.startsWith('WEB_TOKEN_'));

    if (hasWebTokens) {
      print(
          '⚠️  Tokens web détectés - Les notifications push ne fonctionnent pas sur le web');
    }
    if (hasMobileTokens) {
      print(
          '📱 Tokens mobiles détectés - Les notifications push fonctionneront sur mobile');
    }

    // Simuler un délai d'envoi
    await Future.delayed(Duration(seconds: 2));

    print('✅ Notifications envoyées avec succès (simulation)');
    print('===============================================');
  }

  // Initialiser les notifications pour un utilisateur
  Future<void> initializeForUser(String userId) async {
    try {
      String? token;

      if (kIsWeb) {
        // Sur le web, on simule un token FCM
        token = 'WEB_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
        print('Token FCM simulé pour le web: $token');
      } else {
        // Sur mobile, on demande les permissions et on récupère le vrai token
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          // Obtenir le token FCM
          token = await _firebaseMessaging.getToken();
          print('Token FCM mobile: $token');
        } else {
          print('Notifications non autorisées par l\'utilisateur');
          return;
        }
      }

      if (token != null) {
        await saveUserToken(userId, token);
        print('Token FCM sauvegardé pour l\'utilisateur: $userId');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  // Méthode pour l'envoi réel via Firebase Cloud Messaging (à implémenter)
  Future<void> sendRealNotification(
      List<String> tokens, String title, String body,
      {Map<String, dynamic>? data}) async {
    // TODO: Implémenter l'envoi réel via l'API Firebase Cloud Messaging
    // Cela nécessiterait une clé d'authentification Firebase
    print('Envoi réel de notifications (à implémenter)');
  }
}
