import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/AddPoste.dart';
import 'package:terreenvie/controller/EditHoraire.dart';
import 'package:terreenvie/controller/EditPoste.dart';
import 'package:terreenvie/model/create.dart';
import 'MainAppController.dart';

class CardAdmin extends StatefulWidget {
  const CardAdmin({super.key});

  @override
  State<CardAdmin> createState() => _CardAdminState();
}

class _CardAdminState extends State<CardAdmin> with ChangeNotifier {
  TextEditingController posteContoller = TextEditingController();
  TextEditingController descContoller = TextEditingController();
  TextEditingController heureContoller = TextEditingController();
  TextEditingController nbBenContoller = TextEditingController();

  User? userId = FirebaseAuth.instance.currentUser;
  var jour = "Samedi";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("pos_hor")
          .where("jour", isEqualTo: jour)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          print(jour);
          return Center(child: Text("No data found"));
        }
        if (snapshot != null && snapshot.data != null) {
          print(jour);
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
                    constraints:
                        const BoxConstraints(minHeight: 0, maxHeight: 500.0),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Bouton Ajouter un horaire
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      // print(_postsSnap);
                                      Get.to(() => AddPoste(), arguments: {
                                        "poste": poste,
                                        "desc": desc,
                                        "posteId": posteId,
                                      });
                                    },
                                    icon: Icon(Icons.edit),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF2b5a72),
                                    ),
                                  ),
                                ),
                                Text(
                                  poste,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              desc,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Column(
                              children: [
                                buildList(
                                    poste, hor, desc, posteId, snapshot, i),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 5,
                mainAxisExtent: 500,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget buildList(poste, hors, desc, posteId, snapshot, i) => ListView.builder(
      shrinkWrap: true,
      itemCount: hors.length,
      itemBuilder: (context, j) {
        var horId = snapshot.data?.docs[i]['hor'][j];
        var hord = snapshot.data?.docs[i]['hor'][j]["debut"];
        var horf = snapshot.data?.docs[i]['hor'][j]["fin"];
        var nben = snapshot.data?.docs[i]['hor'][j]['nbBen'];

        // final sortedItems = hors
        //   ..sort((item1, item2) => item2.compareTo(item1));
        // final hor = sortedItems[j];

        return Card(
          child: ListTile(
            title: Text(
              hord + ' - ' + horf + ' avec ' + nben + ' benevoles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            trailing: Container(
              width: 70,
              child: Row(children: [
                // Bouton DELETE
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      print(jour);
                    },
                    icon: Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF2b5a72),
                    ),
                  ),
                ),
                // Bouton MODIFIER
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Get.to(() => EditPoste(), arguments: {
                        "jour": jour,
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
                      primary: Color(0xFF2b5a72),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        );
      });
}
