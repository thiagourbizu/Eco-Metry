import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bluetooth_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inicializa Hive

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Metry',
      theme: ThemeData(
        // No se especifica una fuente personalizada
        textTheme: Theme.of(context).textTheme,
        // Asegúrate de que no haya otras configuraciones de fuente aquí
      ),
      home: BluetoothApp(),
    );
  }
}
