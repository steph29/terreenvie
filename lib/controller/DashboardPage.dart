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
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding: EdgeInsets.all(20.0),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("pos_hor")
                        .where("jour", isEqualTo: "5")
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
                              var poste = snapshot.data!.docs[i]['poste'];
                              var desc = snapshot.data!.docs[i]['desc'];
                              var hor = snapshot.data!.docs[i]['debut'];

                              return Card(
                                color: Color(0xFFf2f0e7),
                                child: Container(
                                  height: 290,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              poste,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Text(poste),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      desc,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    Text(
                                                      hor,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 0.0,
                              mainAxisSpacing: 5,
                              mainAxisExtent: 264,
                            ),
                          ),
                        );
                      }

                      return Container();
                    },
                  ),
                )),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        OutlinedButton(
          onPressed: () {
//  Get.to(() => );  Il faut une page qui lit pos_hor
          },
          child: Text(
            "Je choisi un nouveau créneau",
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
      ],
    ));
  }
}
