import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'connection_screen.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'settings_manager.dart'; // Asegúrate de importar tu clase SettingsManager
import 'credits_screen.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isDiscovering = false;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStream;
  bool isTemperatureEnabled = true;
  bool isHumidityEnabled = true;
  bool isVoltageEnabled = true;
  bool isCurrentEnabled = true;
  bool isRPMEnabled = true;
  bool isSpeedEnabled = true;
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
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      String? deviceName = result.device.name;
      if (deviceName != null && deviceName.contains('Eco')) {
        setState(() {
          if (!_devicesList.any(
              (element) => element.device.address == result.device.address)) {
            _devicesList.add(result);
          }
        });
      }
    }, onDone: () {
      setState(() {
        _isDiscovering = false;
      });

      if (_devicesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se encontraron dispositivos Eco-Metry")),
        );
      }
    });
  }

  void _stopDiscovery() {
    if (_discoveryStream != null) {
      _discoveryStream!.cancel();
      setState(() {
        _isDiscovering = false;
        _devicesList.clear();
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

  Future<void> _openGitHub() async {
    final url = 'https://github.com/thiagourbizu/Eco-Metry';
    try {
      await FlutterWebBrowser.openWebPage(url: url);
    } catch (e) {
      print('Error al abrir la URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreditsScreen()), // Navegar a la pantalla de créditos
            );
          },
          child: Text(
            'Eco-Metry',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        actions: [
          Row(
            children: [
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
              if (_isDiscovering)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 23.0,
                    height: 23.0,
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
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _devicesList.length,
                    itemBuilder: (context, index) {
                      BluetoothDiscoveryResult result = _devicesList[index];
                      return ListTile(
                        tileColor: Colors.blueGrey[900],
                        title: Text(
                          result.device.name ?? "Unknown Device",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          result.device.address.toString(),
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        trailing: Text(
                          result.rssi.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          _connectToDevice(result.device);
                        },
                      );
                    },
                  ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                onPressed: _connectToFakeDevice,
                child: Icon(
                  Icons.devices_other,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blueGrey[800],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30), // Espacio para bajar el título
              Text(
                'Eco-Metry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 100),
              Text(
                'Creditos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Configuraciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              // Switches para cada variable
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Temperatura', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isTemperatureEnabled,
                    onChanged: (value) {
                      setState(() {
                        isTemperatureEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Humedad', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isHumidityEnabled,
                    onChanged: (value) {
                      setState(() {
                        isHumidityEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tensión', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isVoltageEnabled,
                    onChanged: (value) {
                      setState(() {
                        isVoltageEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Corriente', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isCurrentEnabled,
                    onChanged: (value) {
                      setState(() {
                        isCurrentEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RPM', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isRPMEnabled,
                    onChanged: (value) {
                      setState(() {
                        isRPMEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Velocidad', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isSpeedEnabled,
                    onChanged: (value) {
                      setState(() {
                        isSpeedEnabled = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 56, 202, 228),
                  ),
                ],
              ),
              Spacer(), // Espacio para empujar el contenido hacia arriba
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showContactDialog(context);
                      },
                      child: Text('Contáctanos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon:
                          FaIcon(FontAwesomeIcons.github, color: Colors.white),
                      onPressed: _openGitHub,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _connectToFakeDevice() {
    BluetoothDevice fakeDevice = BluetoothDevice(
      name: "Dispositivo Inexistente",
      address: "00:00:00:00:00:00",
      type: BluetoothDeviceType.unknown,
      bondState: BluetoothBondState.bonded,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectionScreen(device: fakeDevice),
      ),
    );
  }
}
