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
        backgroundColor: Color(0xFF2b5a72),
        // actions: []
      ),
      body: SingleChildScrollView(
          child: Container(
        child: Column(children: [
          Container(
            alignment: Alignment.center,
            height: 200.0,
            child: Image.asset("logoTEV.png"),
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
                    .then((value) => {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Validé"),
                              content: Text(
                                  "Un email vient de vous être envoyé. Suivez les instructions pour réinitialiser votre mot de passe. Si vous ne trouvez pas l'email, vérifier les spams"),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              LogController())),
                                ),
                              ],
                            ),
                          ),
                          //  Get.off(() => LogController())
                        });
              } on FirebaseAuthException catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Erreur"),
                    content: Text("Votre email est invalide."),
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
            child: Text("Réinitialiser mon mot de passe"),
          ),
        ]),
      )),
    );
  }
}
