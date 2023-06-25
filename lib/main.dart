import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/AdminPage.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: MyApp._title,
      home: user != null ? MainAppController() : const LogController(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color(0xFFf2f0e7)),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainAppController()),
        GetPage(name: '/login', page: () => LogController()),
        GetPage(name: '/logout', page: () => LogController()),
        GetPage(name: '/admin', page: () => AdminPage()),
        GetPage(name: '/dashboard', page: () => DashboardPage()),
      ],
    );
  }
}
