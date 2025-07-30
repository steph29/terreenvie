import 'dart:async';
// import 'package:terreenvie/controller/PDF/web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'kikeou.dart';
import 'package:terreenvie/model/BenevoleListWidgetState.dart';
import 'RadarChartScreen.dart';

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

class BenevoleAvecPoste {
  final String nom;
  final String prenom;
  final String poste;
  final String jour;

  BenevoleAvecPoste({
    required this.nom,
    required this.prenom,
    required this.poste,
    required this.jour,
  });
  @override
  String toString() {
    return '$prenom $nom, Poste: $poste, Jour: $jour';
  }
}

class Analyse extends StatefulWidget {
  const Analyse({Key? key}) : super(key: key);

  @override
  State<Analyse> createState() => _AnalyseState();
}

class _AnalyseState extends State<Analyse> {
  String groupValue = "Samedi";

  // Données centralisées pour les améliorations de performance
  List<Map<String, dynamic>> posHorData = [];
  List<Map<String, dynamic>> posBenData = [];
  List<Map<String, dynamic>> usersData = [];
  bool isLoading = true;

  // Variables pour la compatibilité avec le code existant
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
  List<BenevoleAvecPoste> benevolesAvecPostes = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Charger toutes les données nécessaires en une seule fois
      final posHorSnapshot = await FirebaseFirestore.instance
          .collection('pos_hor')
          .where('jour', isEqualTo: groupValue)
          .get();
      posHorData = posHorSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      final posBenSnapshot =
          await FirebaseFirestore.instance.collection('pos_ben').get();
      posBenData = posBenSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      usersData = usersSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      // Initialiser les variables de compatibilité
      await loadUserNames();
      await Listedeski();
      await kifekoi();
      await kiela();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ki ké où?"),
          backgroundColor: Color(0xFFf2f0e7),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: (kIsWeb || MediaQuery.of(context).size.width > 920)
                    ? isWeb()
                    : isMobile()));
  }

  Widget isMobile() => Column(
        children: [
          // Graphique radar
          Container(
            height: 400,
            child: RadarChartScreen(),
          ),
          space(),
          Kikeou(),
          space(),
          kifekoi(),
          space(),
          Listedeski(),
          space(),
          kiela(),
          ListTotal(),
          BenevoleListWidget()
        ],
      );

  Widget space() => SizedBox(
        height: 30,
      );

  Widget isWeb() => SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          // Graphique radar en haut
          Container(
            height: 400,
            child: RadarChartScreen(),
          ),
          SizedBox(
            height: 20,
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
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [ListTotal(), BenevoleListWidget()],
          )
        ],
      ));

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

  Future<List<List<dynamic>>> fetchVolunteersForPoste(String poste) async {
    // Récupère les bénévoles à partir du document pos_ben
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('pos_ben')
        .where('pos_id.poste', isEqualTo: poste)
        .get();

    // Retourne une liste des informations des bénévoles sous forme de tableau dynamique
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return [
        data['nom'], // Nom
        data['prenom'], // Prénom
        data['telephone'], // Téléphone
        data['jour'], // Jour
        data['poste'], // Poste
        data['horaire_debut'], // Heure début
        data['horaire_fin'], // Heure fin
      ];
    }).toList();
  }

  Future<List<String>> fetchPostes() async {
    // Récupère les postes à partir du document pos_hor
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('pos_hor').get();

    // Retourne la liste des postes
    return snapshot.docs.map((doc) => doc['poste'] as String).toList();
  }

  Future<void> _createPDF() async {
    // Create a new PDF document.
    // PdfDocument document = PdfDocument();
    // Add a new page to the document.
    // final page = document.pages.add();
    // final Size pageSize = page.getClientSize();

    // page.graphics.drawImage(
    //     PdfBitmap(await _readImageData('assets/logoTEV.png')),
    //     Rect.fromLTWH(0, 0, 40, 40));

    // PdfGrid grid = PdfGrid();
    // grid.style = PdfGridStyle(
    //     font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    //     cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));
    // grid.columns.add(count: 7);
    // grid.headers.add(1);

    // PdfGridRow headers = grid.headers[0];
    // headers.cells[0].value = 'Nom';
    // headers.cells[1].value = 'Prenom';
    // headers.cells[2].value = 'Téléphone';
    // headers.cells[3].value = 'Jour';
    // headers.cells[4].value = 'poste';
    // headers.cells[5].value = 'debut';
    // headers.cells[6].value = 'fin';

    // for (var i = 0; i < items.length; i++) {
    //   PdfGridRow row = grid.rows.add();
    //   row.cells[0].value = items[i][0];
    //   row.cells[1].value = items[i][1];
    //   row.cells[2].value = items[i][2];
    //   row.cells[3].value = items[i][3];
    //   row.cells[4].value = items[i][4];
    //   row.cells[5].value = items[i][5];
    //   row.cells[6].value = items[i][6];
    // }

    // grid.draw(
    //     page: document.pages.add(),
    //     bounds: Rect.fromLTWH(0, 55, pageSize.width, pageSize.height));

    //Save the document
    // CustomWebPdf().pdf(document);
  }

  // Future<void> pdfMobile(PdfDocument document) async {
  //   // final appDocDir = await getApplicationDocumentsDirectory();
  //   // final filePath = 'Bénévoles_kikeou.pdf';
  //   // List<int> bytes = await document.save();
  //   // File file = File('Bénévoles_kikeou_mobile.pdf');
  //   // file.writeAsBytes(bytes);

  //   // final File file =
  //   //     File(path.join(appDocDir.path, 'Bénévoles_kikeou_mobile.pdf'));
  //   // // final File file = File(appDocDir.path + 'Bénévoles_kikeou_mobile.pdf');
  //   // await file.writeAsBytes(bytes, flush: true).whenComplete(() {
  //   //   OpenFile.open(appDocDir.path + 'downloaded.pdf');
  //   // });
  //   // file.writeAsBytesSync(await document.save());
  //   // File(filePath).writeAsBytesSync(await document.save());
  // }

  // Future<void> downloadFile(PdfDocument fileUrl) async {
  //   // final response = await http.get(fileUrl as Uri);

  //   // if (response.statusCode == 200) {
  //   //   // Obtenez le répertoire de stockage local de l'appareil
  //   //   final appDocDir = await getApplicationDocumentsDirectory();

  //   //   // Obtenez le chemin d'accès complet où vous souhaitez enregistrer le fichier
  //   //   final filePath = '${appDocDir.path}/test.pdf';

  //   //   // Écrivez le contenu téléchargé dans un fichier local
  //   //   // File file = File(filePath);
  //   //   // await file.writeAsBytes(response.bodyBytes);

  //   //   print('Fichier téléchargé avec succès à $filePath');
  //   // } else {
  //   //   throw Exception('Échec du téléchargement du fichier');
  //   // }
  // }

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

    // Utiliser les données centralisées au lieu de faire un appel Firestore
    List<Map<String, dynamic>> documents = usersData;

    documents.sort((a, b) {
      String nomA = (a['nom'] ?? '').toString().toUpperCase();
      String nomB = (b['nom'] ?? '').toString().toUpperCase();

      return nomA.compareTo(nomB);
    });

    for (Map<String, dynamic> userData in documents) {
      itemsUser.add([
        (userData['nom'] ?? '').toString().toUpperCase(),
        userData['prenom'] ?? '',
        userData['email'] ?? '',
        userData['tel'] ?? '',
      ]);
    }
    return itemsUser;
  }

  Future<void> _createPDFuser() async {
    // Create a new PDF document.
    // PdfDocument document = PdfDocument();
    // Add a new page to the document.
    // final page = document.pages.add();

    // PdfGrid grid = PdfGrid();
    // grid.style = PdfGridStyle(
    //     font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    //     cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));
    // grid.columns.add(count: 4);
    // grid.headers.add(1);

    // PdfGridRow headers = grid.headers[0];
    // headers.cells[0].value = 'Nom';
    // headers.cells[1].value = 'Prenom';
    // headers.cells[2].value = 'Email';
    // headers.cells[3].value = 'Téléphone';

    // for (var i = 0; i < itemsUser.length; i++) {
    //   PdfGridRow row = grid.rows.add();
    //   row.cells[0].value = itemsUser[i][0];
    //   row.cells[1].value = itemsUser[i][1];
    //   row.cells[2].value = itemsUser[i][2];
    //   row.cells[3].value = itemsUser[i][3];
    // }

    // grid.draw(
    //     page: document.pages.add(),
    //     bounds: Rect.fromLTWH(
    //         0, 55, page.getClientSize().width, page.getClientSize().height));

    //Save the document
    // CustomPdf().pdf(document);
    // CustomWebPdf().pdf(document);
  }

  Future<void> loadUserNames() async {
    // Utiliser les données centralisées au lieu de faire un appel Firestore
    final List<Map<String, dynamic>> documents = usersData;

    documents.sort((a, b) {
      String nomA = (a['nom'] ?? '').toString().toUpperCase();
      String nomB = (b['nom'] ?? '').toString().toUpperCase();

      return nomA.compareTo(nomB);
    });

    setState(() {
      users = documents
          .map(
            (doc) => Users(
              id: doc['id'] ?? doc['uid'] ?? '',
              nom: doc['nom'] as String? ?? '',
              prenom: doc['prenom'] as String? ?? '',
            ),
          )
          .toList();
      userNames = users.map((user) => '${user.nom} ${user.prenom}').toList();
    });
  }

  Future<List<Poste>> getUserPosts(String userName) async {
    postesUsers = [];

    // Utiliser les données centralisées au lieu de faire un appel Firestore
    for (Map<String, dynamic> doc in posBenData) {
      if (doc['ben_id'] == userName) {
        List<dynamic> posIds = doc['pos_id'] ?? [];

        for (var i = 0; i < posIds.length; i++) {
          String nomPoste = posIds[i]['poste'] ?? '';
          String jour = posIds[i]['jour'] ?? '';
          String heureDebut = posIds[i]['debut'] ?? '';
          String heureFin = posIds[i]['fin'] ?? '';

          postesUsers.add(Poste(
            nomPoste: nomPoste,
            jour: jour,
            heureDebut: heureDebut,
            heureFin: heureFin,
          ));
        }
      }
    }
    return postesUsers;
  }

  Future<Uint8List> _readImageData1(String name) async {
    final data = await rootBundle.load('$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

// Fonction pour récupérer les bénévoles avec leurs postes
  Future<List<BenevoleAvecPoste>> getVolunteersWithPosts() async {
    List<BenevoleAvecPoste> benevolesAvecPostes = [];

    // Récupère les documents de la collection 'pos_ben'
    final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
        await FirebaseFirestore.instance.collection('pos_ben').get();

    // Parcours des documents 'pos_ben'
    for (var postDoc in postsSnapshot.docs) {
      final postData = postDoc.data();

      // Assurez-vous que ben_id existe
      if (postData.containsKey('ben_id')) {
        String benId = postData['ben_id'] as String;

        // Récupère les informations du bénévole correspondant depuis la collection 'user'
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(benId)
            .get();

        final userData = userDoc.data();
        if (userData != null) {
          String nom = userData['nom'] as String;
          String prenom = userData['prenom'] as String;

          // Vérifiez si 'pos_id' est une liste
          if (postData['pos_id'] is List) {
            List<dynamic> postes = postData['pos_id'];

            // Parcours de chaque poste dans la liste
            for (var posteItem in postes) {
              String poste = "";
              String jour = "";

              // Vérifiez que posteItem est un Map
              if (posteItem is Map<String, dynamic>) {
                // Récupération des données du poste
                if (posteItem.containsKey('poste')) {
                  poste = posteItem['poste'] as String;
                  // jour = posteItem['jour'] as String;
                }
                if (posteItem.containsKey('jour')) {
                  jour = posteItem['jour'] as String;
                }
              }

              // Ajoute le bénévole avec son poste dans la liste
              benevolesAvecPostes.add(BenevoleAvecPoste(
                  nom: nom, prenom: prenom, poste: poste, jour: jour));
            }
          } else {
            print(
                'Erreur : pos_id n\'est pas une liste pour le bénévole $benId');
          }
        }
      } else {
        print('Erreur : ben_id manquant dans le document ${postDoc.id}');
      }
    }

    // Trie les bénévoles par poste
    benevolesAvecPostes.sort((a, b) => a.poste.compareTo(b.poste));

    return benevolesAvecPostes;
  }

  Widget ListTotal() => Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 119, 0, 255).withOpacity(0.1),
      ),
      width: (kIsWeb || MediaQuery.of(context).size.width > 920)
          ? MediaQuery.of(context).size.width / 2.5
          : MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Column(children: [
        Text('La liste de tout le monde ! '),
        FutureBuilder<List<BenevoleAvecPoste>>(
          future: getVolunteersWithPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
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

            // Récupère la liste des bénévoles
            List<BenevoleAvecPoste> volunteers = snapshot.data!;

            // Nombre total de bénévoles
            int totalVolunteers = volunteers.length;

            return Expanded(
                child: Column(
              children: [
                // Affiche le nombre total de bénévoles
                Text(
                  'Nombre total de postes occupés : $totalVolunteers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Affiche la liste des bénévoles, classés par poste
                Expanded(
                  child: ListView.builder(
                    itemCount: volunteers.length,
                    itemBuilder: (context, index) {
                      final volunteer = volunteers[index];
                      return ListTile(
                        title: Text('${volunteer.prenom} ${volunteer.nom}'),
                        subtitle: Text(
                            'Poste : ${volunteer.poste}, le ${volunteer.jour}'),
                      );
                    },
                  ),
                ),
              ],
            ));
          },
        )
      ]));
}
