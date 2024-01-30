import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/AddPoste.dart';
import 'package:terreenvie/controller/EditPoste.dart';
import 'package:terreenvie/model/create.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController posteContoller = TextEditingController();
  TextEditingController descContoller = TextEditingController();
  TextEditingController heureContoller = TextEditingController();
  TextEditingController nbBenContoller = TextEditingController();

  User? userId = FirebaseAuth.instance.currentUser;
  String groupValue = "Samedi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Le coin des référents"),
          backgroundColor: Color(0xFFf2f0e7),
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
                        OutlinedButton(
                          onPressed: () {
                            Get.to(() => Create(), arguments: {
                              "jour": groupValue,
                            });
                          },
                          child: Text(
                            "Je rajoute un poste",
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
            .collection("users")
            .where("UserId", isEqualTo: userId!.uid)
            .where("profil", whereIn: ["admin", "ref"]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data found"));
          }
          if (snapshot.data != null) {
            List<String> adminUserIds =
                snapshot.data!.docs.map((doc) => doc.id).toList();

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("pos_hor")
                  .where("jour", isEqualTo: groupValue)
                  .where("ben_id", whereIn: adminUserIds)
                  .orderBy('poste')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("Something went wrong: ${snapshot.error}");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Quartier Libre !"));
                }
                if (snapshot.data != null) {
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
                        return Card(
                          color: Color(0xFFf2f0e7),
                          child: Container(
                            constraints: const BoxConstraints(
                                minHeight: 0, maxHeight: 500.0),
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
                                        // Bouton Ajouter un horaire
                                        IconButton(
                                          onPressed: () {
                                            Get.to(() => AddPoste(),
                                                arguments: {
                                                  "poste": poste,
                                                  "desc": desc,
                                                  "posteId": posteId,
                                                });
                                          },
                                          icon: Icon(Icons.edit),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFf2f0e7),
                                          ),
                                        ),
                                        // Bouton delete
                                        IconButton(
                                          onPressed: () async {
                                            print(posteId.toString());
                                            await FirebaseFirestore.instance
                                                .collection("pos_hor")
                                                .doc(posteId.toString())
                                                .delete();
                                          },
                                          icon: Icon(Icons.delete),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFf2f0e7),
                                          ),
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
                                        buildList(poste, hor, desc, posteId,
                                            snapshot, i),
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

  Widget buildList(poste, hors, desc, posteId, snapshot, i) => ListView.builder(
      shrinkWrap: true,
      itemCount: hors.length,
      itemBuilder: (context, j) {
        var horId = snapshot.data?.docs[i]['hor'][j];
        var hord = snapshot.data?.docs[i]['hor'][j]["debut"];
        var horf = snapshot.data?.docs[i]['hor'][j]["fin"];
        var nben = snapshot.data?.docs[i]['hor'][j]['nbBen'];

        return Card(
          child: ListTile(
            title: Text(
              hord + ' - ' + horf + ' avec ' + nben.toString() + ' benevoles',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2b5a72)),
            ),
            trailing: Container(
              width: 70,
              child: Row(children: [
                // Bouton DELETE
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("pos_hor")
                          .doc(posteId.toString())
                          .get()
                          .then((doc) {
                        if (doc.exists) {
                          List<dynamic> horaires = doc.data()!['hor'];
                          horaires.removeWhere((horaire) {
                            return (horaire['debut'] == hord &&
                                horaire['fin'] == horf &&
                                horaire['nbBen'] == nben);
                          });

                          FirebaseFirestore.instance
                              .collection("pos_hor")
                              .doc(posteId.toString())
                              .update({"hor": horaires}).then((value) {
                            // Suppression réussie
                          }).catchError((error) {
                            // Gestion des erreurs
                          });
                        }
                      });
                    },
                    icon: Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf2f0e7),
                    ),
                  ),
                ),
                // Bouton MODIFIER
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Get.to(() => EditPoste(), arguments: {
                        "jour": groupValue,
                        "poste": poste,
                        "desc": desc,
                        "horId": horId,
                        "debut": hord,
                        "fin": horf,
                        "nbBen": nben,
                        "posteId": posteId,
                      });
                    },
                    icon: Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf2f0e7),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        );
      });
}
