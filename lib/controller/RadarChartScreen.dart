import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

class RadarChartScreen extends StatefulWidget {
  @override
  _RadarChartScreenState createState() => _RadarChartScreenState();
}

class _RadarChartScreenState extends State<RadarChartScreen> {
  String groupValue = "Samedi";
  double selectedHour = 9.0;
  List<String> _labels = [];
  List<double> _dataValues = [];
  List<Map<String, dynamic>> _postes = [];
  List<Map<String, dynamic>> _posBenData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les données pos_hor pour le jour sélectionné
      final posHorSnapshot = await FirebaseFirestore.instance
          .collection('pos_hor')
          .where('jour', isEqualTo: groupValue)
          .get();

      _postes = posHorSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      // Charger les données pos_ben
      final posBenSnapshot =
          await FirebaseFirestore.instance.collection('pos_ben').get();

      _posBenData = posBenSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      _computeRadarData();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _computeRadarData() {
    _labels = [];
    _dataValues = [];

    // Extraire les noms des postes
    for (var poste in _postes) {
      _labels.add(poste['poste'] ?? 'Poste inconnu');
    }

    // S'assurer qu'il y a au moins 3 postes pour éviter les erreurs fl_chart
    while (_labels.length < 3) {
      _labels.add('—');
    }

    // Calculer les pourcentages de remplissage pour chaque poste
    for (var poste in _postes) {
      String posteName = poste['poste'] ?? '';
      List<dynamic> horList = poste['hor'] ?? [];

      // Trouver le créneau correspondant à l'heure sélectionnée
      String selectedHourStr = _formatHour(selectedHour);
      Map<String, dynamic>? selectedCreneau;

      for (var hor in horList) {
        if (hor['debut'] == selectedHourStr) {
          selectedCreneau = hor;
          break;
        }
      }

      if (selectedCreneau != null) {
        int nbPlaces = selectedCreneau['tot'] ?? 0;
        int inscrits = _countInscrits(posteName, selectedHourStr);

        double percentage = nbPlaces > 0 ? (inscrits / nbPlaces) * 100 : 0.0;
        // Normaliser à 100% maximum
        _dataValues.add(percentage > 100 ? 100.0 : percentage);
      } else {
        _dataValues.add(0.0);
      }
    }

    // S'assurer qu'il y a au moins 3 valeurs
    while (_dataValues.length < 3) {
      _dataValues.add(0.0);
    }
  }

  int _countInscrits(String poste, String heure) {
    int count = 0;

    for (var doc in _posBenData) {
      List<dynamic> posIds = doc['pos_id'] ?? [];

      for (var pos in posIds) {
        if (pos['poste'] == poste &&
            pos['debut'] == heure &&
            pos['jour'] == groupValue) {
          count++;
        }
      }
    }

    return count;
  }

  String _formatHour(double hour) {
    int hourInt = hour.toInt();
    return '${hourInt.toString().padLeft(2, '0')}h00';
  }

  double _normalizeHour(String hourStr) {
    // Convertir "14h00" en 14.0
    return double.tryParse(hourStr.replaceAll('h00', '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sélecteur de jour
          CupertinoSegmentedControl<String>(
            groupValue: groupValue,
            onValueChanged: (String value) {
              setState(() {
                groupValue = value;
              });
              _loadAllData();
            },
            children: {
              'Samedi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Samedi'),
              ),
              'Dimanche': Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Dimanche'),
              ),
            },
          ),

          SizedBox(height: 20),

          // Slider pour l'heure
          Text('Créneau horaire: ${_formatHour(selectedHour)}'),
          Slider(
            value: selectedHour,
            min: 9.0,
            max: 18.0,
            divisions: 9,
            onChanged: (double value) {
              setState(() {
                selectedHour = value;
              });
              // Recalculer avec les données existantes
              _computeRadarData();
            },
          ),

          SizedBox(height: 20),

          // Graphique radar
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RadarChartWidget(
                    labels: _labels,
                    dataValues: _dataValues,
                  ),
          ),
        ],
      ),
    );
  }
}

class RadarChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> dataValues;

  RadarChartWidget({
    required this.labels,
    required this.dataValues,
  });

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries:
                dataValues.map((value) => RadarEntry(value: value)).toList(),
            fillColor: Colors.blue.withOpacity(0.3),
            borderColor: Colors.blue,
            borderWidth: 2,
          ),
        ],
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        getTitle: (index, angle) {
          // Protection contre les dépassements d'index
          String label = (index < labels.length) ? labels[index] : '';
          return RadarChartTitle(
            text: label,
          );
        },
        tickCount: 5,
        ticksTextStyle: TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      ),
    );
  }
}
