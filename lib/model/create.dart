import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/AdminPage.dart';
import 'package:terreenvie/controller/MainAppController.dart';

import '../controller/DashboardPage.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  TextEditingController posteController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController debutController = TextEditingController();
  TextEditingController finController = TextEditingController();
  TextEditingController nbBenController = TextEditingController();
  User? userId = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Les créneaux disponible"),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: TextFormField(
                controller: posteController,
                decoration: InputDecoration(hintText: "Nom du poste"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: TextFormField(
                controller: descController,
                decoration: InputDecoration(hintText: "Description"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: TextFormField(
                controller: debutController,
                decoration: InputDecoration(hintText: "Début"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: TextFormField(
                controller: finController,
                decoration: InputDecoration(hintText: "fin"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: TextFormField(
                controller: nbBenController,
                decoration: InputDecoration(hintText: "Nombre de Bénévoles"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                var poste = posteController.text.trim();
                var desc = descController.text.trim();
                var debut = debutController.text.trim();
                var fin = finController.text.trim();
                var nbBen = nbBenController.text.trim();
                if (poste != "") {
                  try {
                    await FirebaseFirestore.instance
                        .collection("pos_hor")
                        .doc()
                        .set({
                      "createdAt": DateTime.now(),
                      "poste": poste,
                      "desc": desc,
                      "hor": FieldValue.arrayUnion([
                        {"debut": debut, "fin": fin, "nbBen": nbBen}
                      ]),
                      "ben_id": userId?.uid,
                    });
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MainAppController(),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  } catch (e) {
                    print("Error $e");
                  }
                }
              },
              child: Text("Ajouter le poste"),
            )
          ],
        ),
      ),
    );
  }
}
