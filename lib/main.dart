import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:terreenvie/controller/MainAppController.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyAqqA8Y1qLDP0YR0Cm0oiiLEx5dELhdwgk",
    appId: "1:1078182509252:web:a8bd648f93bd27522b2791",
    messagingSenderId: "1078182509252",
    projectId: "terreenvie-6723d",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  static const String _title = 'Le coin des bénévoles';

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: _title,
      home: LogController(),
      debugShowCheckedModeBanner: false,
    );
  }
}
