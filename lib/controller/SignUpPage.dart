import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  var _obscureText = true;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription"),
        backgroundColor: Color(0xFFf2f0e7),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 200.0,
            child: Image.asset("logoTEV.png"),
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
            padding: EdgeInsets.all(15),
            child: Text(
              "Votre mot de passe DOIT contenir 6 caractères minimum.",
              style: TextStyle(
                  color: Color(0xFF2b5a72), fontSize: (kIsWeb ? 20 : 15)),
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
                RegExp phoneNumberRegex = RegExp(r'^0[1-9][0-9]{8}$');
                RegExp emailRegex =
                    RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

                var userEmail = emailController.text.trim();
                var userPassword = passwordController.text.trim();
                var userName = nameController.text.trim();
                var userPrenom = prenomController.text.trim();
                var userPhone = telController.text.trim();
                var profil = "ben";
                var role = "ben";
                try {
                  bool isValidPhoneNumber =
                      phoneNumberRegex.hasMatch(userPhone);
                  if (isValidPhoneNumber) {
                    bool isValidEmail = emailRegex.hasMatch(userEmail);
                    if (isValidEmail) {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: userEmail, password: userPassword)
                          .then((value) => {
                                log("User created"),
                                signUpserv(userEmail, userPassword, userName,
                                    userPrenom, userPhone, profil, role),
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("MESSAGE IMPORTANT"),
                                    content: Text(
                                        "Conservez bien vos identifiants (adresse email + Mot de Passe), ils vous seront nécessaires pour vous connecter à votre compte. Le tableau de bord permet de voir vos créneaux à tout moment du jour et de la nuit, il n'y a donc plus d'email récapitulatifs ."),
                                    actions: [
                                      TextButton(
                                        child: Text("J'ai bien compris"),
                                        onPressed: () => Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                                builder: (context) =>
                                                    LogController())),
                                      ),
                                    ],
                                  ),
                                ),
                              });
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Erreur"),
                          content: Text(
                              "Le format de l'email est invalide. Si vous n'avez d'email, utilisez le modèle suivant: nom.prenom@tev.bzh"),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Erreur"),
                        content: Text("Le numéro de téléphone est invalide"),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  Container(
                    child: Center(
                      child: Text("$e"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                    0xFFf2f0e7), // Définit la couleur de fond sur transparent
                elevation: 0, // Supprime l'ombre du bouton
              ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(
                  0xFFf2f0e7), // Définit la couleur de fond sur transparent
              elevation: 0, // Supprime l'ombre du bouton
            ),
            child: Text("Vous avez déjà un compte, connectez-vous !"),
          ),
        ],
      )),
    );
  }
}
