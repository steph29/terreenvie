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
import 'package:terreenvie/controller/EditPoste.dart';
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

  String dropdownValue = list.first;

  DateTime currentDate = DateTime.now();
  TimeOfDay currentTimeBegin = TimeOfDay.now();
  TimeOfDay currentTimeEnd = TimeOfDay.now();

  final List<String> postes = [
    'Buvette principale',
    'Electricité',
    'Bénévoles volants'
  ];
  User? userId = FirebaseAuth.instance.currentUser;
  Future<void> _selectTimeBegin(BuildContext context) async {
    final TimeOfDay? pickerTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickerTime != null && pickerTime != currentTimeBegin) {
      setState(() {
        currentTimeBegin = pickerTime;
      });
    }
  }

  Future<void> _selectTimeEnd(BuildContext context) async {
    final TimeOfDay? pickerTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickerTime != null && pickerTime != currentTimeEnd) {
      setState(() {
        currentTimeEnd = pickerTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2023, 9, 18),
        firstDate: DateTime(2023, 9, 18),
        lastDate: DateTime(2023, 9, 25));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  bool _checked2 = false;
  PageController page = PageController();

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
                OutlinedButton(
                  onPressed: () {
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
                            var nbBen = snapshot.data!.docs[i]['nbBen'];
                            var posteId = snapshot.data!.docs[i].id;
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
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Icon(Icons.delete),
                                              style: ElevatedButton.styleFrom(
                                                primary: Color(0xFF2b5a72),
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(24),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Icon(Icons.add),
                                              style: ElevatedButton.styleFrom(
                                                primary: Color(0xFF2b5a72),
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(24),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.to(() => EditPoste(),
                                                    arguments: {
                                                      "poste": poste,
                                                      "desc": desc,
                                                      "hor": hor,
                                                      "nbBen": nbBen,
                                                      "posteId": posteId,
                                                    });
                                              },
                                              child: Icon(Icons.edit),
                                              style: ElevatedButton.styleFrom(
                                                primary: Color(0xFF2b5a72),
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(24),
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
              ])),
        ],
      ),
    ));
  }

  Widget cardPlus() {
    return Card(
      elevation: 8,
      child: Container(
          height: 290,
          width: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(24),
              ),
              child: Icon(Icons.add),
              onPressed: () {},
            ),
          )),
    );
  }
}
