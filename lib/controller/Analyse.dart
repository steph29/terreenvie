import 'dart:async';
import 'package:terreenvie/controller/PDF/web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class Users {
  final String id;
  final String nom;
  final String prenom;

  Users({required this.id, required this.nom, required this.prenom});
}

class Poste {
  final String nomPoste;
  final String jour;
  final String heureDebut;
  final String heureFin;

  Poste({
    required this.nomPoste,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
  });
}

class Analyse extends StatefulWidget {
  const Analyse({Key? key}) : super(key: key);

  @override
  State<Analyse> createState() => _AnalyseState();
}

class _AnalyseState extends State<Analyse> {
  String groupValue = "Samedi";
  List<List<dynamic>> test = [];
  List<List<dynamic>> items = [];
  List<List<dynamic>> itemsUser = [];
  List<String> poste = ['Animation Sonore'];
  String? selectedPoste;
  int totalCount = 0;
  int totalCountUser = 0;
  List<String> userNames = [];
  List<String> usersID = [];
  String? selectedUser;
  String? userId;
  List<Users> users = [];
  List<Poste> userPosts = [];
  List<List<dynamic>> userse = [];
  List<Poste> postesUsers = [];

  @override
  void initState() {
    super.initState();
    // Charger la liste des noms d'utilisateurs depuis Firebase
    loadUserNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ki ké où?"),
          backgroundColor: Color(0xFFf2f0e7),
        ),
        // TODO : Réarranger en fonction de la taille des écrans
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: (kIsWeb || MediaQuery.of(context).size.width > 920)
                ? isWeb()
                : isMobile()));
  }

  Widget isMobile() => Column(
        children: [
          Kikeou(),
          space(),
          kifekoi(),
          space(),
          Listedeski(),
          space(),
          kiela()
        ],
      );

  Widget space() => SizedBox(
        height: 30,
      );

  Widget isWeb() => Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Kikeou(),
              Listedeski(),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [kifekoi(), kiela()],
          )
        ],
      );

  Widget Kikeou() => Container(
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
            buildSegmentControl(),
            new DropdownButton<String>(
                items: <String>[
                  'Animation Sonores',
                  'Ateliers animation enfants',
                  'Barriere',
                  'benevoles volants',
                  'Bénévole Volant',
                  'Benevoles volants',
                  'Buvette principale',
                  'Chapiteau',
                  'Conferences',
                  'Decoration',
                  'Demontage / Nettoyage',
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
            FutureBuilder<List<List<dynamic>>>(
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
                return Expanded(
                    child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 6,
                  child: ListView(
                    children: items.map((item) {
                      // Créez des Widgets à partir des données de chaque élément
                      return ListTile(
                        title: Text(
                            'Nom, prénom, tél : ${item[0]} ${item[1]} ${item[2]}'),
                        subtitle: Text(
                            'Poste: le ${item[3]} à ${item[4]} de ${item[5]} à ${item[6]}'),
                        // Ajoutez d'autres éléments ici en fonction de votre structure de données
                      );
                    }).toList(),
                  ),
                ));
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _createPDF();
              },
              child: Text("Télécharger la liste"),
            ),
          ],
        ),
      );

  Widget Listedeski() => Container(
        decoration: BoxDecoration(
          color: Colors.yellowAccent.withOpacity(0.1),
        ),
        width: (kIsWeb || MediaQuery.of(context).size.width > 920)
            ? MediaQuery.of(context).size.width / 2.5
            : MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 2.5,
        child: Column(
          children: [
            Text('La liste des ki ! '),
            FutureBuilder<List<List<dynamic>>>(
              future: getAllUsers(),
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
                      // Créez des Widgets à partir des données de chaque élément
                      return ListTile(
                        title: Text(
                            'Nom, prénom, Email, téléphone : ${item[0]} ${item[1]} ${item[2]} , ${item[3]}'),
                      );
                    }).toList(),
                  ),
                ));
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _createPDFuser();
              },
              child: Text("Télécharger la liste des bénévoles inscrits"),
            ),
          ],
        ),
      );

  Widget kifekoi() => Container(
        width: (kIsWeb || MediaQuery.of(context).size.width > 920)
            ? MediaQuery.of(context).size.width / 2.5
            : MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
        child: Column(
          children: [
            Text('Ki fè koi'),
            Row(children: [
              DropdownButton<String>(
                value: selectedUser,
                onChanged: (String? newValue) async {
                  setState(() {
                    selectedUser = newValue;
                  });

                  if (selectedUser != null) {
                    final selectedUserId = users
                        .firstWhere((user) =>
                            '${user.nom} ${user.prenom}' == selectedUser)
                        .id;

                    // Récupérer les postes de l'utilisateur sélectionné
                    final postes = await getUserPosts(selectedUserId);
                    setState(() {
                      for (var i = 0; i < postes.length; i++)
                        userPosts =
                            postesUsers; // Mettre à jour la liste des postes de l'utilisateur
                    });
                  }
                },
                items:
                    userNames.map<DropdownMenuItem<String>>((String userName) {
                  return DropdownMenuItem<String>(
                    value: userName,
                    child: Text(userName),
                  );
                }).toList(),
                hint: Text('Sélectionnez un nom'),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      final poste = userPosts[index];
                      return ListTile(
                        title: Text('Nom du poste: ${poste.nomPoste}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jour: ${poste.jour}'),
                            Text('Heure de début: ${poste.heureDebut}'),
                            Text('Heure de fin: ${poste.heureFin}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ],
        ),
      );

  Widget kiela() => Container(
        width: (kIsWeb || MediaQuery.of(context).size.width > 920)
            ? MediaQuery.of(context).size.width / 2.5
            : MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1)),
        child: Column(children: [Text("Ki é la?"), EtatDesLieux()]),
      );

  Widget EtatDesLieux() => FutureBuilder<
          Map<String, Map<String, Map<String, List<Map<String, String>>>>>>(
        future: getVolunteersPerPosteWithUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune donnée disponible.'),
            );
          }

          Map<String, Map<String, Map<String, List<Map<String, String>>>>>
              items = snapshot.data!;

          return Expanded(
            // Ajout du SingleChildScrollView pour éviter le débordement
            child: ListView.builder(
              shrinkWrap:
                  true, // Permet au ListView de s'adapter à la hauteur de son contenu
              itemCount: items.length,
              itemBuilder: (context, index) {
                String jour = items.keys.elementAt(index);
                Map<String, Map<String, List<Map<String, String>>>> postesMap =
                    items[jour]!;

                return ExpansionTile(
                  title: Text('Jour: $jour'),
                  children: postesMap.entries.map((posteEntry) {
                    String nomPoste = posteEntry.key;
                    Map<String, List<Map<String, String>>> horairesMap =
                        posteEntry.value;

                    return ExpansionTile(
                      title: Text('Poste: $nomPoste'),
                      children: horairesMap.entries.map((horaireEntry) {
                        String horaires = horaireEntry.key;
                        List<Map<String, String>> benevoles =
                            horaireEntry.value;

                        return ExpansionTile(
                          title: Text(
                              'Horaires: $horaires (${benevoles.length} bénévoles)'),
                          children: benevoles.map((benevole) {
                            String nom = benevole['nom']!;
                            String prenom = benevole['prenom']!;

                            return ListTile(
                              title: Text('$prenom $nom'),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          );
        },
      );

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
    }
    return items;
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
    CustomWebPdf().pdf(document);
  }

  Future<void> pdfMobile(PdfDocument document) async {
    // final appDocDir = await getApplicationDocumentsDirectory();
    // final filePath = 'Bénévoles_kikeou.pdf';
    // List<int> bytes = await document.save();
    // File file = File('Bénévoles_kikeou_mobile.pdf');
    // file.writeAsBytes(bytes);

    // final File file =
    //     File(path.join(appDocDir.path, 'Bénévoles_kikeou_mobile.pdf'));
    // // final File file = File(appDocDir.path + 'Bénévoles_kikeou_mobile.pdf');
    // await file.writeAsBytes(bytes, flush: true).whenComplete(() {
    //   OpenFile.open(appDocDir.path + 'downloaded.pdf');
    // });
    // file.writeAsBytesSync(await document.save());
    // File(filePath).writeAsBytesSync(await document.save());
  }

  Future<void> downloadFile(PdfDocument fileUrl) async {
    // final response = await http.get(fileUrl as Uri);

    // if (response.statusCode == 200) {
    //   // Obtenez le répertoire de stockage local de l'appareil
    //   final appDocDir = await getApplicationDocumentsDirectory();

    //   // Obtenez le chemin d'accès complet où vous souhaitez enregistrer le fichier
    //   final filePath = '${appDocDir.path}/test.pdf';

    //   // Écrivez le contenu téléchargé dans un fichier local
    //   // File file = File(filePath);
    //   // await file.writeAsBytes(response.bodyBytes);

    //   print('Fichier téléchargé avec succès à $filePath');
    // } else {
    //   throw Exception('Échec du téléchargement du fichier');
    // }
  }

  Future<Uint8List> _readImageData(String name) async {
    final data = await rootBundle.load('$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Map<String, Map<String, Map<String, List<Map<String, String>>>>>>
      getVolunteersPerPosteWithUserDetails() async {
    // Récupère les documents depuis Firestore
    final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
        await FirebaseFirestore.instance.collection('pos_ben').get();

    // Map pour compter les occurrences et stocker les détails des bénévoles par jour, poste et horaires
    Map<String, Map<String, Map<String, List<Map<String, String>>>>>
        dayPosteTimeVolunteers = {};

    // Parcours des documents Firestore dans la collection 'pos_ben'
    for (var doc in postsSnapshot.docs) {
      final data = doc.data();

      if (data['pos_id'] == null) {
        print("Attention : champ 'pos_id' manquant pour le document ${doc.id}");
        continue;
      }

      // Parcours de chaque poste dans le document
      for (var i = 0; i < data['pos_id'].length; i++) {
        final posteData = data['pos_id'][i];

        // Vérifie la présence des champs requis (jour, horaires, poste, ben_id)
        if (posteData['jour'] == null ||
            posteData['debut'] == null ||
            posteData['poste'] == null ||
            data['ben_id'] == null) {
          print(
              "Attention : champ manquant pour le document ${doc.id}, index $i");
          continue;
        }

        String jour = posteData['jour'] as String;
        String horaires = posteData['debut'] as String;
        String nomPoste = posteData['poste'] as String;
        String benId = data['ben_id'] as String;

        // Récupère les informations du bénévole depuis la collection 'users'
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(benId)
            .get();
        if (!userDoc.exists) {
          print("Bénévole non trouvé pour ben_id: $benId");
          continue;
        }
        final userData = userDoc.data();
        String nom = userData?['nom'] ?? 'Nom inconnu';
        String prenom = userData?['prenom'] ?? 'Prénom inconnu';

        // Initialiser les sous-Map pour le jour, poste et horaires s'ils n'existent pas encore
        dayPosteTimeVolunteers[jour] ??= {};
        dayPosteTimeVolunteers[jour]![nomPoste] ??= {};
        dayPosteTimeVolunteers[jour]![nomPoste]![horaires] ??= [];

        // Ajoute le bénévole (nom et prénom) à la liste pour ce poste et horaires
        dayPosteTimeVolunteers[jour]![nomPoste]![horaires]!
            .add({'nom': nom, 'prenom': prenom});
      }
    }

    return dayPosteTimeVolunteers;
  }

  Future<List<List<dynamic>>> getAllUsers() async {
    itemsUser = [];
    QuerySnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        userSnapshot.docs;
    documents.sort((a, b) {
      String nomA = (a.get('nom') ?? '').toUpperCase();
      String nomB = (b.get('nom') ?? '').toUpperCase();

      return nomA.compareTo(nomB);
    });

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in documents) {
      Map<String, dynamic> userData = document.data();

      itemsUser.add([
        userData['nom'].toUpperCase(),
        userData['prenom'],
        userData['email'],
        userData['tel'],
      ]);
    }
    return itemsUser;
  }

  Future<void> _createPDFuser() async {
    // Create a new PDF document.
    PdfDocument document = PdfDocument();
    // Add a new page to the document.
    final page = document.pages.add();

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));
    grid.columns.add(count: 4);
    grid.headers.add(1);

    PdfGridRow headers = grid.headers[0];
    headers.cells[0].value = 'Nom';
    headers.cells[1].value = 'Prenom';
    headers.cells[2].value = 'Email';
    headers.cells[3].value = 'Téléphone';

    for (var i = 0; i < itemsUser.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = itemsUser[i][0];
      row.cells[1].value = itemsUser[i][1];
      row.cells[2].value = itemsUser[i][2];
      row.cells[3].value = itemsUser[i][3];
    }

    grid.draw(
        page: document.pages.add(),
        bounds: Rect.fromLTWH(
            0, 55, page.getClientSize().width, page.getClientSize().height));

    //Save the document
    //CustomPdf().pdf(document);
    CustomWebPdf().pdf(document);
  }

  Future<void> loadUserNames() async {
    final QuerySnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        userSnapshot.docs;

    documents.sort((a, b) {
      String nomA = (a.get('nom') ?? '').toUpperCase();
      String nomB = (b.get('nom') ?? '').toUpperCase();

      return nomA.compareTo(nomB);
    });

    setState(() {
      users = documents
          .map(
            (doc) => Users(
              id: doc.id,
              nom: doc['nom'] as String,
              prenom: doc['prenom'] as String,
            ),
          )
          .toList();
      userNames = users.map((user) => '${user.nom} ${user.prenom}').toList();
    });
  }

  Future<List<Poste>> getUserPosts(String userName) async {
    postesUsers = [];
    final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
        await FirebaseFirestore.instance
            .collection('pos_ben')
            .where('ben_id', isEqualTo: userName)
            .get();

    postsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      for (var i = 0; i < data['pos_id'].length; i++) {
        String nomPoste = data['pos_id'][i]['poste'] as String;
        String jour = data['pos_id'][i]['jour'] as String;
        String heureDebut = data['pos_id'][i]['debut'] as String;
        String heureFin = data['pos_id'][i]['fin'] as String;

        postesUsers.add(Poste(
          nomPoste: nomPoste,
          jour: jour,
          heureDebut: heureDebut,
          heureFin: heureFin,
        ));
      }
    }).toList();
    return postesUsers;
  }

  Future<Uint8List> _readImageData1(String name) async {
    final data = await rootBundle.load('$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
