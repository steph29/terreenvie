import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/AddPoste.dart';
import 'package:terreenvie/controller/EditHoraire.dart';
import 'package:terreenvie/controller/EditPoste.dart';
import 'package:terreenvie/model/create.dart';
import 'MainAppController.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({Key? key}) : super(key: key);

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  User? userId = FirebaseAuth.instance.currentUser;

  String groupValue = "Samedi";
  bool isCurrentUserOwner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Faites votre sélection"),
          backgroundColor: Color(0xFF2b5a72),
        ),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        buildSegmentControl(),
                        SizedBox(
                          height: 30,
                        ),

                        // Liste des cards
                        buildCard(groupValue),
                        SizedBox(
                          height: 30,
                        ),
                      ])),
            ],
          ),
        ));
  }

  Widget buildSegmentControl() => CupertinoSegmentedControl<String>(
      padding: EdgeInsets.all(20),
      groupValue: groupValue,
      selectedColor: Color(0xFF2b5a72),
      unselectedColor: Colors.white,
      borderColor: Color(0xFF2b5a72),
      pressedColor: Color(0xFF2b5a72).withOpacity(0.2),
      children: {
        "Mardi": buildSegment("Mardi"),
        "Mercredi": buildSegment("Mercredi"),
        "Jeudi": buildSegment("Jeudi"),
        "Vendredi": buildSegment("Vendredi"),
        "Samedi": buildSegment("Samedi"),
        "Dimanche": buildSegment("Dimanche"),
        "Lundi": buildSegment("Lundi"),
      },
      onValueChanged: (groupValue) {
        print(groupValue);
        setState(() {
          this.groupValue = groupValue;
        });
      });

  Widget buildCard(String groupValue) => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("pos_hor")
            .where("jour", isEqualTo: groupValue)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Quartier Libre !"));
          }
          if (snapshot != null && snapshot.data != null) {
            return Center(
              child: GridView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var poste = snapshot.data!.docs[i]['poste'];
                  var desc = snapshot.data!.docs[i]['desc'];
                  var hor = snapshot.data?.docs[i]['hor'];
                  var posteId = snapshot.data?.docs[i].id;

                  // Vérifier si l'utilisateur connecté est le propriétaire du poste
                  String currentUserId = userId!.uid;
                  String ownerId = snapshot.data?.docs[i]['ben_id'];
                  isCurrentUserOwner = currentUserId == ownerId;

                  return Card(
                    color: Color(0xFFf2f0e7),
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: 0, maxHeight: 500.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    poste,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2b5a72)),
                                  ),
                                ],
                              ),
                              Text(
                                desc,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2b5a72)),
                              ),
                              Column(
                                children: [
                                  buildButtonList(
                                      poste, hor, desc, posteId, snapshot, i)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                gridDelegate: (MediaQuery.of(context).size.width >= 1024)
                    ? SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 5,
                        mainAxisExtent: (groupValue == 'Lundi' ||
                                groupValue == 'Jeudi' ||
                                groupValue == 'Mardi')
                            ? 250
                            : 450,
                      )
                    : ((MediaQuery.of(context).size.width <= 1024 &&
                            MediaQuery.of(context).size.width >= 640)
                        ? SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 0.0,
                            mainAxisSpacing: 5,
                            mainAxisExtent: (groupValue == 'Lundi' ||
                                    groupValue == 'Jeudi' ||
                                    groupValue == 'Mardi')
                                ? 250
                                : 450,
                          )
                        : (SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 0.0,
                            mainAxisSpacing: 5,
                            mainAxisExtent: (groupValue == 'Lundi' ||
                                    groupValue == 'Jeudi' ||
                                    groupValue == 'Mardi')
                                ? 250
                                : 450,
                          ))),
              ),
            );
          }
          return Container();
        },
      );

  Widget buildSegment(String text) => Container(
        padding: EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      );

  Widget buildButtonList(poste, hors, desc, posteId, snapshot, i) =>
      ListView.builder(
        shrinkWrap: true,
        itemCount: hors.length,
        itemBuilder: (context, index) {
          var horId = snapshot.data?.docs[i]['hor'][index];
          var horIds = snapshot.data?.docs[i]['hor'][index].toString();
          var hord = horId["debut"];
          var horf = horId["fin"];
          var nben = horId['nbBen'];
          var checked = horId['check'];

          return Card(
            child: ListTile(
              title: (nben != 0)
                  ? Text(
                      hord +
                          ' - ' +
                          horf +
                          ' avec ' +
                          nben.toString() +
                          ' benevoles',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2b5a72)),
                    )
                  : Text(
                      hord + ' - ' + horf,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2b5a72)),
                    ),
              trailing: (nben != 0)
                  ? Container(
                      width: 70,
                      child: Row(
                        children: [
                          Expanded(
                              child: IconButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF2b5a72),
                            ),
                            icon: Icon(Icons.check_circle),
                            onPressed: () {
                              setState(() {
                                checked = !checked;
                                checked
                                    ? insertNewPoste(posteId, poste, hord, desc,
                                        horf, groupValue)
                                    : null;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Merci "),
                                    content: Text(
                                        "Votre sélection est bien enregistrée. Vous pouvez la retrouver dans votre tableau de bord."),
                                    actions: [
                                      TextButton(
                                        child: Text("Poursuivre"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                                // Mettre à jour la valeur de checked dans Firestore
                                updateCheckedValue(posteId, checked, nben, hord,
                                    horf, poste, desc);
                                print(nben);
                              });
                            },
                          )),
                        ],
                      ),
                    )
                  : Container(
                      child: Text("Complet"),
                    ),
            ),
          );
        },
      );

  void insertNewPoste(String posteId, String poste, String debut, String desc,
      String fin, String jour) {
    FirebaseFirestore.instance.collection("pos_ben").doc().set({
      "createdAt": DateTime.now(),
      "pos_id": FieldValue.arrayUnion([
        {
          "debut": debut,
          "fin": fin,
          "poste": poste,
          "desc": desc,
          "jour": jour,
          "posteId": posteId
        }
      ]),
      "ben_id": userId?.uid,
    });
  }

  void updateCheckedValue(String posteId, bool checked, int nben, String debut,
      String fin, String poste, String desc) {
    FirebaseFirestore.instance
        .collection('pos_hor')
        .doc(posteId.toString())
        .update({
      "jour": groupValue,
      "poste": poste,
      "desc": desc,
      "hor": FieldValue.arrayRemove([
        {"debut": debut, "fin": fin, "nbBen": nben, "check": !checked}
      ]),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('pos_hor')
          .doc(posteId.toString())
          .update({
        "jour": groupValue.toString(),
        "poste": poste.toString(),
        "desc": desc,
        'hor': FieldValue.arrayUnion([
          {
            "check": false,
            "debut": debut,
            "fin": fin,
            "nbBen": checked ? nben - 1 : nben + 1,
          }
        ])
      }).then((value) {
        FirebaseFirestore.instance
            .collection('pos_hor')
            .doc(posteId.toString())
            .get()
            .then((snapshot) {
          var horList = snapshot.data()!['hor'] as List<dynamic>;
          horList.sort((a, b) => a['debut'].compareTo(b['debut']));
          FirebaseFirestore.instance
              .collection('pos_hor')
              .doc(posteId.toString())
              .update({'hor': horList});
        });
      });
    });
  }
}
