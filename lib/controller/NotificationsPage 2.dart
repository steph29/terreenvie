import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/fcm_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FCMService _fcmService = FCMService();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = false;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Configuration spécifique pour le web
        print('Initialisation des notifications pour le web');

        // Sur le web, on simule un token FCM
        fcmToken = 'WEB_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
        print('FCM Token (Web): $fcmToken');

        // Sur le web, on ne peut pas utiliser Firebase Messaging directement
        // mais on peut simuler les notifications
        print('Notifications web initialisées (mode simulation)');
      } else {
        // Configuration pour mobile (Android/iOS)
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
          fcmToken = await _firebaseMessaging.getToken();
          print('FCM Token (Mobile): $fcmToken');

          // Sauvegarder le token dans Firestore si l'utilisateur est connecté
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && fcmToken != null) {
            await _fcmService.saveUserToken(currentUser.uid, fcmToken!);
            print(
                'Token FCM sauvegardé pour l\'utilisateur: ${currentUser.uid}');
          }

          // Écouter les messages en premier plan
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            _addNotification(message);
          });

          // Écouter les messages quand l'app est en arrière-plan
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            _addNotification(message);
          });

          // Écouter les messages quand l'app est fermée
          RemoteMessage? initialMessage =
              await _firebaseMessaging.getInitialMessage();
          if (initialMessage != null) {
            _addNotification(initialMessage);
          }
        } else {
          print('Notifications non autorisées');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addNotification(RemoteMessage message) {
    setState(() {
      notifications.insert(0, {
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? 'Contenu de la notification',
        'data': message.data,
        'timestamp': DateTime.now(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });
  }

  // Simulation de notification pour le web
  void _simulateNotification() {
    if (kIsWeb) {
      _addNotification(RemoteMessage(
        notification: RemoteNotification(
          title: 'Test Web',
          body: 'Ceci est une notification de test pour le web !',
        ),
        data: {'type': 'test', 'platform': 'web'},
      ));
    }
  }

  void _clearNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearNotifications,
            tooltip: 'Effacer toutes les notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Section d'information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'État des notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Initialisation...'),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(
                        fcmToken != null ? Icons.check_circle : Icons.error,
                        color: fcmToken != null ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fcmToken != null
                            ? 'Notifications activées'
                            : 'Notifications non disponibles',
                      ),
                    ],
                  ),
                if (fcmToken != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb
                        ? 'Mode Web (simulation) - Token: ${fcmToken!.substring(0, 20)}...'
                        : 'Token FCM: ${fcmToken!.substring(0, 20)}...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: kIsWeb ? _simulateNotification : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Tester (Web)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearNotifications,
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des notifications
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune notification',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les notifications reçues apparaîtront ici',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(
                              Icons.notifications,
                              color: Colors.green[700],
                            ),
                          ),
                          title: Text(
                            notification['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['body']),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(notification['timestamp']),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                notifications.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
