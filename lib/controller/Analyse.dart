import 'dart:async';
import 'package:terreenvie/controller/PDF/web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
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

class _AnalyseState extends State<Analyse> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String groupValue = "Samedi";

  // Centralisation des données Firestore
  List<Map<String, dynamic>> posHorData = [];
  List<Map<String, dynamic>> posBenData = [];
  List<Map<String, dynamic>> usersData = [];
  bool isLoading = true;

  // Couleurs du thème
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFf2f0e7);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color accentColor = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final posHorSnapshot = await FirebaseFirestore.instance
          .collection('pos_hor')
          .where('jour', isEqualTo: groupValue)
          .get();

      if (!mounted) return;

      posHorData = posHorSnapshot.docs.map((d) => d.data()).toList();

      final posBenSnapshot =
          await FirebaseFirestore.instance.collection('pos_ben').get();

      if (!mounted) return;

      posBenData = posBenSnapshot.docs.map((d) => d.data()).toList();

      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (!mounted) return;

      usersData = usersSnapshot.docs.map((d) => d.data()).toList();

      // Debug: Afficher la structure des données
      if (mounted) {
        print('📊 Données chargées:');
        print('  - posBenData: ${posBenData.length} éléments');
        print('  - usersData: ${usersData.length} éléments');
        if (usersData.isNotEmpty) {
          print('  - Clés dans usersData[0]: ${usersData.first.keys.toList()}');
          print('  - Exemple user: ${usersData.first}');
        }
        if (posBenData.isNotEmpty) {
          print(
              '  - Clés dans posBenData[0]: ${posBenData.first.keys.toList()}');
          print('  - Exemple posBen: ${posBenData.first}');
        }
      }
    } catch (e) {
      if (mounted) {
        print('❌ Erreur lors du chargement des données: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Tableau de bord",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFf2f0e7),
        foregroundColor: Colors.black87,
        elevation: 2,
        shadowColor: Colors.black12,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.black54,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard, size: 20),
              text: 'KPI',
            ),
            Tab(
              icon: Icon(Icons.radar, size: 20),
              text: 'Graphique',
            ),
            Tab(
              icon: Icon(Icons.people, size: 20),
              text: 'Bénévoles',
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des données...',
                    style: TextStyle(color: accentColor),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildKPITab(),
                _buildChartTab(),
                _buildVolunteersTab(),
              ],
            ),
    );
  }

  Widget _buildKPITab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicateurs clés',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),

          // KPI Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildKPICard(
                'Total Bénévoles',
                _getTotalVolunteers().toString(),
                Icons.people,
                primaryColor,
              ),
              _buildKPICard(
                'Créneaux Occupés',
                _getOccupiedSlots().toString(),
                Icons.schedule,
                Colors.blue,
              ),
              _buildKPICard(
                'Taux de Remplissage',
                '${_getFillRate().toStringAsFixed(1)}%',
                Icons.pie_chart,
                Colors.orange,
              ),
              _buildKPICard(
                'Postes Actifs',
                _getActivePosts().toString(),
                Icons.work,
                Colors.purple,
              ),
              _buildKPICard(
                'Jours Actifs',
                _getActiveDays().toString(),
                Icons.calendar_today,
                Colors.teal,
              ),
              _buildKPICard(
                'Nouveaux Cette Semaine',
                _getNewVolunteersThisWeek().toString(),
                Icons.person_add,
                Colors.green,
              ),
            ],
          ),

          SizedBox(height: 30),

          // Sélecteur de jour
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par jour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  CupertinoSegmentedControl<String>(
                    children: {
                      'Lundi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Lun'),
                      ),
                      'Mardi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Mar'),
                      ),
                      'Mercredi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Mer'),
                      ),
                      'Jeudi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Jeu'),
                      ),
                      'Vendredi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Ven'),
                      ),
                      'Samedi': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Sam'),
                      ),
                      'Dimanche': Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Dim'),
                      ),
                    },
                    groupValue: groupValue,
                    onValueChanged: (String value) {
                      setState(() {
                        groupValue = value;
                      });
                      _loadAllData();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Graphique de remplissage',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: RadarChartScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des bénévoles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Kikeou(),
              SizedBox(height: 20),
              kifekoi(),
              SizedBox(height: 20),
              Listedeski(),
              SizedBox(height: 20),
              kiela(),
              SizedBox(height: 20),
              ListTotal(),
              SizedBox(height: 20),
              BenevoleListWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget isMobile() => Column(
        children: [
          Kikeou(),
          space(),
          kifekoi(),
          space(),
          Listedeski(),
          space(),
          kiela(),
          ListTotal(),
          BenevoleListWidget(),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: (kIsWeb || MediaQuery.of(context).size.width > 920)
                ? MediaQuery.of(context).size.width / 2.5
                : MediaQuery.of(context).size.width / 1.1,
            height: MediaQuery.of(context).size.height / 2.5,
            child: RadarChartScreen(),
          ),
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
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                width: (kIsWeb || MediaQuery.of(context).size.width > 920)
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.height / 2.5,
                child: RadarChartScreen(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellowAccent.withOpacity(0.1),
                ),
                width: (kIsWeb || MediaQuery.of(context).size.width > 920)
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.height / 2.5,
              )
            ],
          ),
        ],
      ));

  // --- Nouvelle version de Listedeski ---
  Widget Listedeski() {
    // 1. Construire un map UserId -> user pour accès rapide
    final userMap = {for (var u in usersData) u['UserId']: u};

    // 2. Set pour éviter les doublons
    final benevoleIds = <String>{};
    final benevoles = <Map<String, dynamic>>[];

    for (var ben in posBenData) {
      final benId = ben['ben_id'];
      if (benId != null &&
          !benevoleIds.contains(benId) &&
          userMap.containsKey(benId)) {
        benevoleIds.add(benId);
        final user = userMap[benId];
        benevoles.add({
          'nom': user?['nom'] ?? '',
          'prenom': user?['prenom'] ?? '',
          'tel': user?['tel'] ?? '',
          'email': user?['email'] ?? ''
        });
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.yellowAccent.withOpacity(0.1),
      ),
      width: (kIsWeb || MediaQuery.of(context).size.width > 920)
          ? MediaQuery.of(context).size.width / 2.5
          : MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Column(
        children: [
          Text('La liste des bénévoles de cette année'),
          Expanded(
            child: benevoles.isEmpty
                ? Center(child: Text("Aucun bénévole trouvé"))
                : ListView.builder(
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
          ),
        ],
      ),
    );
  }

  // --- Nouvelle version de kifekoi ---
  Widget kifekoi() {
    return _KifekoiWidget(
      usersData: usersData,
      posBenData: posBenData,
    );
  }

  // --- Nouvelle version de kiela ---
  Widget kiela() {
    // Map : jour > poste > créneau > liste des bénévoles
    Map<String, Map<String, Map<String, List<Map<String, String>>>>>
        dayPosteTimeVolunteers = {};

    // Créer un map pour un accès rapide aux utilisateurs
    final userMap = <String, Map<String, dynamic>>{};
    for (var user in usersData) {
      // Essayer les deux clés possibles
      if (user['uid'] != null) {
        userMap[user['uid']] = user;
      }
      if (user['UserId'] != null) {
        userMap[user['UserId']] = user;
      }
    }

    print('🗺️ Map des utilisateurs créé avec ${userMap.length} entrées');

    for (var ben in posBenData) {
      if (ben['pos_id'] != null && ben['pos_id'] is List) {
        for (var affectation in ben['pos_id']) {
          if (affectation is Map &&
              affectation['jour'] != null &&
              affectation['poste'] != null &&
              affectation['debut'] != null) {
            String jour = affectation['jour'];
            String poste = affectation['poste'];
            String debut = affectation['debut'];

            // Récupérer le nom/prénom du bénévole
            final benId = ben['ben_id'];
            final user = userMap[benId];

            String nom = 'Nom inconnu';
            String prenom = 'Prénom inconnu';

            if (user != null) {
              nom = user['nom'] ?? 'Nom inconnu';
              prenom = user['prenom'] ?? 'Prénom inconnu';
              print('✅ Utilisateur trouvé: $prenom $nom (ID: $benId)');
            } else {
              print('❌ Utilisateur non trouvé pour ben_id: $benId');
            }

            dayPosteTimeVolunteers[jour] ??= {};
            dayPosteTimeVolunteers[jour]![poste] ??= {};
            dayPosteTimeVolunteers[jour]![poste]![debut] ??= [];
            dayPosteTimeVolunteers[jour]![poste]![debut]!
                .add({'nom': nom, 'prenom': prenom});
          }
        }
      }
    }
    return Container(
      width: (kIsWeb || MediaQuery.of(context).size.width > 920)
          ? MediaQuery.of(context).size.width / 2.5
          : MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1)),
      child: Column(children: [
        Text("Ki é la?"),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dayPosteTimeVolunteers.length,
            itemBuilder: (context, index) {
              String jour = dayPosteTimeVolunteers.keys.elementAt(index);
              Map<String, Map<String, List<Map<String, String>>>> postesMap =
                  dayPosteTimeVolunteers[jour]!;

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
                      List<Map<String, String>> benevoles = horaireEntry.value;
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
        ),
      ]),
    );
  }

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

    // Supprimer tous les usages de 'items' (lignes 606-614)
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
    // File file = File(filePath);
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

  // --- Fonction pure : Liste des bénévoles ---
  List<Map<String, dynamic>> getBenevoles(List<Map<String, dynamic>> posBenData,
      List<Map<String, dynamic>> usersData) {
    final benevoleIds = <String>{};
    final benevoles = <Map<String, dynamic>>[];
    for (var ben in posBenData) {
      final benId = ben['ben_id'];
      if (benId != null && !benevoleIds.contains(benId)) {
        benevoleIds.add(benId);
        final user =
            usersData.firstWhere((u) => u['UserId'] == benId, orElse: () => {});
        if (user.isNotEmpty) {
          benevoles.add({
            'nom': user['nom'],
            'prenom': user['prenom'],
            'tel': user['tel'],
            'email': user['email']
          });
        }
      }
    }
    return benevoles;
  }

