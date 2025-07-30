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
  List<Map<String, dynamic>> posHorData = [];
  List<Map<String, dynamic>> usersData = [];
  bool isLoading = true;
  String groupValue = "Samedi";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
    });
    final posHorSnapshot =
        await FirebaseFirestore.instance.collection('pos_hor').get();
    posHorData = posHorSnapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return data;
    }).toList();
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    usersData = usersSnapshot.docs
        .map((d) => d.data() as Map<String, dynamic>)
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  Widget buildSegmentControl() => CupertinoSegmentedControl<String>(
      padding: EdgeInsets.all(0),
      groupValue: groupValue,
      selectedColor: Color(0xFF2b5a72),
      unselectedColor: Colors.white,
      borderColor: Color(0xFF2b5a72),
      pressedColor: Color(0xFF2b5a72).withOpacity(0.2),
      children: {
        "Mardi": (kIsWeb) ? buildSegment("Mardi") : buildSegment("Mar"),
        "Mercredi": (kIsWeb) ? buildSegment("Mercredi") : buildSegment("Mer"),
        "Jeudi": (kIsWeb) ? buildSegment("Jeudi") : buildSegment("Jeu"),
        "Vendredi": (kIsWeb) ? buildSegment("Vendredi") : buildSegment("Ven"),
        "Samedi": (kIsWeb) ? buildSegment("Samedi") : buildSegment("Sam"),
        "Dimanche": (kIsWeb) ? buildSegment("Dimanche") : buildSegment("Dim"),
        "Lundi": (kIsWeb) ? buildSegment("Lundi") : buildSegment("Lun"),
      },
      onValueChanged: (newValue) {
        setState(() {
          groupValue = newValue;
        });
      });

  Widget buildSegment(String text) => Container(
        padding: (kIsWeb) ? EdgeInsets.all(12) : EdgeInsets.all(3),
        child: Text(
          text,
          style: (kIsWeb)
              ? TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              : TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );

  Widget buildCardList() {
    // Filtrer les postes selon le jour sélectionné
    final filteredPosHor =
        posHorData.where((d) => d['jour'] == groupValue).toList();
    final isWeb = kIsWeb || MediaQuery.of(context).size.width >= 1024;
    return isWeb
        ? GridView.builder(
            controller: ScrollController(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            itemCount: filteredPosHor.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 5,
              mainAxisExtent: (groupValue == 'Lundi' ||
                      groupValue == 'Jeudi' ||
                      groupValue == 'Mardi')
                  ? 250
                  : 450,
            ),
            itemBuilder: (context, i) => buildPosteCard(filteredPosHor[i]),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: filteredPosHor.length,
            itemBuilder: (context, i) => buildPosteCard(filteredPosHor[i]),
          );
  }

  Widget buildPosteCard(Map<String, dynamic> posteData) {
    final poste = posteData['poste'] ?? '';
    final desc = posteData['desc'] ?? '';
    final horList = posteData['hor'] as List? ?? [];
    final posteId = posteData['id'] ?? '';
    return Card(
      color: Color(0xFFf2f0e7),
      child: Container(
        constraints: BoxConstraints(minHeight: 0, maxHeight: 500.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                poste,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2b5a72)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      print('Édition du posteId: $posteId');
                      // Ouvre la page d'édition du poste et attend le retour
                      await Get.to(() => AddPoste(), arguments: {
                        "poste": poste,
                        "desc": desc,
                        "posteId": posteId,
                      });
                      // Rafraîchir les données après retour de la page d'édition
                      _loadAllData();
                    },
                    icon: Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf2f0e7),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      print('Suppression du posteId: $posteId');
                      await FirebaseFirestore.instance
                          .collection("pos_hor")
                          .doc(posteId)
                          .delete();
                      _loadAllData();
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: horList.length,
                    itemBuilder: (context, j) {
                      final h = horList[j];
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${h['debut']} - ${h['fin']} (${h['nbBen'] ?? '-'} places restantes / ${h['tot'] ?? '-'} total)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF2b5a72)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // IconButton(
                              //   icon: Icon(Icons.edit),
                              //   onPressed: () {
                              //     // Ouvre la page d’édition du créneau
                              //   },
                              // ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final newHorList = List.from(horList)
                                    ..remove(h);
                                  await FirebaseFirestore.instance
                                      .collection('pos_hor')
                                      .doc(posteId)
                                      .update({'hor': newHorList});
                                  _loadAllData();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Le coin des référents"),
        backgroundColor: Color(0xFFf2f0e7),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  buildSegmentControl(),
                  SizedBox(height: 30),
                  buildCardList(),
                ],
              ),
            ),
    );
  }
}
