import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'RadarChartWidget.dart';

class RadarChartScreen extends StatefulWidget {
  @override
  _RadarChartScreenState createState() => _RadarChartScreenState();
}

class _RadarChartScreenState extends State<RadarChartScreen> {
  final CollectionReference _posBenRef =
      FirebaseFirestore.instance.collection('pos_ben');
  final CollectionReference _posHorRef =
      FirebaseFirestore.instance.collection('pos_hor');

  String? groupValue; // Jour sélectionné
  List<double> _dataValues = [
    20,
    25,
    15
  ]; // Données de remplissage en pourcentages
  List<String> _postes = [
    'Buvette',
    'crepes',
    'entree'
  ]; // Intitulés des postes

  // Ajout pour la jauge horaire
  List<String> _horaires = [];
  int _selectedHoraireIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser groupValue sur le jour d'aujourd'hui (français)
    final joursFrancais = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    final today = DateTime.now();
    // DateTime.weekday: 1 = lundi, 7 = dimanche
    groupValue = joursFrancais[today.weekday - 1];
    _fetchPostes(); // Récupérer les intitulés des postes au démarrage
  }

  Future<void> _fetchPostes() async {
    if (groupValue == null) return;
    try {
      final posHorSnapshot = await _posHorRef.get();
      _postes = posHorSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((data) => data['jour'] == groupValue)
          .map((data) => data['poste'] as String?)
          .where((poste) => poste != null)
          .cast<String>()
          .toList();
      // Astuce : compléter pour avoir au moins 3 axes
      while (_postes.length < 3) {
        _postes.add('—');
      }
      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des intitulés de postes : $e");
    }
  }

  Future<void> _fetchHoraires() async {
    if (groupValue == null) return;
    try {
      final posHorSnapshot = await _posHorRef.get();
      Set<String> horairesSet = {};
      for (var doc in posHorSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['jour'] == groupValue && data['hor'] != null) {
          for (var h in data['hor']) {
            if (h is Map && h['debut'] != null) {
              horairesSet.add(h['debut'].toString());
            }
          }
        }
      }
      if (horairesSet.isEmpty) {
        // Valeur par défaut si rien trouvé
        horairesSet = {
          '08h00',
          '09h00',
          '10h00',
          '11h00',
          '12h00',
          '13h00',
          '14h00',
          '15h00',
          '16h00',
          '17h00',
          '18h00',
          '19h00',
          '20h00'
        };
      }
      // Tri intelligent : par heure si possible
      List<String> horairesList = horairesSet.toList();
      horairesList.sort((a, b) {
        // Extraire l'heure en int pour trier
        int getHour(String s) {
          final match = RegExp(r'^(\d{1,2})').firstMatch(s);
          return match != null ? int.parse(match.group(1)!) : 0;
        }

        return getHour(a).compareTo(getHour(b));
      });
      _horaires = horairesList;
      _selectedHoraireIndex = 0;
      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des horaires : $e");
    }
  }

  String normalizeHour(String s) {
    // Garde uniquement les chiffres et les lettres h ou : puis remplace : par h
    return s.replaceAll(RegExp(r'[^0-9h:]'), '').replaceAll(':', 'h');
  }

  Future<void> _fetchData() async {
    if (groupValue == null || _horaires.isEmpty) return;
    String selectedHoraire = _horaires[_selectedHoraireIndex];
    try {
      List<double> values = List.filled(_postes.length, 0.0);
      // Nouveau : compter le nombre de bénévoles par poste pour le créneau sélectionné
      final posBenSnapshot = await _posBenRef.get();
      // Compteur par poste
      Map<String, int> countByPoste = {for (var p in _postes) p: 0};
      for (var doc in posBenSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['pos_id'] != null && data['pos_id'] is List) {
          for (var affectation in data['pos_id']) {
            if (affectation is Map) {
              final poste = affectation['poste']?.toString();
              final jour = affectation['jour']?.toString();
              final debut = affectation['debut']?.toString();
              if (poste != null &&
                  jour == groupValue &&
                  normalizeHour(debut ?? '') ==
                      normalizeHour(selectedHoraire)) {
                if (countByPoste.containsKey(poste)) {
                  countByPoste[poste] = countByPoste[poste]! + 1;
                }
              }
            }
          }
        }
      }
      // Récupérer le nombre de places par poste/créneau dans pos_hor
      final posHorSnapshot = await _posHorRef.get();
      Map<String, int> placesByPoste = {
        for (var p in _postes) p: 1
      }; // Valeur par défaut 1 pour éviter division par zéro
      for (var doc in posHorSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['jour'] == groupValue &&
            data['poste'] != null &&
            data['hor'] != null) {
          String poste = data['poste'].toString();
          for (var h in data['hor']) {
            if (h is Map &&
                h['debut'] != null &&
                normalizeHour(h['debut'].toString()) ==
                    normalizeHour(selectedHoraire)) {
              int nbTot = 1;
              if (h['tot'] != null) {
                nbTot = int.tryParse(h['tot'].toString()) ?? 1;
              }
              placesByPoste[poste] = nbTot;
            }
          }
        }
      }
      // Calcul du taux de remplissage (en pourcentage)
      for (int i = 0; i < _postes.length; i++) {
        String poste = _postes[i];
        int count = countByPoste[poste] ?? 0;
        int nbPlaces = placesByPoste[poste] ?? 1;
        double percentage = (count / nbPlaces) * 100;
        values[i] = percentage;
      }
      setState(() {
        _dataValues = values;
      });
    } catch (e) {
      print("Erreur de récupération des données Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Jauge horaire
        if (_horaires.isNotEmpty)
          Column(
            children: [
              Text('Sélectionnez un créneau horaire'),
              Slider(
                value: _selectedHoraireIndex.toDouble(),
                min: 0,
                max: (_horaires.length - 1).toDouble(),
                divisions: _horaires.length - 1,
                label: _horaires[_selectedHoraireIndex],
                onChanged: (double value) {
                  setState(() {
                    _selectedHoraireIndex = value.round();
                    _fetchData();
                  });
                },
              ),
              Text('Heure : ${_horaires[_selectedHoraireIndex]}'),
            ],
          ),
        Text('Radar chart'),
        buildSegmentControl(),
        Expanded(
          child: _dataValues.isEmpty
              ? Center(child: CircularProgressIndicator())
              : RadarChartWidget(
                  data: _dataValues, // Liste des pourcentages
                  labels: _postes, // Liste des intitulés des postes
                ),
        ),
      ],
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
        onValueChanged: (newValue) async {
          setState(() {
            groupValue = newValue;
          });
          await _fetchPostes();
          await _fetchHoraires();
          await _fetchData();
        },
      );

  Widget buildSegment(String text) => Padding(
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
}
