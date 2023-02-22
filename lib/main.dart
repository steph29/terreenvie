import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/MainAppController.dart';

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

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  static const String _title = 'Le coin des bénévoles';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    // ignore: avoid_print
    print(user?.uid.toString());
    // Ceci est un test de branche
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: MyApp._title,
      home: user != null ? MainAppController() : const LogController(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color(0xFFf2f0e7)),
    );
  }
}
