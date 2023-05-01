// ignore_for_file: prefer_const_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/AdminPage.dart';
import 'package:terreenvie/controller/MainAppController.dart';

class AddPoste extends StatefulWidget {
  const AddPoste({Key? key}) : super(key: key);

  @override
  State<AddPoste> createState() => _AddPosteState();
}

class _AddPosteState extends State<AddPoste> {
  TextEditingController posteContoller = TextEditingController();
  TextEditingController descContoller = TextEditingController();
  TextEditingController debutContoller = TextEditingController();
  TextEditingController finContoller = TextEditingController();
  TextEditingController nbBenContoller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier le poste")),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 400, vertical: 50),
        child: Column(children: [
          Card(
            color: Color(0xFFf2f0e7),
            child: Container(
              height: 290,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: posteContoller
                            ..text = "${Get.arguments['poste'].toString()}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: descContoller
                                    ..text =
                                        "${Get.arguments['desc'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  controller: debutContoller,
                                  // ..text =
                                  //     "${Get.arguments['debut'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  controller: finContoller,
                                  // ..text =
                                  //     "${Get.arguments['fin'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  controller: nbBenContoller,
                                  // ..text =
                                  //     "${Get.arguments['nbBen'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          OutlinedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("pos_hor")
                  .doc(Get.arguments['posteId'].toString())
                  .update(
                {
                  "poste": posteContoller.text.trim(),
                  "desc": descContoller.text.trim(),
                  "hor": FieldValue.arrayUnion([
                    {
                      "debut": debutContoller.text.trim(),
                      "fin": finContoller.text.trim(),
                      "nbBen": nbBenContoller.text.trim()
                    }
                  ]),
                },
              ).then((value) => {
                        Get.back(),
                      });
            },
            child: Text(
              "Modifier",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(43, 90, 114, 1)),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Color.fromRGBO(242, 240, 231, 1),
            ),
          ),
        ]),
      ),
    );
  }
}
