import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
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

const List<String> list = <String>[
  'Buvette principale',
  'Bénévoles volant',
  'tri selectif',
  'Tisanerie'
];
// Recupération des postes depuis la base de données

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              flex: 1,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  height: 30,
                ),
                SingleChoice(),
                SizedBox(
                  height: 30,
                ),
                OutlinedButton(
                  onPressed: () {
                    Get.to(() => Create());
                    print("J'ajoute un créneau");
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
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("pos_hor")
                      // .where("ben_id", isEqualTo: userId!.uid)
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Bouton Ajouter
                                            Expanded(
                                              child: IconButton(
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
                                            ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: hor.length,
                                                itemBuilder: (context, j) {
                                                  var horId = snapshot
                                                      .data?.docs[i]['hor'][j];
                                                  var hord =
                                                      snapshot.data?.docs[i]
                                                          ['hor'][j]["debut"];
                                                  var horf =
                                                      snapshot.data?.docs[i]
                                                          ['hor'][j]["fin"];
                                                  var nben =
                                                      snapshot.data?.docs[i]
                                                          ['hor'][j]['nbBen'];
                                                  return Card(
                                                    child: ListTile(
                                                      title: Text(
                                                        hord +
                                                            ' - ' +
                                                            horf +
                                                            ' avec ' +
                                                            nben +
                                                            ' benevoles',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      trailing: Container(
                                                        width: 70,
                                                        child: Row(children: [
                                                          // Bouton DELETE
                                                          Expanded(
                                                            child: IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "pos_hor")
                                                                    .doc(Get
                                                                        .arguments[
                                                                            'posteId']
                                                                        .toString())
                                                                    .update({});
                                                              },
                                                              icon: Icon(
                                                                  Icons.delete),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Color(
                                                                    0xFF2b5a72),
                                                              ),
                                                            ),
                                                          ),
                                                          // Bouton MODIFIER
                                                          Expanded(
                                                            child: IconButton(
                                                              onPressed: () {
                                                                print(hor[j]);
                                                                Get.to(
                                                                    () =>
                                                                        EditPoste(),
                                                                    arguments: {
                                                                      "poste":
                                                                          poste,
                                                                      "desc":
                                                                          desc,
                                                                      "horId":
                                                                          horId,
                                                                      "debut":
                                                                          hord,
                                                                      "fin":
                                                                          horf,
                                                                      "nbBen":
                                                                          nben,
                                                                      "posteId":
                                                                          posteId,
                                                                    });
                                                              },
                                                              icon: Icon(
                                                                  Icons.edit),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Color(
                                                                    0xFF2b5a72),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
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
                            mainAxisExtent: 500,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ])),
        ],
      ),
    ));
  }
}

enum Calendar { Mardi, Mercredi, Jeudi, Vendredi, Samedi, Diamnche, Lundi }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.Samedi;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.Mardi,
            label: Text('Mardi'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<Calendar>(
            value: Calendar.Mercredi,
            label: Text('Mercredi'),
            icon: Icon(Icons.calendar_view_month)),
        ButtonSegment<Calendar>(
            value: Calendar.Jeudi,
            label: Text('Jeudi'),
            icon: Icon(Icons.calendar_today)),
        ButtonSegment<Calendar>(
            value: Calendar.Vendredi,
            label: Text('Vendredi'),
            icon: Icon(Icons.calendar_today)),
        ButtonSegment<Calendar>(
            value: Calendar.Samedi,
            label: Text('Samedi'),
            icon: Icon(Icons.calendar_today)),
        ButtonSegment<Calendar>(
            value: Calendar.Diamnche,
            label: Text('Diamnche'),
            icon: Icon(Icons.calendar_today)),
        ButtonSegment<Calendar>(
            value: Calendar.Lundi,
            label: Text('Lundi'),
            icon: Icon(Icons.calendar_today)),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}
