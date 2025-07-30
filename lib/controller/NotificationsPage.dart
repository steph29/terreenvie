import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../api/fcm_service.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FCMService _fcmService = FCMService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? fcmToken;
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];
  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Simulation pour le web
        fcmToken = 'WEB_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
        print('FCM Token (Web): $fcmToken');
        print('Notifications web initialisées (mode simulation)');
      } else {
        // Configuration pour mobile
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
          fcmToken = await _firebaseMessaging.getToken();
          print('FCM Token (Mobile): $fcmToken');

          // Sauvegarder le token pour l'utilisateur actuel
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && fcmToken != null) {
            await _fcmService.saveUserToken(currentUser.uid, fcmToken!);
            print(
                'Token FCM sauvegardé pour l\'utilisateur: ${currentUser.uid}');
          }

          // Écouter les messages en premier plan
          _messageSubscription =
              FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            print(
                'Message reçu en premier plan: ${message.notification?.title}');
            _addNotification(message);
          });

          // Écouter les messages en arrière-plan
          // Note: Le gestionnaire de messages en arrière-plan est défini dans firebase_api.dart

          print('Notifications mobiles initialisées avec succès');
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
        'body': message.notification?.body ?? '',
        'timestamp': DateTime.now(),
        'data': message.data,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color.fromRGBO(43, 90, 114, 1),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Section d'information sur le token
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'État des notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Token FCM: ${fcmToken?.substring(0, 20)}...',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Plateforme: ${kIsWeb ? "Web" : "Mobile"}',
                        style: TextStyle(fontSize: 12),
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
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune notification',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Les notifications reçues apparaîtront ici',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
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
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  Icons.notifications,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  notification['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notification['body']),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(
                                          notification['timestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
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
