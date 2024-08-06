import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'connection_screen.dart'; // Importar la pantalla de conexión

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  void _checkBluetooth() async {
    BluetoothState state = await FlutterBluetoothSerial.instance.state;
    if (state == BluetoothState.STATE_OFF) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, activa Bluetooth")),
      );
    } else {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      _startDiscovery();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permisos necesarios no otorgados")),
      );
    }
  }

  void _startDiscovery() {
    setState(() {
      _devicesList.clear();
      _isDiscovering = true;
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        _devicesList.add(r);
      });
    }).onDone(() {
      setState(() {
        _isDiscovering = false;
      });

      if (_devicesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se encontraron dispositivos")),
        );
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectionScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Fondo azul oscuro
      appBar: AppBar(
         title: Text(
          'Bluetooth Scanner',
          style: TextStyle(color: Colors.white)), 
        backgroundColor: Colors.blueGrey[800], // Color de fondo del AppBar
        actions: [
          _isDiscovering
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: _startDiscovery,
                ),
        ],
      ),
      body: _devicesList.isEmpty
          ? Center(
              child: Text(
                "No hay dispositivos encontrados",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            )
          : ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDiscoveryResult result = _devicesList[index];
                return ListTile(
                  tileColor: Colors.blueGrey[900], // Fondo de cada ítem en la lista
                  title: Text(
                    result.device.name ?? "Unknown Device",
                    style: TextStyle(color: Colors.white), // Texto en blanco
                  ),
                  subtitle: Text(
                    result.device.address.toString(),
                    style: TextStyle(color: Colors.grey[300]), // Texto secundario en gris claro
                  ),
                  trailing: Text(
                    result.rssi.toString(),
                    style: TextStyle(color: Colors.white), // Texto en blanco
                  ),
                  onTap: () {
                    _connectToDevice(result.device);
                  },
                );
              },
            ),
    );
  }
}