// --- Fonction pure : Liste des postes d'un utilisateur ---
  List<Map<String, dynamic>> getUserPosts(
      String userId, List<Map<String, dynamic>> posBenData) {
    final userPosts = <Map<String, dynamic>>[];
    for (var ben in posBenData) {
      if (ben['ben_id'] == userId &&
          ben['pos_id'] != null &&
          ben['pos_id'] is List) {
        for (var affectation in ben['pos_id']) {
          if (affectation is Map) {
            userPosts.add({
              'nomPoste': affectation['poste'],
              'jour': affectation['jour'],
              'heureDebut': affectation['debut'],
              'heureFin': affectation['fin'],
            });
          }
        }
      }
    }
    return userPosts;
  }

// --- Fonction pure : Map jour > poste > créneau > liste des bénévoles ---
  Map<String, Map<String, Map<String, List<Map<String, String>>>>>
      getDayPosteTimeVolunteers(List<Map<String, dynamic>> posBenData,
          List<Map<String, dynamic>> usersData) {
    Map<String, Map<String, Map<String, List<Map<String, String>>>>>
        dayPosteTimeVolunteers = {};
    for (var ben in posBenData) {
      if (ben['pos_id'] != null && ben['pos_id'] is List) {
        for (var affectation in ben['pos_id']) {
          if (affectation is Map &&
              affectation['jour'] != null &&
              affectation['poste'] != null &&
              affectation['debut'] != null) {
            String jour = affectation['jour'];
            String poste = affectation['poste'];
            String debut = affectation['debut'];
            final user = usersData.firstWhere((u) => u['uid'] == ben['ben_id'],
                orElse: () => {});
            String nom = user['nom'] ?? 'Nom inconnu';
            String prenom = user['prenom'] ?? 'Prénom inconnu';
            dayPosteTimeVolunteers[jour] ??= {};
            dayPosteTimeVolunteers[jour]![poste] ??= {};
            dayPosteTimeVolunteers[jour]![poste]![debut] ??= [];
            dayPosteTimeVolunteers[jour]![poste]![debut]!
                .add({'nom': nom, 'prenom': prenom});
          }
        }
      }
    }
    return dayPosteTimeVolunteers;
  }

