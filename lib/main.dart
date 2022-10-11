import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:terreenvie/controller/MainAppController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
      // options: FirebaseOptions(
      //   apiKey: "AIzaSyA3TfCMtvxlJRFt9ibeBmyjt46hX_VKiUY",
      //   appId: "1:1094407773095:web:4259b1ba7d80d1ee2df482",
      //   messagingSenderId: "1094407773095",
      //   projectId: "terre-en-vie-766c7",
      // ),
      );

  static const String _title = 'Le coin des bénévoles';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: //_handleAuth(),
          FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return LogController();
          }
          if (snapshot.hasData) {
            return LogController();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _handleAuth() {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            // acces a l'app
            return MainAppController();
          } else {
// retourne vers log
            return LogController();
          }
        });
  }
}
