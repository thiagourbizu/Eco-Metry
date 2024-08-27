import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Asegúrate de importar esto
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _voltageController = TextEditingController();
  final TextEditingController _amperageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      var box = await Hive.openBox('settings');
      setState(() {
        _temperatureController.text = box.get('temperature_max', defaultValue: '0');
        _speedController.text = box.get('speed_max', defaultValue: '0');
        _voltageController.text = box.get('voltage_max', defaultValue: '0');
        _amperageController.text = box.get('amperage_max', defaultValue: '0');
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      var box = await Hive.openBox('settings');
      await box.put('temperature_max', _temperatureController.text);
      await box.put('speed_max', _speedController.text);
      await box.put('voltage_max', _voltageController.text);
      await box.put('amperage_max', _amperageController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración guardada!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        title: Text('Configuración', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Cambia el color aquí
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveSettings,
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildInputField(
              label: 'Temperatura Máxima',
              controller: _temperatureController,
              suffix: '°C',
            ),
            SizedBox(height: 16),
            _buildInputField(
              label: 'Velocidad Máxima',
              controller: _speedController,
              suffix: 'km/h',
            ),
            SizedBox(height: 16),
            _buildInputField(
              label: 'Voltaje Máximo',
              controller: _voltageController,
              suffix: 'V',
            ),
            SizedBox(height: 16),
            _buildInputField(
              label: 'Amperaje Máximo',
              controller: _amperageController,
              suffix: 'A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String suffix}) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white),
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent), // Borde normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 185, 15, 15), width: 2.0), // Borde cuando está enfocado
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    suffixText: suffix,
                    suffixStyle: TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (value) {
                    final intValue = int.tryParse(value) ?? 0;
                    if (intValue < 0) {
                      controller.text = '0';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () {
                  _updateValue(controller, 1);
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                onPressed: () {
                  _updateValue(controller, -1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateValue(TextEditingController controller, int delta) {
    final currentValue = int.tryParse(controller.text) ?? 0;
    final newValue = (currentValue + delta).clamp(0, double.infinity).toInt();
    controller.text = newValue.toString();
  }
}
