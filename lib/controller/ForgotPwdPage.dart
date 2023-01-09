// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:terreenvie/controller/Logcontroller.dart';

class ForgotPwdPage extends StatefulWidget {
  const ForgotPwdPage({Key? key}) : super(key: key);

  @override
  State<ForgotPwdPage> createState() => _ForgotPwdPageState();
}

class _ForgotPwdPageState extends State<ForgotPwdPage> {
  TextEditingController emailcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mot de passe perdu ?"),
        // actions: []
      ),
      body: SingleChildScrollView(
          child: Container(
        child: Column(children: [
          Container(
            alignment: Alignment.center,
            height: 200.0,
            child: Lottie.asset("hands.json"),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: emailcontroller,
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
          ElevatedButton(
            onPressed: () async {
              var forgotemial = emailcontroller.text.trim();
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: forgotemial)
                    .then((value) =>
                        {print("Email send"), Get.off(() => LogController())});
              } on FirebaseAuthException catch (e) {
                print("Erreur $e");
              }
            },
            child: Text("Réinitialiser mon mot de passe"),
          ),
        ]),
      )),
    );
  }
}
