import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      // Demander les permissions
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
        print('Notifications autorisées');

        // Obtenir le token FCM
        String? token = await _firebaseMessaging.getToken();
        print('FCM Token: $token');

        // Configurer les gestionnaires de messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

        // Configurer le gestionnaire de messages en arrière-plan
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } else {
        print('Notifications non autorisées');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Message reçu en premier plan: ${message.notification?.title}');
    // Ici vous pouvez afficher une notification locale ou mettre à jour l'UI
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Message reçu en arrière-plan: ${message.notification?.title}');
    // Ici vous pouvez naviguer vers une page spécifique
  }

  // Méthodes utilitaires
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

// Gestionnaire de messages en arrière-plan (doit être au niveau global)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en arrière-plan: ${message.notification?.title}');
  // Ici vous pouvez traiter le message en arrière-plan
}
