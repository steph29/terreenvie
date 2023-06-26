import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/Logcontroller.dart';
import 'package:terreenvie/model/SignUpServices.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _log = true;
  String _adresseMail = "";
  String _motDePasse = "";
  String _prenom = "";
  String _name = "";
  String _tel = "";
  var _obscureText = true;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
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
              controller: nameController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Votre  Nom',
                labelStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: prenomController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Votre  Prénom',
                labelStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: telController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                labelText: 'Votre  Téléphone',
                labelStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
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
                var userName = nameController.text.trim();
                var userPrenom = prenomController.text.trim();
                var userPhone = telController.text.trim();
                var profil = "ben";
                var role = "ben";

                await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: userEmail, password: userPassword)
                    .then((value) => {
                          log("User created"),
                          signUpserv(userEmail, userPassword, userName,
                              userPrenom, userPhone, profil, role),
                        });
              },
              child: Text("Inscription"),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LogController()));
            },
            child: Text("Vous avez déjà un compte, connectez-vous !"),
          ),
        ],
      )),
    );
  }
}
