import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/previsao.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({required this.dias, super.key});
  final List<DiaPrevisao> dias;
  @override
  Widget build(BuildContext context) {
    final valid =
        dias.where((d) => d.minima != null || d.maxima != null).toList();
    if (valid.length < 2)
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Não há dados suficientes para apresentar o gráfico.'),
        ),
      );
    final spotsMin = <FlSpot>[];
    final spotsMax = <FlSpot>[];
    for (var i = 0; i < valid.length; i++) {
      if (valid[i].minima != null)
        spotsMin.add(FlSpot(i.toDouble(), valid[i].minima!));
      if (valid[i].maxima != null)
        spotsMax.add(FlSpot(i.toDouble(), valid[i].maxima!));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperaturas (°C)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (valid.length - 1).toDouble(),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          return i < valid.length
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    valid[i].dia.length >= 5
                                        ? valid[i].dia.substring(5)
                                        : valid[i].dia,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsMin,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: spotsMax,
                      isCurved: true,
                      color: Colors.deepOrange,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, color: Colors.blue),
                const SizedBox(width: 5),
                const Text('Mínima'),
                const SizedBox(width: 18),
                Container(width: 12, height: 12, color: Colors.deepOrange),
                const SizedBox(width: 5),
                const Text('Máxima'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
