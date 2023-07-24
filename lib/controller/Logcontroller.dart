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

import '../main.dart';

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  State<LogController> createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var _obscureText = true;
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentification"),
        backgroundColor: Color(0xFF2b5a72),
      ),
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
            child: Image.asset("logoTEV.png"),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            child: Text(
              "Une adresse mail PAR PERSONNE. Si la votre est déjà utilisée, vous pouvez utiliser le modèle suivant: prenom.nom@tev.bzh ",
              style: TextStyle(color: Color(0xFF2b5a72), fontSize: 20),
            ),
          ),
          SizedBox(
            height: 10.0,
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
                labelText: 'Mot de passe',
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
                    // Get.offNamed('/');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MainAppController()));
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Erreur"),
                        content: Text(
                            "Votre identifiant ou mot de passe est invalide."),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                    print("Check email and password");
                  }
                } on FirebaseAuthException catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Erreur"),
                      content: Text(
                          "Votre identifiant ou mot de passe est invalide."),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                  // ignore: avoid_print
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Erreur"),
                      content: Text("Erreur $e"),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                  print("Erreur $e");
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(
                    0xFF2b5a72), // Définit la couleur de fond sur transparent
                elevation: 0, // Supprime l'ombre du bouton
              ),
              child: Text("Se connecter"),
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
              style: ElevatedButton.styleFrom(
                primary: Color(
                    0xFF2b5a72), // Définit la couleur de fond sur transparent
                elevation: 0, // Supprime l'ombre du bouton
              ),
              child: Text("Mot de passe oublié ?"),
            ),
          )),
          SizedBox(
            height: 10.0,
          ),
          Container(
            child: Text(
              "Si c'est votre première venue, allez sur 'S'inscrire' en haut à gauche.",
              style: TextStyle(color: Color(0xFF2b5a72), fontSize: 20),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            child: Text(
              "Le tableau de bord permet de voir vos créneaux à tout moment du jour et de la nuit, il n'y a donc plus d'emails récapitulatifs.",
              style: TextStyle(color: Color(0xFF2b5a72), fontSize: 20),
            ),
          ),
        ],
      )),
    );
  }
}
