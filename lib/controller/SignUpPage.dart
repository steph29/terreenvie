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

  allowAdminToLogin() async {
    SnackBar snackbar = const SnackBar(
      content: Text(
        "Loading ... ",
        style: const TextStyle(fontSize: 36, color: Colors.black),
      ),
      backgroundColor: Colors.pinkAccent,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    User? currentnUser;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((fAuth) {
      currentnUser = fAuth.user;
    }).catchError((onError) {
      final snackbar = SnackBar(
        content: Text(
          "Erreur " + onError.toString() + emailController.toString(),
          style: const TextStyle(fontSize: 36, color: Colors.black),
        ),
        backgroundColor: Colors.pinkAccent,
        duration: const Duration(seconds: 15),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });

    if (currentnUser != null) {
      // Check if that admin exists in the admin collection friestore  database
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(currentnUser!.uid)
          .get()
          .then((snap) {
        if (snap.exists) {
          Get.to(DashboardPage());
        } else {
          SnackBar snackbar = const SnackBar(
            content: Text(
              "Pas de compte trouvé !",
              style: const TextStyle(fontSize: 36, color: Colors.black),
            ),
            backgroundColor: Colors.pinkAccent,
            duration: Duration(seconds: 5),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // textfields(),
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
              onChanged: (string) {
                setState(() {
                  string = _adresseMail;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            // textfields(),
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
              onChanged: (string) {
                setState(() {
                  string = _adresseMail;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            // textfields(),
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
              onChanged: (string) {
                setState(() {
                  string = _adresseMail;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            // textfields(),
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
              onChanged: (string) {
                setState(() {
                  string = _adresseMail;
                });
              },
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            // textfields(),
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
              onChanged: (string) {
                setState(() {
                  string = _motDePasse;
                });
              },
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

                FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: userEmail, password: userPassword)
                    .then((value) => {
                          log("User created"),
                          FirebaseFirestore.instance
                              .collection("benevoles")
                              .doc()
                              .set({
                            'nom': userName,
                            'prenom': userPrenom,
                            'tel': userPhone,
                            'email': userEmail,
                            'createdAt': DateTime.now(),
                            'UserId': currentUser!.uid,
                          }),
                          log("Data added"),
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
              Get.to(() => LogController());
            },
            child: Text("Vous avez déjà un compte, connectez-vous !"),
          ),
        ],
      )),
    );
  }
}
