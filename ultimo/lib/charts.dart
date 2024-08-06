import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsScreen extends StatelessWidget {
  final List<double> data;

  ChartsScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gráfico de Datos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202), // Color de fondo de la AppBar
        iconTheme: IconThemeData(color: Colors.white), // Color de los íconos en la AppBar
      ),
      body: Container(
        color: Colors.blueGrey[900], // Fondo oscuro para el cuerpo de la pantalla
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          backgroundColor: Colors.blueGrey[900], // Fondo oscuro del gráfico
          primaryXAxis: NumericAxis(
            labelStyle: TextStyle(color: Colors.white), // Color de las etiquetas del eje X
            axisLine: AxisLine(
              color: Colors.white, // Color de la línea del eje X
            ),
            majorGridLines: MajorGridLines(
              color: Colors.white.withOpacity(0.3), // Línea de cuadrícula
            ),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(color: Colors.white), // Color de las etiquetas del eje Y
            axisLine: AxisLine(
              color: Colors.white, // Color de la línea del eje Y
            ),
            majorGridLines: MajorGridLines(
              color: Colors.white.withOpacity(0.3), // Línea de cuadrícula
            ),
          ),
          series: <LineSeries<double, int>>[
            LineSeries<double, int>(
              dataSource: data,
              xValueMapper: (double value, int index) => index,
              yValueMapper: (double value, int index) => value,
              color: Colors.white, // Color de la línea del gráfico
            ),
          ],
        ),
      ),
    );
  }
}
