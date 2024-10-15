import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bluetooth_app.dart';
import 'settings_manager.dart'; // Asegúrate de importar el SettingsManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inicializa Hive
  final settingsManager = SettingsManager();
  await settingsManager.init(); // Inicializa SettingsManager

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Metry',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme,
      ),
      home: BluetoothApp(),
    );
  }
}
