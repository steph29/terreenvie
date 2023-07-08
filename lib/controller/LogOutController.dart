// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:lottie/lottie.dart';
import 'package:terreenvie/controller/ForgotPwdPage.dart';
import 'package:terreenvie/controller/MainAppController.dart';
import 'package:terreenvie/controller/SignUpPage.dart';

import '../main.dart';

class LogOutController extends StatefulWidget {
  const LogOutController({Key? key}) : super(key: key);

  @override
  State<LogOutController> createState() => _LogOutControllerState();
}

class _LogOutControllerState extends State<LogOutController> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var _obscureText = true;
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Déconnexion"),
        backgroundColor: Color(0xFF2b5a72),
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
            primary:
                Color(0xFF2b5a72), // Définit la couleur de fond sur transparent
            elevation: 0, // Supprime l'ombre du bouton
          ),
          child: Text('Se déconnecter')),
    );
  }
}
