import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:terreenvie/controller/MainAppController.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyA3TfCMtvxlJRFt9ibeBmyjt46hX_VKiUY",
        authDomain: "terre-en-vie-766c7.firebaseapp.com",
        projectId: "terre-en-vie-766c7",
        storageBucket: "terre-en-vie-766c7.appspot.com",
        messagingSenderId: "1094407773095",
        appId: "1:1094407773095:web:4259b1ba7d80d1ee2df482",
        measurementId: "G-LMM3Z2WHNL"),
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
            try {
              return MainAppController();
              // return LogController();
            } catch (e) {
              print(e);
            }
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
