// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
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

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  State<LogController> createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Authentification")),
      body: AuthLog(),
    );
  }

  Widget AuthLog() {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 200.0,
            child: Lottie.asset("hands.json"),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: emailController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Votre  Email',
                labelStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password),
                labelStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: ElevatedButton(
              onPressed: () async {
                var userEmail = emailController.text.trim();
                var userPassword = passwordController.text.trim();

                try {
                  final User? firebaseUser = (await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: userEmail, password: userPassword))
                      .user;
                  if (firebaseUser != null) {
                    Get.offAll(MainAppController());
                  } else {
                    print("Check email and password");
                  }
                } on FirebaseAuthException catch (e) {
                  // ignore: avoid_print
                  print("Erreur $e");
                }
              },
              child: Text("Authentification"),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
              child: Card(
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => ForgotPwdPage());
              },
              child: Text("Mot de passe oublié ?"),
            ),
          )),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(() => SignUpPage());
            },
            child: Text("Pas encore de compte, inscrivez-vous !"),
          ),
        ],
      )),
    );
  }
}
