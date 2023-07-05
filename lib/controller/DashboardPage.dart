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
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data found"));
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
        var posteId = snapshot.data?.docs[i]['pos_id'][j]['posteId'];

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
                await FirebaseFirestore.instance
                    .collection("pos_ben")
                    .doc(posteId)
                    .delete();
                // updateCheckedValue()
              },
            ),
          ),
        );
      });

  void updateCheckedValue(String posteId, bool checked, int nben, String debut,
      String fin, String poste, String desc, String jour) {
    FirebaseFirestore.instance
        .collection('pos_hor')
        // .where("posteId", isEqualTo: posteId).where("")
        .doc(posteId.toString())
        .update({
      "jour": jour,
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
        "jour": jour.toString(),
        "poste": poste.toString(),
        "desc": desc,
        'hor': FieldValue.arrayUnion([
          {
            "check": false,
            "debut": debut,
            "fin": fin,
            "nbBen": nben + 1,
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