// --- Fonction pure : Statistiques globales (exemple : nombre total de bénévoles) ---
  int getTotalBenevoles(List<Map<String, dynamic>> posBenData) {
    final benevoleIds = <String>{};
    for (var ben in posBenData) {
      final benId = ben['ben_id'];
      if (benId != null) {
        benevoleIds.add(benId);
      }
    }
    return benevoleIds.length;
  }

// --- Fonction pure : Export PDF (exemple) ---
  Future<void> exportBenevolesPDF(List<Map<String, dynamic>> benevoles) async {
    // Utiliser le package pdf pour générer le PDF à partir de la liste benevoles
    // ...
  }

// --- Utilisation dans le build ---
// Remplacer les widgets enfants par des appels à ces fonctions pures et affichage des résultats

  // Méthodes pour calculer les KPI
  int _getTotalVolunteers() {
    return usersData.length;
  }

  int _getOccupiedSlots() {
    int total = 0;
    for (var posBen in posBenData) {
      if (posBen['pos_id'] != null && posBen['pos_id'] is List) {
        final posIdList = posBen['pos_id'] as List;
        // Compter seulement les créneaux pour le jour sélectionné
        for (var pos in posIdList) {
          if (pos is Map<String, dynamic> && pos['jour'] == groupValue) {
            total++;
          }
        }
      }
    }
    print('=== DEBUG _getOccupiedSlots ===');
    print('Créneaux occupés pour $groupValue: $total');
    return total;
  }

  double _getFillRate() {
    num totalSlots = 0;
    num occupiedSlots = 0;

    print('=== DEBUG _getFillRate ===');
    print('Jour sélectionné: $groupValue');
    print('Nombre de posHorData: ${posHorData.length}');

    // Calculer le total des places disponibles
    for (var posHor in posHorData) {
      if (posHor['hor'] != null && posHor['hor'] is List) {
        print('Trouvé posHor pour le jour: ${posHor['jour']}');
        for (var hor in posHor['hor']) {
          if (hor is Map<String, dynamic>) {
            final tot = hor['tot'] ?? 0;
            print('Créneau - tot: $tot');

            // Vérifier que les valeurs sont valides
            if (tot > 0) {
              totalSlots += tot;
            }
          }
        }
      }
    }

    // Compter les vrais inscrits dans pos_ben
    for (var posBen in posBenData) {
      if (posBen['pos_id'] != null && posBen['pos_id'] is List) {
        final posIdList = posBen['pos_id'] as List;
        for (var pos in posIdList) {
          if (pos is Map<String, dynamic> && pos['jour'] == groupValue) {
            occupiedSlots++;
            print('Inscription trouvée pour ${pos['poste']} - ${pos['debut']}');
          }
        }
      }
    }

    print('Total slots: $totalSlots, Occupied slots: $occupiedSlots');

    // Éviter les valeurs aberrantes
    if (totalSlots <= 0) return 0;

    final result = (occupiedSlots / totalSlots) * 100;
    print('Taux de remplissage calculé: $result%');
    return result;
  }

  int _getActivePosts() {
    Set<String> posts = {};
    for (var posHor in posHorData) {
      if (posHor['poste'] != null) {
        posts.add(posHor['poste']);
      }
    }
    return posts.length;
  }

  int _getActiveDays() {
    Set<String> days = {};
    for (var posHor in posHorData) {
      if (posHor['jour'] != null) {
        days.add(posHor['jour']);
      }
    }
    return days.length;
  }

  int _getNewVolunteersThisWeek() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));

    int newVolunteers = 0;
    for (var user in usersData) {
      if (user['createdAt'] != null) {
        DateTime createdAt = (user['createdAt'] as Timestamp).toDate();
        if (createdAt.isAfter(weekAgo)) {
          newVolunteers++;
        }
      }
    }
    return newVolunteers;
  }
}

