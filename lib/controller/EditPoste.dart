// ignore_for_file: prefer_const_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditPoste extends StatefulWidget {
  const EditPoste({Key? key}) : super(key: key);

  @override
  State<EditPoste> createState() => _EditPosteState();
}

class _EditPosteState extends State<EditPoste> {
  TextEditingController posteContoller = TextEditingController();
  TextEditingController descContoller = TextEditingController();
  TextEditingController debutContoller = TextEditingController();
  TextEditingController finContoller = TextEditingController();
  TextEditingController nbBenContoller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le poste"),
        backgroundColor: Color(0xFFf2f0e7),
      ),
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
                                  controller: debutContoller
                                    ..text =
                                        "${Get.arguments['debut'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  controller: finContoller
                                    ..text =
                                        "${Get.arguments['fin'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  controller: nbBenContoller
                                    ..text =
                                        "${Get.arguments['nbBen'].toString()}",
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
                      "jour": Get.arguments['jour'].toString(),
                      "poste": posteContoller.text.trim(),
                      "desc": descContoller.text.trim(),
                      // Suppression de l'ancienne valeur
                      "hor": FieldValue.arrayRemove([
                        {
                          "debut": Get.arguments['debut'].toString(),
                          "fin": Get.arguments['fin'].toString(),
                          "nbBen": Get.arguments['nbBen'].toInt(),
                          "check": false
                        }
                      ]),
                    },
                  )
                  .then((value) => {
                        // Ajout de la nouvelle valeur
                        FirebaseFirestore.instance
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
                                "nbBen": int.parse(nbBenContoller.text.trim()),
                                "check": false
                              }
                            ])
                          },
                        ),
                        Get.back(),
                      })
                  .then((value) {
                    FirebaseFirestore.instance
                        .collection('pos_hor')
                        .doc(Get.arguments['posteId'].toString())
                        .get()
                        .then((snapshot) {
                      var horList = snapshot.data()!['hor'] as List<dynamic>;
                      horList.sort((a, b) => a['debut'].compareTo(b['debut']));
                      FirebaseFirestore.instance
                          .collection('pos_hor')
                          .doc(Get.arguments['posteId'].toString())
                          .update({'hor': horList});
                    });
                  });
              ;
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
