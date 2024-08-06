import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'charts.dart'; // Importar el archivo para el gráfico

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  ConnectionScreen({required this.device});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothConnection? connection;
  List<double> receivedData = [];
  bool isConnecting = true;
  double currentTemperature = 0.0;
  double currentSpeed = 0.0;

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
          List<String> values = valueString.split(','); // Suponiendo que los datos vienen separados por comas

          if (values.length == 2) {
            double tempValue = double.tryParse(values[0]) ?? 0.0; // Convertir a double
            double speedValue = double.tryParse(values[1]) ?? 0.0; // Convertir a double

            currentTemperature = tempValue;
            currentSpeed = speedValue;
          }

          // Añadir valores a la lista de datos recibidos para graficar
          if (receivedData.length >= 30) {
            receivedData.removeAt(0); // Eliminar el dato más antiguo
          }
          receivedData.add(currentSpeed); // Añadir el valor de velocidad a la lista
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
    super.dispose();
  }

  void _navigateToChart(String chartType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartsScreen(data: receivedData),
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
                    aspectRatio: 1.0, // Proporción de aspecto 1:1 para mantener la altura igual
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
                              offset: Offset(0, 4), // cambios en la posición de la sombra
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
                            Text(
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
                    aspectRatio: 1.0, // Proporción de aspecto 1:1 para mantener la altura igual
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
                              offset: Offset(0, 4), // cambios en la posición de la sombra
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
                            Text(
                              'Velocidad',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentSpeed.toStringAsFixed(1)} km/h',
                              style: TextStyle(
                                fontSize: 24, // Tamaño reducido del texto
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
            // Removido el botón "Ver Gráfico" como se solicitó
          ],
        ),
      ),
    );
  }
}
