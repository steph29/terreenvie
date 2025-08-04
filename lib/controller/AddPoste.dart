// ignore_for_file: prefer_const_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPoste extends StatefulWidget {
  const AddPoste({Key? key}) : super(key: key);

  @override
  State<AddPoste> createState() => _AddPosteState();
}

class _AddPosteState extends State<AddPoste> {
  TextEditingController posteContoller = TextEditingController();
  TextEditingController descContoller = TextEditingController();
  TextEditingController debutContoller = TextEditingController();
  TextEditingController finContoller = TextEditingController();
  TextEditingController nbBenContoller = TextEditingController();

  List<Map<String, dynamic>> horList = [];
  int? editingIndex;
  bool isEdition = false;
  String? posteId;

  @override
  void initState() {
    super.initState();
    // Vérifier si on est en mode édition
    if (Get.arguments != null && Get.arguments['posteId'] != null) {
      isEdition = true;
      posteId = Get.arguments['posteId'];
      posteContoller.text = Get.arguments['poste'] ?? '';
      descContoller.text = Get.arguments['desc'] ?? '';
      _loadHoraires();
    }
  }

  Future<void> _loadHoraires() async {
    if (posteId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('pos_hor')
          .doc(posteId)
          .get();
      if (doc.exists) {
        setState(() {
          horList = List<Map<String, dynamic>>.from(doc.data()!['hor'] ?? []);
        });
      }
    }
  }

  void _clearHoraireFields() {
    debutContoller.clear();
    finContoller.clear();
    nbBenContoller.clear();
    editingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdition ? "Modifier le poste" : "Créer un poste"),
        backgroundColor: Color(0xFFf2f0e7),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Formulaire principal
            Card(
              color: Color(0xFFf2f0e7),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations du poste",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2b5a72),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: posteContoller,
                      decoration: InputDecoration(
                        labelText: "Nom du poste",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: descContoller,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Section des créneaux horaires
            Card(
              color: Color(0xFFf2f0e7),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Créneaux horaires",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2b5a72),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Formulaire pour ajouter/modifier un créneau
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: debutContoller,
                            decoration: InputDecoration(
                              labelText: "Heure début (ex: 09h00)",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: finContoller,
                            decoration: InputDecoration(
                              labelText: "Heure fin (ex: 12h00)",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: nbBenContoller,
                            decoration: InputDecoration(
                              labelText: "Nombre de places",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (debutContoller.text.isNotEmpty &&
                                finContoller.text.isNotEmpty &&
                                nbBenContoller.text.isNotEmpty) {
                              setState(() {
                                if (editingIndex != null) {
                                  // Modifier un créneau existant
                                  horList[editingIndex!] = {
                                    'debut': debutContoller.text.trim(),
                                    'fin': finContoller.text.trim(),
                                    'nbBen':
                                        int.parse(nbBenContoller.text.trim()),
                                    'tot':
                                        int.parse(nbBenContoller.text.trim()),
                                    'check': false,
                                  };
                                  editingIndex = null;
                                } else {
                                  // Ajouter un nouveau créneau
                                  horList.add({
                                    'debut': debutContoller.text.trim(),
                                    'fin': finContoller.text.trim(),
                                    'nbBen':
                                        int.parse(nbBenContoller.text.trim()),
                                    'tot':
                                        int.parse(nbBenContoller.text.trim()),
                                    'check': false,
                                  });
                                }
                                _clearHoraireFields();
                              });
                            }
                          },
                          child: Text(
                              editingIndex != null ? "Modifier" : "Ajouter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2b5a72),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        if (editingIndex != null)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                editingIndex = null;
                                _clearHoraireFields();
                              });
                            },
                            child: Text("Annuler"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Liste des créneaux existants
            if (horList.isNotEmpty) ...[
              Card(
                color: Color(0xFFf2f0e7),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Créneaux existants",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2b5a72),
                        ),
                      ),
                      SizedBox(height: 15),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: horList.length,
                        itemBuilder: (context, index) {
                          final hor = horList[index];
                          return Card(
                            child: ListTile(
                              title: Text("${hor['debut']} - ${hor['fin']}"),
                              subtitle: Text("Places: ${hor['nbBen']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        editingIndex = index;
                                        debutContoller.text = hor['debut'];
                                        finContoller.text = hor['fin'];
                                        nbBenContoller.text =
                                            hor['nbBen'].toString();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        horList.removeAt(index);
                                      });
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
                ),
              ),
            ],

            SizedBox(height: 30),

            // Boutons d'action
            Row(
              children: [
                if (!isEdition)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (posteContoller.text.isNotEmpty &&
                            descContoller.text.isNotEmpty &&
                            horList.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection("pos_hor")
                              .add({
                            "poste": posteContoller.text.trim(),
                            "desc": descContoller.text.trim(),
                            "hor": horList,
                            "jour": Get.arguments['jour'] ?? "Samedi",
                          });
                          Get.back();
                        }
                      },
                      child: Text(
                        "Créer le poste",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(43, 90, 114, 1),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(242, 240, 231, 1),
                      ),
                    ),
                  ),
                if (isEdition)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (posteContoller.text.isNotEmpty &&
                            descContoller.text.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection("pos_hor")
                              .doc(posteId)
                              .update({
                            "poste": posteContoller.text.trim(),
                            "desc": descContoller.text.trim(),
                            "hor": horList,
                          });
                          Get.back();
                        }
                      },
                      child: Text(
                        "Mettre à jour le poste",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(43, 90, 114, 1),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(242, 240, 231, 1),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
