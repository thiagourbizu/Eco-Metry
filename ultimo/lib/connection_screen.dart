import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'data_screen.dart'; // Importar la nueva pantalla de datos
import 'charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
//import 'package:kdgaugeview/kdgaugeview.dart';

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  ConnectionScreen({required this.device});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothConnection? connection;
  List<double> temperatureData = [];
  List<double> speedData = [];
  List<double> voltageData = [];
  List<double> currentData = [];
  List<String> receivedLines = [];
  bool isConnecting = true;
  double currentTemperature = 0.0;
  double currentSpeed = 0.0;
  double currentVoltage = 0.0;
  double currentCurrent = 0.0;

  final StreamController<List<String>> _streamController =
      StreamController<List<String>>.broadcast();

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
    _startSpeedometerUpdate(); // Iniciar actualización del velocímetro
  }

  void _connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.device.address);
      print('Conectado a ${widget.device.name}');
      setState(() {
        isConnecting = false;
      });

      // Escuchar datos
      connection!.input!.listen((data) {
        String valueString = String.fromCharCodes(data).trim();
        List<String> values = valueString.split(',');

        // Depuración
        print('Datos recibidos: $valueString');

        setState(() {
          if (receivedLines.length >= 25) {
            receivedLines.removeAt(0);
          }
          receivedLines.add(valueString);

          _streamController.add(receivedLines);

          if (values.length == 4) {
            double tempValue = double.tryParse(values[0]) ?? 0.0;
            double speedValue = double.tryParse(values[1]) ?? 0.0;
            double voltageValue = double.tryParse(values[2]) ?? 0.0;
            double currentValue = double.tryParse(values[3]) ?? 0.0;

            currentTemperature = tempValue;
            currentSpeed = speedValue;
            currentVoltage = voltageValue;
            currentCurrent = currentValue;

            // Almacenar los últimos 30 datos
            if (temperatureData.length >= 50) {
              temperatureData.removeAt(0);
            }
            temperatureData.add(currentTemperature);

            if (speedData.length >= 30) {
              speedData.removeAt(0);
            }
            speedData.add(currentSpeed);

            if (voltageData.length >= 30) {
              voltageData.removeAt(0);
            }
            voltageData.add(currentVoltage);

            if (currentData.length >= 30) {
              currentData.removeAt(0);
            }
            currentData.add(currentCurrent);
          }
        });
      }).onDone(() {
        print('Conexión cerrada');
        _showConnectionClosedDialog();
      });
    } catch (e) {
      print('No se pudo conectar: $e');
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _startSpeedometerUpdate() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        // Forzar la actualización del velocímetro
      });
    });
  }

  void _showConnectionClosedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conexión Cerrada'),
          content: Text('La conexión con el dispositivo se ha cerrado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    _streamController.close(); // Cerrar el StreamController al deshacerse del widget
    _updateTimer?.cancel(); // Cancelar el temporizador al deshacerse del widget
    super.dispose();
  }

  void _navigateToChart(String chartType) {
    List<double> dataToPass;
    switch (chartType) {
      case 'temperature':
        dataToPass = List.from(temperatureData);
        break;
      case 'speed':
        dataToPass = List.from(speedData);
        break;
      case 'voltage':
        dataToPass = List.from(voltageData);
        break;
      case 'current':
        dataToPass = List.from(currentData);
        break;
      default:
        dataToPass = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartsScreen(
          data: dataToPass,
          chartType: chartType,
        ),
      ),
    );
  }

  void _navigateToDataScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataScreen(stream: _streamController.stream),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final orientation = MediaQuery.of(context).orientation;

  if (orientation == Orientation.landscape) {
    // Modo horizontal
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        title: Text(
          'Conectado a ${widget.device.name}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Row(
          children: [
            // Nuevo velocímetro a la izquierda con margen izquierdo
            Padding(
              padding: const EdgeInsets.only(left: 70.0, top: 15.0), // Margen izquierdo
              child: Container(
                width: 310, // Tamaño del velocímetro
                height: 310, // Tamaño del velocímetro
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: currentSpeed),
                  duration: const Duration(milliseconds: 100), // Duración de la animación
                  builder: (BuildContext context, double value, Widget? child) {
                    return Center(
                      child: Stack(
                        children: [
                          // Fondo redondeado detrás del velocímetro
                          Container(
                            width: 310,
                            height: 310,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(155), // Radio de borde redondeado
                              border: Border.all(
                                width: 20, // Grosor del borde
                                color: Colors.black.withOpacity(0.3), // Color del borde
                              ),
                            ),
                          ),
                          SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 60, // Ajustado para un máximo de 60 km/h
                                ranges: <GaugeRange>[
                                  // Color verde
                                  GaugeRange(
                                    startValue: 0,
                                    endValue: value < 20 ? value : 20,
                                    color: Colors.green,
                                    startWidth: 20,
                                    endWidth: 20,
                                  ),
                                  // Color naranja
                                  GaugeRange(
                                    startValue: 20,
                                    endValue: value < 40 ? value : 40,
                                    color: Colors.orange,
                                    startWidth: 20,
                                    endWidth: 20,
                                  ),
                                  // Color rojo
                                  GaugeRange(
                                    startValue: 40,
                                    endValue: value < 60 ? value : 60,
                                    color: Colors.red,
                                    startWidth: 20,
                                    endWidth: 20,
                                  ),
                                  GaugeRange(
                                    startValue: 70,
                                    endValue: value < 70 ? value : 70,
                                    color: const Color.fromARGB(255, 85, 85, 85),
                                    startWidth: 20,
                                    endWidth: 20,
                                  )
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(value: value),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Padding(
                                      padding: const EdgeInsets.only(top: 50.0), // Ajusta la posición hacia abajo
                                      child: Text(
                                        'km/h',
                                        style: TextStyle(
                                          fontSize: 20, // Tamaño de fuente para "km/h"
                                          fontWeight: FontWeight.bold, // Velocidad en negrita
                                          color: Colors.white, // Color del texto
                                        ),
                                      ),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.5,
                                  ),
                                ],
                                axisLabelStyle: GaugeTextStyle(
                                  color: Colors.white,
                                  fontSize: 20, // Tamaño de fuente agrandado para las etiquetas
                                ),
                                majorTickStyle: MajorTickStyle(
                                  length: 15,
                                  thickness: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      SizedBox(width: 155),
              // Column of remaining boxes
              Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Temperature
      Padding(
        padding: const EdgeInsets.only(top: 13.0, right: 50.0), // Margen superior de 16px
        child: GestureDetector(
          //onTap: () => _navigateToChart('temperature'),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blueGrey[700],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.blueGrey[300]!,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                '${currentTemperature.toStringAsFixed(1)} °C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 16),
                    // Voltage
GestureDetector(
  //onTap: () => _navigateToChart('voltage'),
  child: Padding(
    padding: const EdgeInsets.only(right: 50.0), // Margen derecho de 10px
    child: Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.blueGrey[300]!,
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          '${currentVoltage.toStringAsFixed(1)} V',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ),
),
SizedBox(height: 16),
                    // Current
GestureDetector(
  //onTap: () => _navigateToChart('current'),
  child: Padding(
    padding: const EdgeInsets.only(right: 50.0), // Margen derecho de 20px
    child: Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.blueGrey[300]!,
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          '${currentCurrent.toStringAsFixed(1)} A',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } 
    else
         // Modo vertical
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        title: Text(
          'Conectado a ${widget.device.name}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.view_list, color: Colors.white),
            onPressed: _navigateToDataScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isConnecting)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onTap: () => _navigateToChart('temperature'),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blueGrey[300]!, // Cambiado a Colors.blueGrey[700]
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Temperatura',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentTemperature.toStringAsFixed(1)} °C',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onTap: () => _navigateToChart('speed'),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blueGrey[300]!, // Cambiado a Colors.blueGrey[700]
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Velocidad',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentSpeed.toStringAsFixed(1)} km/h',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onTap: () => _navigateToChart('voltage'),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blueGrey[300]!, // Cambiado a Colors.blueGrey[700]
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Voltaje',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentVoltage.toStringAsFixed(1)} V',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onTap: () => _navigateToChart('current'),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blueGrey[300]!, // Cambiado a Colors.blueGrey[700]
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Amperaje',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentCurrent.toStringAsFixed(1)} A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}