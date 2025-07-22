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
      // On suppose que chaque poste a les mêmes horaires pour un jour donné
      final posHorSnapshot = await _posHorRef.get();
      Set<String> horairesSet = {};
      for (var doc in posHorSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['jour'] == groupValue &&
            data['debut'] != null &&
            data['fin'] != null) {
          // On ajoute tous les créneaux horaires (par heure)
          int debut = int.tryParse(data['debut'].toString().split(':')[0]) ?? 8;
          int fin = int.tryParse(data['fin'].toString().split(':')[0]) ?? 20;
          for (int h = debut; h < fin; h++) {
            horairesSet.add(h.toString().padLeft(2, '0') + ':00');
          }
        }
      }
      if (horairesSet.isEmpty) {
        // Valeur par défaut si rien trouvé
        horairesSet = {
          '08:00',
          '09:00',
          '10:00',
          '11:00',
          '12:00',
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
          '18:00',
          '19:00',
          '20:00'
        };
      }
      _horaires = horairesSet.toList()..sort();
      _selectedHoraireIndex = 0;
      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des horaires : $e");
    }
  }

  Future<void> _fetchData() async {
    if (groupValue == null || _horaires.isEmpty) return;
    String selectedHoraire = _horaires[_selectedHoraireIndex];
    try {
      final nbBenSnapshot = await _posHorRef.doc('hor').get();
      final nbBenData = nbBenSnapshot.data() as Map<String, dynamic>?;
      final nbBen = nbBenData?['nbBen'] ?? 1;
      List<double> values = List.filled(_postes.length, 0.0);
      final posBenSnapshot = await _posBenRef.get();
      for (var posDoc in posBenSnapshot.docs) {
        final daySnapshot =
            await _posBenRef.doc(posDoc.id).collection(groupValue!).get();
        for (var doc in daySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          // On suppose que la clé de l'heure est présente dans les données
          for (int i = 0; i < _postes.length; i++) {
            String posteId = _postes[i];
            if (posteId != '—' &&
                data.containsKey(posteId) &&
                data['heure'] == selectedHoraire) {
              int count = data[posteId];
              double percentage = (count / nbBen) * 100;
              values[i] = percentage;
            }
          }
        }
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
