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
import 'package:terreenvie/controller/SignUpPage.dart';

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  State<LogController> createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
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
            // textfields(),
            child: TextFormField(
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
            // textfields(),
            child: TextFormField(
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
                allowAdminToLogin();
              },
              child: Text("Authentification"),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
              child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
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

  Future<void> alerte(String message) async {
    Text title = Text("Erreur");
    Text msg = Text(message);
    FloatingActionButton okButton = FloatingActionButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text("ok"),
    );
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: title,
            content: msg,
            actions: <Widget>[okButton],
          );
        });
  }
}
