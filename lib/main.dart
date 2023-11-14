import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/AdminPage.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terreenvie/controller/MainAppController.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final DotEnv rootEnv = DotEnv();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rootEnv.load(fileName: '.env');
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: rootEnv.get('APIKEY', fallback: 'APIKEY not found'),
    appId: rootEnv.get('APPID', fallback: 'APPID not found'),
    messagingSenderId: rootEnv.get('MESSAGINGSENDERID',
        fallback: 'MESSAGINGSENDERID not found'),
    projectId: rootEnv.get('PROJECTID', fallback: 'PROJECTID not found'),
  ));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

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
      home: MainAppController(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color(0xFFf2f0e7)),
    );
  }
}
