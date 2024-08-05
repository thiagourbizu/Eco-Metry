import 'package:flutter/material.dart';
import 'bluetooth_app.dart'; // Importar la aplicación Bluetooth

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Metry',
      home: BluetoothApp(),
    );
  }
}
