import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../controller/DashboardPage.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  bool _checked = false;
  bool _checked2 = false;

  User? userId = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Les créneaux disponible"),
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                // flex: 1,
                child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20.0),
              child: Card(
                  elevation: 8,
                  child: SingleChildScrollView(
                    child: Container(
                        child: Column(
                      children: [
                        Row(
                          children: [
                            poste(),
                            poste(),
                            poste(),
                          ],
                        ),
                        Row(
                          children: [
                            poste(),
                            poste(),
                            poste(),
                          ],
                        ),
                        Row(
                          children: [
                            poste(),
                            poste(),
                            poste(),
                          ],
                        ),
                        Row(
                          children: [
                            poste(),
                            poste(),
                            poste(),
                          ],
                        ),
                      ],
                    )),
                  )),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 8,
        hoverElevation: 45,
        hoverColor: Colors.greenAccent,
        child: Text(
          "Je valide",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget poste() {
    return Expanded(
        flex: 1,
        child: Card(
          margin: EdgeInsets.all(8),
          elevation: 8,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Buvette Principale"),
                    // Image.asset("assets/logoTEV.png"),
                    Icon(Icons.wine_bar),
                  ],
                ),
                Text(
                  'Allez! Viens boire un p\'tit coup à la maison !',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
                ),
                CheckboxListTile(
                  title: const Text('1200h - 14h00'),
                  autofocus: false,
                  controlAffinity: ListTileControlAffinity.platform,
                  value: _checked,
                  onChanged: (bool? value) {
                    setState(() async {
                      _checked = value!;
                      if (_checked = true) {
                        await FirebaseFirestore.instance
                            .collection("pos_ben")
                            .doc()
                            .set({
                          "createdAt": DateTime.now(),
                          "ben_id": userId?.uid,
                          "pos_hor_id": "12h00-14h00"
                        });
                      } else {
                        try {} catch (e) {
                          print("Erreur $e");
                          FirebaseFirestore.instance
                              .collection("pos_ben")
                              .doc()
                              .delete();
                        }
                      }
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ), //CheckboxListT
                CheckboxListTile(
                  title: const Text('14h00 - 16h00'),
                  autofocus: false,
                  controlAffinity: ListTileControlAffinity.platform,
                  value: _checked2,
                  onChanged: (bool? value) {
                    setState(() {
                      _checked2 = value!;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ), //CheckboxListT
              ]),
        ));
  }
}
