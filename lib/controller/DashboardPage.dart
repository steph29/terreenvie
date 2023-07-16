import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/create.dart';

class DashboardPage extends StatefulWidget {
  // const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    //  const DashboardPage({Key? key}) : super(key: key);

    return Scaffold(
        appBar: AppBar(
          title: Text("Votre tableau de bord"),
          backgroundColor: Color(0xFF2b5a72),
        ),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    userId != null ? buildCardList() : Text('Pas de données'),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget buildCardList() => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("pos_ben")
            .where("ben_id", isEqualTo: userId!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Oups! une erreur est survenue");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                    "Vous n'avez pas encore de créneau sélectionné. Allez dans l'onglet Choisir ses postes"));
          }
          if (snapshot != null && snapshot.data != null) {
            return Center(
              child: ListView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var pos = snapshot.data!.docs[i]['pos_id'];
                  var posteId = snapshot.data?.docs[i].id;
                  return Center(
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: 0, maxHeight: 200.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  buildList(pos, posteId, snapshot, i),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      );

  Widget buildList(poste, posteId, snapshot, i) => ListView.builder(
      shrinkWrap: true,
      itemCount: poste.length,
      itemBuilder: (context, j) {
        var horId = snapshot.data?.docs[i]['pos_id'][j];
        var hord = snapshot.data?.docs[i]['pos_id'][j]["debut"];
        var horf = snapshot.data?.docs[i]['pos_id'][j]["fin"];
        var jour = snapshot.data?.docs[i]['pos_id'][j]['jour'];
        var postes = snapshot.data?.docs[i]['pos_id'][j]['poste'];
        var idPoste = snapshot.data?.docs[i]['pos_id'][j]['posteId'];

        return Card(
          child: ListTile(
            title: Text(
              postes.toString() +
                  ' - ' +
                  jour.toString() +
                  ' - ' +
                  hord +
                  '-' +
                  horf,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2b5a72)),
            ),
            trailing: IconButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF2b5a72),
              ),
              icon: Icon(Icons.delete),
              onPressed: () async {
                updatePosHor(idPoste, hord, horf);
                // UpdateBen(idPoste, posteId, hord, horf);

                await FirebaseFirestore.instance
                    .collection("pos_ben")
                    .doc(posteId.toString())
                    .delete();
              },
            ),
          ),
        );
      });

  void updatePosHor(String posteId, String debut, String fin) {
    FirebaseFirestore.instance
        .collection('pos_hor')
        .doc(posteId)
        .get()
        .then((snapshot) {
      var horList = snapshot.data()!['hor'] as List<dynamic>;
      for (var hor in horList) {
        if (hor['debut'] == debut && hor['fin'] == fin) {
          hor['nbBen'] = hor['nbBen'] + 1;
          break;
        }
      }
      FirebaseFirestore.instance
          .collection('pos_hor')
          .doc(posteId)
          .update({'hor': horList});
    });
  }

  Widget UpdateBen(String idPoste, String posteId, String debut, String fin) =>
      StreamBuilder(
        //  On récupère les informations de posteId

        stream: FirebaseFirestore.instance.collection("pos_ben").where("pos_id",
            arrayContains: {"posteId": idPoste, "debut": debut}).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(FieldPath.documentId);

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data found"));
          }
          if (snapshot != null && snapshot.data != null) {
            // var doc = snapshot.data.docs.first;
            // var documentId = doc.id;
            // print("hello");
            List<String> postesIds =
                snapshot.data!.docs.map((doc) => doc.id).toList();
            // On met à jour les informations dans pos_hor
          }
          return Container();
        },
      );
}
