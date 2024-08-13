import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Importación necesaria para StreamSubscription
import 'connection_screen.dart'; // Importar la pantalla de conexión
import 'package:url_launcher/url_launcher.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isDiscovering = false;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStream;

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

    _discoveryStream =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        _devicesList.add(r);
      });
    }, onDone: () {
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

  void _stopDiscovery() {
    if (_discoveryStream != null) {
      _discoveryStream!.cancel(); // Cancelar el stream de descubrimiento
      setState(() {
        _isDiscovering = false;
        _devicesList.clear(); // Limpiar la lista de dispositivos si es necesario
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectionScreen(device: device),
      ),
    );
  }

  Future<void> _launchURL() async {
    const String url = 'https://github.com/thiagourbizu/Eco-Metry';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Fondo azul oscuro
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _launchURL();
          },
          child: Text(
            'Eco-Metry',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202), // Color de fondo del AppBar
        actions: [
          Row(
            children: [
              // Cuadrado blanco para detener la búsqueda
              Container(
                child: IconButton(
                  icon: Icon(_isDiscovering ? Icons.stop : Icons.play_arrow,
                      color: Colors.white),
                  onPressed: () {
                    if (_isDiscovering) {
                      _stopDiscovery();
                    } else {
                      _startDiscovery();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
              // Indicador de carga o botón de actualización
              if (_isDiscovering)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 23.0, // Ajusta el tamaño según tus necesidades
                    height: 23.0, // Ajusta el tamaño según tus necesidades
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: _startDiscovery,
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _devicesList.isEmpty
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _launchURL(); // Abre el enlace al ser presionado
              },
              child: Text("Abrir GitHub"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700], // Color de fondo
                foregroundColor: Colors.white, // Color del texto
              ),
            ),
          ),
        ],
      ),
    );
  }
}
