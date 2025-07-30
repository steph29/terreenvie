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
  List<double> _dataValues = [];
  List<String> _postes = [];
  List<String> _horaires = [];
  int _selectedHoraireIndex = 0;
  List<Map<String, dynamic>> posHorData = [];
  List<Map<String, dynamic>> posBenData = [];

  @override
  void initState() {
    super.initState();
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
    groupValue = joursFrancais[today.weekday - 1];
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Charger tous les pos_hor et pos_ben du jour sélectionné
    final posHorSnapshot =
        await _posHorRef.where('jour', isEqualTo: groupValue).get();
    posHorData = posHorSnapshot.docs
        .map((d) => d.data() as Map<String, dynamic>)
        .toList();

    final posBenSnapshot = await _posBenRef.get();
    posBenData = posBenSnapshot.docs
        .map((d) => d.data() as Map<String, dynamic>)
        .toList();

    // Construire la liste des postes et horaires
    _postes = posHorData.map((d) => d['poste'] as String).toList();
    while (_postes.length < 3) {
      _postes.add('—');
    }
    Set<String> horairesSet = {};
    for (var d in posHorData) {
      if (d['hor'] != null) {
        for (var h in d['hor']) {
          if (h is Map && h['debut'] != null) {
            horairesSet.add(h['debut'].toString());
          }
        }
      }
    }
    List<String> horairesList = horairesSet.toList();
    horairesList.sort((a, b) {
      int getHour(String s) {
        final match = RegExp(r'^(\d{1,2})').firstMatch(s);
        return match != null ? int.parse(match.group(1)!) : 0;
      }

      return getHour(a).compareTo(getHour(b));
    });
    _horaires = horairesList;
    _selectedHoraireIndex = 0;
    _computeRadarData();
  }

  void _computeRadarData() {
    if (_horaires.isEmpty) return;
    String selectedHoraire = _horaires[_selectedHoraireIndex];
    // Map du nombre de places par poste/créneau
    Map<String, int> placesByPoste = {for (var p in _postes) p: 1};
    for (var d in posHorData) {
      String poste = d['poste'];
      if (d['hor'] != null) {
        for (var h in d['hor']) {
          if (h is Map && h['debut'] == selectedHoraire && h['tot'] != null) {
            placesByPoste[poste] = int.tryParse(h['tot'].toString()) ?? 1;
          }
        }
      }
    }
    // Map du nombre d'inscrits par poste/créneau
    Map<String, int> countByPoste = {for (var p in _postes) p: 0};
    for (var ben in posBenData) {
      if (ben['pos_id'] != null && ben['pos_id'] is List) {
        for (var affectation in ben['pos_id']) {
          if (affectation is Map &&
              affectation['jour'] == groupValue &&
              affectation['debut'] == selectedHoraire) {
            String poste = affectation['poste'];
            if (countByPoste.containsKey(poste)) {
              countByPoste[poste] = countByPoste[poste]! + 1;
            }
          }
        }
      }
    }
    // Calcul des pourcentages
    _dataValues = [];
    for (var poste in _postes) {
      int inscrits = countByPoste[poste] ?? 0;
      int places = placesByPoste[poste] ?? 1;
      double percentage = (inscrits / places) * 100;
      // Normaliser à 100% maximum
      _dataValues.add(percentage > 100 ? 100.0 : percentage);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    _computeRadarData();
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
                  data: _dataValues,
                  labels: _postes,
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
          await _loadAllData();
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
