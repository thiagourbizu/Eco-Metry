import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsScreen extends StatelessWidget {
  final List<double> data; // Cambiar a List<double>

  ChartsScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Datos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: NumericAxis(),
          primaryYAxis: NumericAxis(),
          series: <LineSeries<double, int>>[
            LineSeries<double, int>(
              dataSource: data,
              xValueMapper: (double value, int index) => index,
              yValueMapper: (double value, int index) => value,
            ),
          ],
        ),
      ),
    );
  }
}
