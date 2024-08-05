import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'charts.dart'; // Importar el nuevo archivo para el gráfico

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  ConnectionScreen({required this.device});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothConnection? connection;
  List<double> receivedData = []; // Cambiar a una lista de double
  bool isConnecting = true;

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
          double value =
              double.tryParse(valueString) ?? 0.0; // Convertir a double
          receivedData.add(value); // Añadir el valor recibido
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectado a ${widget.device.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isConnecting) Center(child: CircularProgressIndicator()),
            Expanded(
              child: ListView.builder(
                itemCount: receivedData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Valor recibido: ${receivedData[index]}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navegar al gráfico
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartsScreen(data: receivedData),
                  ),
                );
              },
              child: Text('Ver Gráfico'),
            ),
          ],
        ),
      ),
    );
  }
}
