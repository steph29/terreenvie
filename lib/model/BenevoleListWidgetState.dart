import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart'; // Pour imprimer et générer un PDF
import 'package:pdf/widgets.dart' as pw; // Package pour créer un PDF
import 'dart:async';
import 'package:terreenvie/controller/PDF/web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class BenevoleListWidget extends StatefulWidget {
  const BenevoleListWidget({Key? key}) : super(key: key);

  @override
  _BenevoleListWidgetState createState() => _BenevoleListWidgetState();
}

class _BenevoleListWidgetState extends State<BenevoleListWidget> {
  // Liste pour stocker les bénévoles uniques
  List<Map<String, dynamic>> benevoles = [];
  List<List<dynamic>> items = [];
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUniqueBenevoles();
  }

  // Fonction pour récupérer les bénévoles sans doublons
  Future<void> fetchUniqueBenevoles() async {
    Set<String> uniqueBenevoleIds = {}; // Set pour stocker les ben_id uniques
    List<Map<String, dynamic>> uniqueBenevoles =
        []; // Liste pour les bénévoles uniques

    try {
      // Récupérer tous les documents de la collection 'pos_ben'
      QuerySnapshot posBenSnapshot =
          await FirebaseFirestore.instance.collection('pos_ben').get();

      // Parcourir chaque document de 'pos_ben' pour extraire les ben_id
      for (var doc in posBenSnapshot.docs) {
        String benId = doc['ben_id'];

        // Ajouter benId au set (Set évite les doublons)
        uniqueBenevoleIds.add(benId);
      }

      // Récupérer les informations de chaque bénévole à partir des ben_id uniques
      for (String benId in uniqueBenevoleIds) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(benId)
            .get();

        if (userSnapshot.exists) {
          // Convertir les données en Map<String, dynamic>
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            uniqueBenevoles
                .add({'nom': userData['nom'], 'prenom': userData['prenom']});
          }
        }
      }

      // Mettre à jour la liste des bénévoles sans doublons
      setState(() {
        benevoles = uniqueBenevoles;
      });
    } catch (e) {
      print('Erreur lors de la récupération des bénévoles: $e');
    }
  }

  // Fonction pour générer le PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Ajouter une page avec la liste des bénévoles
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Liste des bénévoles', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.ListView.builder(
              itemCount: benevoles.length,
              itemBuilder: (context, index) {
                final benevole = benevoles[index];
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                  child: pw.Text(
                      '${benevole['prenom']} ${benevole['nom']} - Email: ${benevole['email']}, Téléphone: ${benevole['telephone']}'),
                );
              },
            ),
          ],
        ),
      ),
    );

    // Afficher l'aperçu avant impression
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: benevoles.isEmpty
          ? Container(
              child: CircularProgressIndicator(),
              width: (kIsWeb || MediaQuery.of(context).size.width > 920)
                  ? MediaQuery.of(context).size.width / 2.5
                  : MediaQuery.of(context).size.width / 1.1,
              height: MediaQuery.of(context).size.height / 2.5,
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: (kIsWeb || MediaQuery.of(context).size.width > 920)
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Couleur de fond du container
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 6,
                      child: ListView.builder(
                        itemCount: benevoles.length,
                        itemBuilder: (context, index) {
                          final benevole = benevoles[index];
                          return ListTile(
                            title: Text(
                              '${benevole['prenom']} ${benevole['nom']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Email: ${benevole['email']}, Téléphone: ${benevole['telephone']}',
                            ),
                          );
                        },
                      ),
                    )),
                    // Ajout du bouton dans un container aligné en bas
                    ElevatedButton(
                      onPressed: () async {
                        // Appeler fetchData avant la génération du PDF
                        await fetchData(); // Passer un paramètre si nécessaire

                        // Ensuite, générer le PDF avec les données récupérées
                        await _createPDF();
                      },
                      child: Text("Télécharger la liste des entrée"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _createPDF() async {
    // Create a new PDF document.
    PdfDocument document = PdfDocument();
    // Add a new page to the document.
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawImage(
    //     PdfBitmap(await _readImageData('assets/logoTEV.png')),
    //     Rect.fromLTWH(0, 0, 40, 40));

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));
    grid.columns.add(count: 2);
    grid.headers.add(1);

    PdfGridRow headers = grid.headers[0];
    headers.cells[0].value = 'Nom';
    headers.cells[1].value = 'Prenom';

    for (var i = 0; i < items.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = items[i][0];
      row.cells[1].value = items[i][1];
    }

    grid.draw(
        page: document.pages.add(),
        bounds: Rect.fromLTWH(0, 55, pageSize.width, pageSize.height));

    //Save the document
    CustomWebPdf().pdf(document);
  }

  Future<List<List>> fetchData() async {
    items = [];
    totalCount = 0;

    // Utiliser un Set pour stocker les noms complets (nom + prénom) afin d'éviter les doublons
    Set<String> uniqueBenevoles = {};

    // Requête Firestore pour récupérer les données des bénévoles
    QuerySnapshot<Map<String, dynamic>> posBenSnapshot =
        await FirebaseFirestore.instance.collection('pos_ben').get();

    // Convertir les documents en une liste pour les trier
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        posBenSnapshot.docs;

    // Filtrer les documents et récupérer les informations des bénévoles
    for (var document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<dynamic>? posIdList = data['pos_id'];

      if (posIdList != null && posIdList.isNotEmpty) {
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

            // Créer une clé unique (nom + prénom) pour détecter les doublons
            String fullName =
                '${userData['nom'].toUpperCase()} ${userData['prenom']}';

            // Vérifier si la clé existe déjà dans le Set
            if (!uniqueBenevoles.contains(fullName)) {
              // Ajouter la clé au Set et les détails dans items
              uniqueBenevoles.add(fullName);
              items.add([
                userData['nom'].toUpperCase(),
                userData['prenom'],
              ]);
              totalCount++;
            }
          }
        }
      }
    }
    // Trier par nom puis par prénom
    items.sort((a, b) {
      int nomComparison = a[0].compareTo(b[0]);
      if (nomComparison == 0) {
        return a[1].compareTo(b[1]); // Si les noms sont égaux, trier par prénom
      }
      return nomComparison;
    });

    return items;
  }
}
