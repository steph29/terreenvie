import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controller/MainAppController.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Assurez-vous que ceci est importé
import 'package:rxdart/rxdart.dart';

//final DotEnv rootEnv = DotEnv();
// Utilisé pour passer les messages de l'event handler à l'UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // (kIsWeb) ? null : await FirebaseApi().initNotifications();
// Assurez-vous que Firebase est initialisé avant d'appeler ceci, par exemple :
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Ceci est appelé chaque fois qu'un message FCM est reçu
    // pendant que l'application est au premier plan.

    // Pour le débogage, vous pouvez imprimer les détails du message :
    // if (kDebugMode) { // Importez 'package:flutter/foundation.dart' pour kDebugMode
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification title: ${message.notification?.title}');
    print('Message notification body: ${message.notification?.body}');
    // }

    // Publiez le message vers notre contrôleur de flux pour que l'UI puisse le récupérer
    _messageStreamController.sink.add(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  String _lastMessage = "";
  // Ajoutez un Subscription pour pouvoir l'annuler proprement
  // lorsque le widget est détruit
  late StreamSubscription<RemoteMessage> _messageSubscription;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _messageSubscription = _messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          // Si le message contient un titre et un corps de notification
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
        } else {
          // Si c'est seulement un message de données (sans notification visible)
          _lastMessage = 'Received a data message: ${message.data}';
        }
      });
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel(); // Annule l'abonnement
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MainAppController(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFFf2f0e7)),
    );
  }
}
