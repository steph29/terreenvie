import 'package:flutter/cupertino.dart';
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
  bool _isLoading = true;

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

  @override
  void dispose() {
    // Nettoyer les ressources avant de supprimer le widget
    // Note: Les requêtes Firestore .get() ne peuvent pas être annulées,
    // mais les vérifications mounted empêcheront les setState() après dispose
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Charger tous les pos_hor et pos_ben du jour sélectionné
      final posHorSnapshot =
          await _posHorRef.where('jour', isEqualTo: groupValue).get();

      if (!mounted) return;

      posHorData = posHorSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      final posBenSnapshot = await _posBenRef.get();

      if (!mounted) return;

      posBenData = posBenSnapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      // Construire la liste des postes
      _postes = posHorData.map((d) => d['poste'] as String).toList();

      // S'assurer qu'il y a au moins 3 postes pour éviter les erreurs fl_chart
      while (_postes.length < 3) {
        _postes.add('—');
      }

      // Construire la liste des horaires
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

      if (!mounted) return;

      _horaires = horairesList;
      _selectedHoraireIndex = 0;

      if (_horaires.isNotEmpty && mounted) {
        _computeRadarData();
      }
    } catch (e) {
      if (mounted) {
        print('Erreur lors du chargement des données: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _computeRadarData() {
    if (!mounted) return;

    if (_horaires.isEmpty) {
      if (mounted) {
        setState(() {
          _dataValues = List.filled(_postes.length, 0.0);
        });
      }
      return;
    }

    String selectedHoraire = _horaires[_selectedHoraireIndex];

    // Map du nombre de places par poste/créneau
    Map<String, int> placesByPoste = {};
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
    Map<String, int> countByPoste = {};
    for (var ben in posBenData) {
      if (ben['pos_id'] != null && ben['pos_id'] is List) {
        for (var affectation in ben['pos_id']) {
          if (affectation is Map &&
              affectation['jour'] == groupValue &&
              affectation['debut'] == selectedHoraire) {
            String poste = affectation['poste'];
            countByPoste[poste] = (countByPoste[poste] ?? 0) + 1;
          }
        }
      }
    }

    // Calcul des pourcentages
    _dataValues = [];
    for (var poste in _postes) {
      int inscrits = countByPoste[poste] ?? 0;
      int places = placesByPoste[poste] ?? 0;
      double percentage = places > 0 ? (inscrits / places) * 100 : 0.0;
      // Normaliser à 100% maximum
      _dataValues.add(percentage > 100 ? 100.0 : percentage);
    }

    if (mounted) {
      setState(() {});
    }
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
              if (mounted) {
                setState(() {
                  groupValue = value;
                });
                _loadAllData();
              }
            },
            children: {
              'Lundi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Lundi'),
              ),
              'Mardi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Mardi'),
              ),
              'Mercredi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Mercredi'),
              ),
              'Jeudi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Jeudi'),
              ),
              'Vendredi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Vendredi'),
              ),
              'Samedi': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Samedi'),
              ),
              'Dimanche': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Dimanche'),
              ),
            },
          ),

          SizedBox(height: 20),

          // Slider pour l'heure
          if (_horaires.isNotEmpty) ...[
            Text('Créneau horaire: ${_horaires[_selectedHoraireIndex]}'),
            Slider(
              value: _selectedHoraireIndex.toDouble(),
              min: 0,
              max: (_horaires.length - 1).toDouble(),
              divisions: _horaires.length - 1,
              onChanged: (double value) {
                if (mounted) {
                  setState(() {
                    _selectedHoraireIndex = value.round();
                  });
                  _computeRadarData();
                }
              },
            ),
          ] else ...[
            Text('Aucun créneau disponible pour ce jour'),
          ],

          SizedBox(height: 20),

          // Graphique radar
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RadarChartWidget(
                    data: _dataValues,
                    labels: _postes,
                  ),
          ),
        ],
      ),
    );
  }
}
