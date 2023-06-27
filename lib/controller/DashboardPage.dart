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
        appBar: AppBar(title: Text("Votre tableau de bord")),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    userId != null ? buildCard() : Text('Pas de données'),
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

  Widget buildCard() => StreamBuilder(
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
              child: GridView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var pos = snapshot.data!.docs[i]['pos_id'];
                  var posteId = snapshot.data?.docs[i].id;
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
                          SizedBox(
                            height: 500,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Vous êtes inscrit pour: ",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2b5a72)),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  buildList(pos, posteId, snapshot, i)
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
  Widget buildList(poste, posteId, snapshot, i) => ListView.builder(
      shrinkWrap: true,
      itemCount: poste.length,
      itemBuilder: (context, j) {
        var horId = snapshot.data?.docs[i]['pos_id'][j];
        var hord = snapshot.data?.docs[i]['pos_id'][j]["debut"];
        var horf = snapshot.data?.docs[i]['pos_id'][j]["fin"];
        var jour = snapshot.data?.docs[i]['pos_id'][j]['jour'];
        var postes = snapshot.data?.docs[i]['pos_id'][j]['poste'];

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
            trailing: ElevatedButton(
              child: Icon(Icons.delete),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("pos_ben")
                    .doc(posteId)
                    .delete();
              },
            ),
          ),
        );
      });
}
