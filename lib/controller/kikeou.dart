import 'dart:async';
import 'package:flutter/material.dart';
import 'package:terreenvie/controller/PDF/web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'Analyse.dart';

class Kikeou extends StatefulWidget {
  @override
  _KikeouState createState() => _KikeouState();
}

class _KikeouState extends State<Kikeou> {
  String? selectedPoste; // Le poste sélectionné dans le DropdownButton
  String? groupValue; // Valeur pour le jour sélectionné (ou autre filtre)
  List<List<dynamic>> items = [];
  int totalCount = 0;

  // Fonction pour récupérer dynamiquement les postes depuis Firestore
  Future<List<String>> fetchPostes() async {
    List<String> postes = [];

    // Accéder à la collection "pos_hor" pour récupérer les postes
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('pos_hor').get();

    // Extraire les postes et éviter les doublons
    for (var doc in snapshot.docs) {
      String poste = doc['poste'];
      if (!postes.contains(poste)) {
        postes.add(poste);
      }
    }

    return postes;
  }

  // Vous pouvez maintenant modifier votre build comme suit :
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchPostes(), // Récupère les postes dynamiquement
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(strokeWidth: 4),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erreur : ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Aucun poste disponible.'),
          );
        }

        List<String> postes = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.pinkAccent.withOpacity(0.1),
          ),
          width: (kIsWeb || MediaQuery.of(context).size.width > 920)
              ? MediaQuery.of(context).size.width / 2.5
              : MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 2.5,
          child: Column(
            children: [
              Text("Ki ké où "),
              buildSegmentControl(), // Si vous avez un segment pour gérer des filtres/jours

              // DropdownButton dynamique basé sur les postes récupérés
              DropdownButton<String>(
                items: postes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: const Text('Quel poste voulez-vous sélectionner ?'),
                value: selectedPoste,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPoste = newValue;
                  });
                },
              ),

              // FutureBuilder pour afficher les bénévoles après la sélection du poste
              FutureBuilder<List<List<dynamic>>>(
                future: fetchData(
                    groupValue), // Appelle fetchData avec la valeur sélectionnée
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
                  return Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 6,
                      child: ListView(
                        children: items.map((item) {
                          return ListTile(
                            title: Text(
                                'Nom, prénom, tél : ${item[0]} ${item[1]} ${item[2]}'),
                            subtitle: Text(
                                'Poste: le ${item[3]} à ${item[4]} de ${item[5]} à ${item[6]}'),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  // Afficher un indicateur de chargement
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Génération du PDF en cours...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  await _createPDF();
                },
                child: Text("Télécharger la liste"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSegmentControl() => CupertinoSegmentedControl<String>(
      padding: EdgeInsets.all(5),
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
      onValueChanged: (groupValue) {
        print(groupValue);
        setState(() {
          this.groupValue = groupValue;
        });
      });

  Widget buildSegment(String text) => Container(
        padding: (kIsWeb || MediaQuery.of(context).size.width > 920)
            ? EdgeInsets.all(7)
            : EdgeInsets.all(3),
        child: Text(
          text,
          style: (kIsWeb || MediaQuery.of(context).size.width > 920)
              ? TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              : TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      );
  Future<void> _createPDF() async {
    // Vérifier qu'un poste et un jour sont sélectionnés
    if (selectedPoste == null || groupValue == null) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un poste et un jour'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Récupérer les données à jour
    await fetchData(groupValue);

    // Create a new PDF document.
    PdfDocument document = PdfDocument();
    // Add a new page to the document.
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // En-tête du document
    PdfGraphics graphics = page.graphics;
    PdfStandardFont titleFont =
        PdfStandardFont(PdfFontFamily.timesRoman, 20, style: PdfFontStyle.bold);
    PdfStandardFont subtitleFont =
        PdfStandardFont(PdfFontFamily.timesRoman, 14);
    PdfStandardFont normalFont = PdfStandardFont(PdfFontFamily.timesRoman, 12);

    // Ajouter le logo Terre en Vie
    try {
      final logoData = await rootBundle.load('assets/logoTEV.png');
      final logoImage = PdfBitmap(logoData.buffer.asUint8List());
      graphics.drawImage(logoImage, Rect.fromLTWH(20, 20, 40, 40));
    } catch (e) {
      print('Erreur lors du chargement du logo: $e');
      // Continuer sans logo si erreur
    }

    // Titre principal
    graphics.drawString('Terre en Vie', titleFont,
        bounds: Rect.fromLTWH(0, 20, pageSize.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Sous-titre avec informations du poste et jour
    String subtitle = 'Liste des bénévoles - $selectedPoste - $groupValue';
    graphics.drawString(subtitle, subtitleFont,
        bounds: Rect.fromLTWH(0, 50, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Date de génération
    String dateGeneree =
        'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    graphics.drawString(dateGeneree, normalFont,
        bounds: Rect.fromLTWH(0, 70, pageSize.width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Tableau des bénévoles
    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.timesRoman, 11),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );
    grid.columns.add(count: 4);
    grid.headers.add(1);

    // En-têtes du tableau
    PdfGridRow headers = grid.headers[0];
    headers.cells[0].value = 'Nom';
    headers.cells[1].value = 'Prénom';
    headers.cells[2].value = 'Téléphone';
    headers.cells[3].value = 'Créneau';

    // Données des bénévoles
    for (var i = 0; i < items.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = items[i][0]; // Nom
      row.cells[1].value = items[i][1]; // Prénom
      row.cells[2].value = items[i][2]; // Téléphone
      row.cells[3].value =
          '${items[i][5]} - ${items[i][6]}'; // Créneau (début - fin)
    }

    // Dessiner le tableau
    grid.draw(
        page: page,
        bounds:
            Rect.fromLTWH(0, 100, pageSize.width - 40, pageSize.height - 120));

    // Pied de page avec statistiques
    String totalBenevoles = 'Total des bénévoles: ${items.length}';
    graphics.drawString(totalBenevoles, normalFont,
        bounds: Rect.fromLTWH(0, pageSize.height - 50, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Sauvegarder le document
    List<int> bytes = await document.save();
    document.dispose();

    // Afficher le PDF
    if (kIsWeb) {
      print('📄 PDF Ki ké où généré avec succès (mode Web)');
      print('📄 Nombre de bénévoles: ${items.length}');
      print('📄 Taille du PDF: ${bytes.length} bytes');

      // Créer une URL de données pour afficher le PDF dans le navigateur
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Créer un lien de téléchargement
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            'download', 'kikeou_${selectedPoste}_${groupValue ?? "tous"}.pdf')
        ..setAttribute('target', '_blank')
        ..click();

      // Nettoyer l'URL après un délai
      Future.delayed(Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });
    } else {
      // Pour mobile, on pourrait sauvegarder le fichier
      print('📄 PDF Ki ké où généré avec succès (mode Mobile)');
    }
  }

  Future<List<List>> fetchData(String? groupValue) async {
    items = [];
    Widget? itemWidget = null;
    totalCount = 0;

    // Si selectedPoste est null, ne pas récupérer les données
    if (selectedPoste == null) {
      return [];
    }

    // Requête Firestore pour récupérer les données des bénévoles
    QuerySnapshot<Map<String, dynamic>> posBenSnapshot =
        await FirebaseFirestore.instance.collection('pos_ben').get();

    // Convertir les documents en une liste pour les trier
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        posBenSnapshot.docs;

    // Trier les documents par poste, jour et heure
    documents.sort((a, b) {
      String posteA = a.get('pos_id')[0]['poste'] ?? '';
      String posteB = b.get('pos_id')[0]['poste'] ?? '';
      String jourA = a.get('pos_id')[0]['jour'] ?? '';
      String jourB = b.get('pos_id')[0]['jour'] ?? '';
      String heureA = a.get('pos_id')[0]['debut'] ?? '';
      String heureB = b.get('pos_id')[0]['debut'] ?? '';

      int posteComparison = posteA.compareTo(posteB);
      int jourComparison = jourA.compareTo(jourB);

      if (posteComparison == 0) {
        return jourComparison == 0 ? heureA.compareTo(heureB) : jourComparison;
      } else {
        return posteComparison;
      }
    });

    // Filtrer les documents par le poste sélectionné
    for (var document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<dynamic>? posIdList = data['pos_id'];

      if (posIdList != null && posIdList.isNotEmpty) {
        Map<String, dynamic>? firstPosId = posIdList[0];
        String? poste = firstPosId?['poste'];
        String? jour = firstPosId?['jour'];

        if (poste != null && poste == selectedPoste) {
          if (groupValue == null || jour == groupValue) {
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

                items.add([
                  userData['nom'].toUpperCase(),
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
    return items;
  }
}
