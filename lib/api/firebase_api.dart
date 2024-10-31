import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    debugPrint(
        'Token : $fCMToken'); // TODO enregistrer  e token pour chaque utilisateur
  }

// Get device token to use for push notification
  Future getDeviceToken() async {
    // Request user permission
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    await _firebaseMessaging.requestPermission();
    String? deviceToken = await _firebaseMessage.getToken();
    print(deviceToken);
    return (deviceToken == null) ? "" : deviceToken;
  }
}
