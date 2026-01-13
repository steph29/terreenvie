import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'dart:html' as html;

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
    if (!mounted) return;

    Set<String> uniqueBenevoleIds = {}; // Set pour stocker les ben_id uniques
    List<Map<String, dynamic>> uniqueBenevoles =
        []; // Liste pour les bénévoles uniques

    try {
      // Récupérer tous les documents de la collection 'pos_ben'
      QuerySnapshot posBenSnapshot =
          await FirebaseFirestore.instance.collection('pos_ben').get();

      if (!mounted) return;

      // Parcourir chaque document de 'pos_ben' pour extraire les ben_id
      for (var doc in posBenSnapshot.docs) {
        String? benId = doc['ben_id'] as String?;

        if (benId != null && benId.isNotEmpty) {
          // Ajouter benId au set (Set évite les doublons)
          uniqueBenevoleIds.add(benId);
        }
      }

      // Récupérer les informations de chaque bénévole à partir des ben_id uniques
      for (String benId in uniqueBenevoleIds) {
        if (!mounted) return;

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(benId)
            .get();

        if (!mounted) return;

        if (userSnapshot.exists) {
          // Convertir les données en Map<String, dynamic>
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            uniqueBenevoles.add({
              'nom': userData['nom'] ?? '',
              'prenom': userData['prenom'] ?? '',
              'tel': userData['tel'] ?? '',
              'email': userData['email'] ?? ''
            });
          }
        }
      }

      // Mettre à jour la liste des bénévoles sans doublons
      if (mounted) {
        setState(() {
          benevoles = uniqueBenevoles;
        });
      }
    } catch (e) {
      if (mounted) {
        print('Erreur lors de la récupération des bénévoles: $e');
      }
    }
  }

  // Fonction pour générer le PDF avec Syncfusion
  Future<void> _generatePdf() async {
    // Créer un nouveau document PDF
    PdfDocument document = PdfDocument();

    // Ajouter une page
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;
    Size pageSize = page.getClientSize();

    // Définir les polices
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    PdfFont subtitleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    PdfFont headerFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    // Couleurs du thème
    PdfColor headerColor = PdfColor(200, 200, 200);

    // Position initiale
    double yPosition = 50;

    // Ajouter le logo Terre en Vie
    try {
      final logoData = await rootBundle.load('assets/logoTEV.png');
      final logoImage = PdfBitmap(logoData.buffer.asUint8List());
      graphics.drawImage(logoImage, Rect.fromLTWH(20, 20, 60, 60));
    } catch (e) {
      print('Erreur lors du chargement du logo: $e');
      // Continuer sans logo si erreur
    }

    // Titre principal
    graphics.drawString('TERRE EN VIE', titleFont,
        bounds: Rect.fromLTWH(0, 20, pageSize.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Sous-titre
    graphics.drawString('Liste des bénévoles', subtitleFont,
        bounds: Rect.fromLTWH(0, 50, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    yPosition = 100;

    // Informations de génération
    String dateGeneration =
        'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    graphics.drawString(dateGeneration, font,
        bounds: Rect.fromLTWH(50, yPosition, pageSize.width - 100, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    yPosition += 30;

    // Statistiques
    String stats = 'Total des bénévoles : ${benevoles.length}';
    graphics.drawString(stats, headerFont,
        bounds: Rect.fromLTWH(50, yPosition, pageSize.width - 100, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    yPosition += 40;

    // Créer un tableau avec nom, prénom, email et téléphone
    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4); // 4 colonnes : Nom, Prénom, Email, Téléphone
    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      font: font,
    );

    // Ajuster la largeur des colonnes pour une meilleure lisibilité
    double tableWidth = pageSize.width - 100;
    grid.columns[0].width = tableWidth * 0.22; // Nom : 22%
    grid.columns[1].width = tableWidth * 0.22; // Prénom : 22%
    grid.columns[2].width =
        tableWidth * 0.38; // Email : 38% (plus large pour les adresses email)
    grid.columns[3].width = tableWidth * 0.18; // Téléphone : 18%

    // En-têtes du tableau
    PdfGridRow header = grid.headers.add(1)[0];
    header.cells[0].value = 'Nom';
    header.cells[1].value = 'Prénom';
    header.cells[2].value = 'Email';
    header.cells[3].value = 'Téléphone';

    // Style de l'en-tête
    header.style = PdfGridRowStyle(
      font: headerFont,
      backgroundBrush: PdfSolidBrush(headerColor),
      textBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
    );

    // Trier les bénévoles par ordre alphabétique des noms
    List<Map<String, dynamic>> benevolesTries = List.from(benevoles);
    benevolesTries.sort((a, b) {
      String nomA = (a['nom'] ?? '').toString().toUpperCase();
      String nomB = (b['nom'] ?? '').toString().toUpperCase();
      if (nomA == nomB) {
        // Si les noms sont identiques, trier par prénom
        String prenomA = (a['prenom'] ?? '').toString().toUpperCase();
        String prenomB = (b['prenom'] ?? '').toString().toUpperCase();
        return prenomA.compareTo(prenomB);
      }
      return nomA.compareTo(nomB);
    });

    // Vérifier qu'on a des données
    if (benevolesTries.isEmpty) {
      throw Exception('Aucun bénévole trouvé pour générer le PDF');
    }

    // Ajouter les données des bénévoles triés (nom, prénom, email, téléphone)
    for (int i = 0; i < benevolesTries.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = (benevolesTries[i]['nom'] ?? '').toString();
      row.cells[1].value = (benevolesTries[i]['prenom'] ?? '').toString();
      row.cells[2].value =
          (benevolesTries[i]['email'] ?? 'Non renseigné').toString();
      row.cells[3].value =
          (benevolesTries[i]['tel'] ?? 'Non renseigné').toString();

      // Alterner les couleurs des lignes
      if (i % 2 == 0) {
        row.style = PdfGridRowStyle(
          backgroundBrush: PdfSolidBrush(PdfColor(248, 248, 248)),
        );
      }
    }

    // Dessiner le tableau
    grid.draw(
        page: page,
        bounds: Rect.fromLTWH(50, yPosition, pageSize.width - 100, 0));

    // Pied de page
    yPosition = pageSize.height - 80;
    graphics.drawString(
        '© ${DateTime.now().year} Terre en Vie - Tous droits réservés', font,
        bounds: Rect.fromLTWH(50, yPosition, pageSize.width - 100, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    yPosition += 20;
    graphics.drawString(
        'Document généré automatiquement par l\'application Terre en Vie', font,
        bounds: Rect.fromLTWH(50, yPosition, pageSize.width - 100, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Sauvegarder le document
    List<int> bytes = await document.save();
    document.dispose();

    // Afficher le PDF
    if (kIsWeb) {
      print('📄 PDF généré avec succès (mode Web)');
      print('📄 Nombre de bénévoles: ${benevoles.length}');
      print('📄 Taille du PDF: ${bytes.length} bytes');

      // Créer une URL de données pour afficher le PDF dans le navigateur
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Créer un lien de téléchargement
      html.AnchorElement(href: url)
        ..setAttribute('download', 'liste_benevoles.pdf')
        ..setAttribute('target', '_blank')
        ..click();

      // Nettoyer l'URL après un délai
      Future.delayed(Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });
    } else {
      // Pour mobile, on pourrait sauvegarder le fichier
      print('📄 PDF généré avec succès (mode Mobile)');
    }
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
                              'Email: ${benevole['email']}, Téléphone: ${benevole['tel']}',
                            ),
                          );
                        },
                      ),
                    )),
                    // Ajout du bouton dans un container aligné en bas
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // S'assurer que les données sont à jour avant de générer le PDF
                          if (benevoles.isEmpty) {
                            await fetchUniqueBenevoles();
                          }

                          // Générer le PDF avec les données actuelles
                          await _generatePdf();
                        } catch (e) {
                          print('❌ Erreur lors de la génération du PDF: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Erreur lors de la génération du PDF: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text("Télécharger la liste des entrées"),
                    ),
                  ],
                ),
              ),
            ),
    );
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
      Map<String, dynamic> data = document.data();
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
                '${userData['nom'].toUpperCase()} ${userData['prenom']} ${userData['email']}';

            // Vérifier si la clé existe déjà dans le Set
            if (!uniqueBenevoles.contains(fullName)) {
              // Ajouter la clé au Set et les détails dans items
              uniqueBenevoles.add(fullName);
              items.add([
                userData['nom'].toUpperCase(),
                userData['prenom'],
                userData['tel'],
                userData['email']
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