// Widget séparé pour Kifekoi avec son propre état
class _KifekoiWidget extends StatefulWidget {
  final List<Map<String, dynamic>> usersData;
  final List<Map<String, dynamic>> posBenData;

  const _KifekoiWidget({
    required this.usersData,
    required this.posBenData,
  });

  @override
  _KifekoiWidgetState createState() => _KifekoiWidgetState();
}

class _KifekoiWidgetState extends State<_KifekoiWidget> {
  String? selectedUser;
  List<Map<String, dynamic>> userPosts = [];

  @override
  Widget build(BuildContext context) {
    // Liste des utilisateurs (noms complets) triée par ordre alphabétique
    final userNames = widget.usersData
        .map((u) => '${u['nom'] ?? 'Inconnu'} ${u['prenom'] ?? 'Inconnu'}')
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Container(
      width: (kIsWeb || MediaQuery.of(context).size.width > 920)
          ? MediaQuery.of(context).size.width / 2.5
          : MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
      child: Column(
        children: [
          Text('Ki fè koi'),
          SizedBox(height: 10),
          Row(
            children: [
              // Autocomplete pour sélectionner un utilisateur avec recherche
              Expanded(
                flex: 2,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return userNames;
                      }
                      return userNames.where((String option) {
                        return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedUser = selection;
                        _updateUserPosts();
                      });
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un nom...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      option,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Liste des postes de l'utilisateur sélectionné
              Expanded(
                flex: 3,
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: userPosts.isEmpty
                      ? Center(
                          child: Text(
                            selectedUser == null
                                ? 'Sélectionnez un nom pour voir ses postes'
                                : 'Aucun poste trouvé pour cet utilisateur',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final poste = userPosts[index];
                            return Card(
                              margin: EdgeInsets.all(4),
                              child: ListTile(
                                title: Text(
                                  '${poste['nomPoste']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jour: ${poste['jour']}'),
                                    Text(
                                        'Heure: ${poste['heureDebut']} - ${poste['heureFin']}'),
                                  ],
                                ),
                                leading: Icon(
                                  Icons.work,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateUserPosts() {
    userPosts.clear();

    if (selectedUser == null) return;

    // Trouver l'utilisateur sélectionné
    final user = widget.usersData.firstWhere(
      (u) =>
          '${u['nom'] ?? 'Inconnu'} ${u['prenom'] ?? 'Inconnu'}' ==
          selectedUser,
      orElse: () => {},
    );

    if (user.isEmpty) return;

    final userId = user['uid'] ?? user['UserId'];
    if (userId == null) return;

    print(
        '🔍 Recherche des postes pour l\'utilisateur: $selectedUser (ID: $userId)');

    // Parcourir les données des bénévoles pour trouver les postes de cet utilisateur
    for (var ben in widget.posBenData) {
      if (ben['ben_id'] == userId &&
          ben['pos_id'] != null &&
          ben['pos_id'] is List) {
        print('📋 Postes trouvés pour $selectedUser');
        for (var affectation in ben['pos_id']) {
          if (affectation is Map) {
            userPosts.add({
              'nomPoste': affectation['poste'] ?? 'Poste inconnu',
              'jour': affectation['jour'] ?? 'Jour inconnu',
              'heureDebut': affectation['debut'] ?? 'Heure inconnue',
              'heureFin': affectation['fin'] ?? 'Heure inconnue',
            });
          }
        }
      }
    }

    print('📊 Total des postes trouvés: ${userPosts.length}');
  }
}
