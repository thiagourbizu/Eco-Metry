import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsScreen extends StatelessWidget {
  final List<double> data;
  final String chartType;

  ChartsScreen({required this.data, required this.chartType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chartType == 'temperature' ? 'Gráfico de Temperatura' : 'Gráfico de elocidad',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.blueGrey[900],
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          backgroundColor: Colors.blueGrey[900],
          primaryXAxis: NumericAxis(
            labelStyle: TextStyle(color: Colors.white),
            axisLine: AxisLine(color: Colors.white),
            majorGridLines: MajorGridLines(color: Colors.white.withOpacity(0.3)),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(color: Colors.white),
            axisLine: AxisLine(color: Colors.white),
            majorGridLines: MajorGridLines(color: Colors.white.withOpacity(0.3)),
          ),
          series: <LineSeries<double, int>>[
            LineSeries<double, int>(
              dataSource: data,
              xValueMapper: (double value, int index) => index,
              yValueMapper: (double value, int index) => value,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
