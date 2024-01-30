import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/MainAppController.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terreenvie/model/environnement.dart';

//final DotEnv rootEnv = DotEnv();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await dotenv.load(fileName: Environnement.fileName);
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Environnement.apiKey,
        appId: Environnement.appId,
        messagingSenderId: Environnement.messagingSenderId,
        projectId: Environnement.projectId,
      ),
    );
  } else if (Platform.isAndroid || Platform.isIOS) {
    print("I am in android device");
    await Firebase.initializeApp(
      name: 'terreenvie-6723d',
      options: const FirebaseOptions(
        // apiKey: Environnement.apiKey,
        // appId: Environnement.appId,
        // messagingSenderId: Environnement.messagingSenderId,
        // projectId: Environnement.projectId,

        apiKey: 'AIzaSyAqqA8Y1qLDP0YR0Cm0oiiLEx5dELhdwgk',
        appId: '1:1078182509252:web:a8bd648f93bd27522b2791',
        messagingSenderId: '1078182509252',
        projectId: 'terreenvie-6723d',
      ),
    );
    // await FirebaseAppCheck.instance.activate(
    //     webProvider:
    //         ReCaptchaV3Provider('6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'));
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
      theme: ThemeData(primaryColor: const Color(0xFFf2f0e7)),
    );
  }
}
