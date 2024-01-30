// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:terreenvie/controller/MainAppController.dart';

class LogOutController extends StatefulWidget {
  const LogOutController({Key? key}) : super(key: key);

  @override
  State<LogOutController> createState() => _LogOutControllerState();
}

class _LogOutControllerState extends State<LogOutController> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Déconnexion"),
        backgroundColor: Color(0xFFf2f0e7),
      ),
      body: Disconnect(),
    );
  }

  Widget Disconnect() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainAppController()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Color(0xFFf2f0e7), // Définit la couleur de fond sur transparent
            elevation: 0, // Supprime l'ombre du bouton
          ),
          child: Text('Se déconnecter')),
    );
  }
}
