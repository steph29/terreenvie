import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syn;
import 'package:open_file/open_file.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'PDF/web.dart';
import 'PDF/mobile.dart';

class Analyse extends StatefulWidget {
  const Analyse({Key? key}) : super(key: key);

  @override
  State<Analyse> createState() => _AnalyseState();
}

class _AnalyseState extends State<Analyse> {
  String groupValue = "Samedi";
  List<List<dynamic>> test = [];
  List<List<dynamic>> items = [];
  List<String> poste = ['Animation Sonore'];
  String? selectedPoste;
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ki kè où?"),
        backgroundColor: Color(0xFF2b5a72),
      ),
      body: Column(
        children: [
          buildSegmentControl(),
          new DropdownButton<String>(
              items: <String>[
                'Animation Sonores',
                'Atelier animation enfants',
                'Barriere',
                'benevoles volants',
                'Bénévole Volant',
                'Benevoles volants',
                'Buvette principale',
                'Chapiteau',
                'Conferences',
                'Decoration',
                'Electricite',
                'Entree',
                'Exposants',
                'Faire les crepes',
                'Flechage',
                'Flechage / Signalétique',
                'Montage',
                'Plomberie',
                'Restauration Benevoles',
                'Restauration Visiteurs',
                'Secours',
                'Sono',
                'Stand',
                'Surveillance',
                'Tisanerie',
                'Toilettes seches',
                'Vaisselle',
                'Ventes de crepes'
              ].map((String value) {
                //La fonction crée un objet qui aura la même valeur et le même texte, à partir du tableau d'objet
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              hint: const Text(
                'Quel poste voulez-vous sélectionner ?',
              ),
              value: selectedPoste,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPoste = newValue;
                });
              }),
          Expanded(
            child: FutureBuilder<List<List<dynamic>>>(
              future: fetchData(groupValue),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    strokeWidth: 4,
                  );
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Aucune donnée disponible.');
                }
                List<List<dynamic>> items = snapshot.data!;
                print(totalCount);
                return ListView(
                  children: items.map((item) {
                    // Créez des Widgets à partir des données de chaque élément
                    return ListTile(
                      title: Text(
                          'Nom, prénom, tél : ${item[0]} ${item[1]} ${item[2]}'),
                      subtitle: Text(
                          'Poste: le ${item[3]} à ${item[4]} de ${item[5]} à ${item[6]}'),
                      // Ajoutez d'autres éléments ici en fonction de votre structure de données
                    );
                  }).toList(), //snapshot.data!,
                );
              },
            ),
          ),
          // FutureBuilder(
          //     future: fetchData(groupValue),
          //     builder: (context, snapshot) {
          //       return Text('Nombre de bénévoles : $totalCount');
          //     }),
          ElevatedButton(
            onPressed: () async {
              await _createPDF();
            },
            child: Text("Générer PDF"),
          ),
        ],
      ),
    );
  }

  Widget buildSegmentControl() => CupertinoSegmentedControl<String>(
      padding: EdgeInsets.all(15),
      groupValue: groupValue,
      selectedColor: Color(0xFF2b5a72),
      unselectedColor: Colors.white,
      borderColor: Color(0xFF2b5a72),
      pressedColor: Color(0xFF2b5a72).withOpacity(0.2),
      children: {
        "Mardi": buildSegment("Mardi"),
        "Mercredi": buildSegment("Mercredi"),
        "Jeudi": buildSegment("Jeudi"),
        "Vendredi": buildSegment("Vendredi"),
        "Samedi": buildSegment("Samedi"),
        "Dimanche": buildSegment("Dimanche"),
        "Lundi": buildSegment("Lundi"),
      },
      onValueChanged: (groupValue) {
        print(groupValue);
        setState(() {
          this.groupValue = groupValue;
        });
      });

  Widget buildSegment(String text) => Container(
        padding: EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      );

  Future<List<List>> fetchData(String groupValue) async {
    items = [];
    Widget? itemWidget = null;
    totalCount = 0;
    QuerySnapshot<Map<String, dynamic>> posBenSnapshot =
        await FirebaseFirestore.instance.collection('pos_ben').get();

    // Convertissez les documents en une liste pour trier les résultats
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        posBenSnapshot.docs;

    // Triez les documents en fonction du champ "poste" à l'index 0, puis du champ "jour"
    documents.sort((a, b) {
      String posteA = a.get('pos_id')[0]['poste'] ?? '';
      String posteB = b.get('pos_id')[0]['poste'] ?? '';
      String jourA = a.get('pos_id')[0]['jour'] ?? 0;
      String jourB = b.get('pos_id')[0]['jour'] ?? 0;
      String heureA = a.get('pos_id')[0]['debut'] ?? 0;
      String HeureB = b.get('pos_id')[0]['debut'] ?? 0;

      int posteComparison = posteA.compareTo(posteB);
      int jourComparaison = jourA.compareTo(jourB);

      if (posteComparison == 0) {
        // Si les postes sont identiques, comparez par jour
        if (jourComparaison == 0) {
          return heureA.compareTo(HeureB);
        } else {
          return jourA.compareTo(jourB);
        }
      } else {
        return posteComparison;
      }
    });

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Accédez à la liste "pos_id"
      List<dynamic>? posIdList = data['pos_id'];
      if (posIdList != null && posIdList.isNotEmpty) {
        // Accédez au premier élément (index 0) de "pos_id"
        Map<String, dynamic>? firstPosId = posIdList[0];
        if (firstPosId != null) {
          // Accédez au champ "jour" dans le premier élément de "pos_id"
          String? jour = firstPosId['jour'];
          String? poste = firstPosId['poste'];

          if (jour != null && jour == groupValue) {
            // Si le champ "jour" correspond à groupValue, ajoutez cet élément à la liste
            if (poste != null && poste == selectedPoste) {
              String? benevoleId = data['ben_id'] as String?;

              if (benevoleId != null) {
                DocumentSnapshot<Map<String, dynamic>> userSnapshot =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(benevoleId)
                        .get();

                if (userSnapshot.exists) {
                  Map<String, dynamic> userData =
                      userSnapshot.data() as Map<String, dynamic>;

                  itemWidget = ListTile(
                    title: Text(
                        'Nom et prénom de l\'utilisateur: ${userData['nom']} ${userData['prenom']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Élément du poste: ${data['pos_id'][0]['poste']} de ${data['pos_id'][0]['debut']} à ${data['pos_id'][0]['fin']} le ${data['pos_id'][0]['jour']}'), // Remplacez "votre_champ" par le champ que vous souhaitez afficher
                        // Ajoutez d'autres champs de "pos_ben" ici si nécessaire
                      ],
                    ),
                  );
                  items.add([
                    userData['nom'],
                    userData['prenom'],
                    userData['tel'],
                    data['pos_id'][0]['jour'],
                    data['pos_id'][0]['poste'],
                    data['pos_id'][0]['debut'],
                    data['pos_id'][0]['fin']
                  ]);
                  totalCount++;
                }
              }
            }
          }
        }
      }
    }
    return items;
  }

  Future<void> _createPDF() async {
    // Create a new PDF document.
    PdfDocument document = PdfDocument();
    // Add a new page to the document.
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    page.graphics.drawImage(PdfBitmap(await _readImageData('logoTEV.png')),
        Rect.fromLTWH(0, 0, 40, 40));

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));
    grid.columns.add(count: 7);
    grid.headers.add(1);

    PdfGridRow headers = grid.headers[0];
    headers.cells[0].value = 'Nom';
    headers.cells[1].value = 'Prenom';
    headers.cells[2].value = 'Téléphone';
    headers.cells[3].value = 'Jour';
    headers.cells[4].value = 'poste';
    headers.cells[5].value = 'debut';
    headers.cells[6].value = 'fin';

    for (var i = 0; i < items.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = items[i][0];
      row.cells[1].value = items[i][1];
      row.cells[2].value = items[i][2];
      row.cells[3].value = items[i][3];
      row.cells[4].value = items[i][4];
      row.cells[5].value = items[i][5];
      row.cells[6].value = items[i][6];
    }

    grid.draw(
        page: document.pages.add(),
        bounds: Rect.fromLTWH(0, 55, pageSize.width, pageSize.height));

    //Save the document
    List<int> bytes = await document.save();
    //Dispose the document
    document.dispose();
    //Download the output file
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "Bénévole_de_TEV.pdf")
      ..click();
  }

  Future<Uint8List> _readImageData(String name) async {
    final data = await rootBundle.load('$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
