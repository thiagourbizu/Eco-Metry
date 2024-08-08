import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'data_screen.dart'; // Importar la nueva pantalla de datos
import 'charts.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _connectToDevice();
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
        setState(() {
          String valueString = String.fromCharCodes(data).trim();
          List<String> values = valueString.split(',');

          // Almacenar las últimas 50 líneas recibidas
          if (receivedLines.length >= 25) {
            receivedLines.removeAt(0);
          }
          receivedLines.add(valueString);

          // Emitir datos actualizados al stream
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
            if (temperatureData.length >= 30) {
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
    _streamController
        .close(); // Cerrar el StreamController al deshacerse del widget
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueGrey[300]!,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Temperatura',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentTemperature.toStringAsFixed(1)} °C',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueGrey[300]!,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Velocidad',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${currentSpeed.toStringAsFixed(1)} km/h',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
            SizedBox(height: 20),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueGrey[300]!,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Voltaje',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${currentVoltage.toStringAsFixed(1)} V',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueGrey[300]!,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Amperaje',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${currentCurrent.toStringAsFixed(1)} A',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
