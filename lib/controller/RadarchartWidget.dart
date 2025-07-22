import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RadarChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  RadarChartWidget({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              entryRadius: 3,
              dataEntries:
                  data.map((value) => RadarEntry(value: value)).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData:
              const BorderSide(width: 1, color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          getTitle: (index, angle) {
            // Protection contre les dépassements d'index
            String label = (index < labels.length) ? labels[index] : '';
            return RadarChartTitle(
              text: label,
              //textStyle: TextStyle(color: Colors.black, fontSize: 10),
            );
          },
          tickCount: 5, // Nombre de cercles de ticks (de 0 à 100%)
          ticksTextStyle: TextStyle(color: Colors.grey, fontSize: 8),
          tickBorderData: BorderSide(color: Colors.grey.shade300),
          gridBorderData: BorderSide(color: Colors.grey.shade400),
          //maxRadarValue: 100.0, // Définit le maximum du graphique à 100%
        ),
      ),
    );
  }
}
