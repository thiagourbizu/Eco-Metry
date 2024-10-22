  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  //import 'package:hive/hive.dart';
  import 'settings_manager.dart'; // Asegúrate de importar tu clase SettingsManager

  class SettingsScreen extends StatefulWidget {
    @override
    _SettingsScreenState createState() => _SettingsScreenState();
  }

  class _SettingsScreenState extends State<SettingsScreen> {
    final TextEditingController _temperatureController = TextEditingController();
    final TextEditingController _humidityController = TextEditingController();
    final TextEditingController _voltageController = TextEditingController();
    final TextEditingController _amperageController = TextEditingController();

    @override
    void initState() {
      super.initState();
      _loadSettings();
    }

    Future<void> _loadSettings() async {
      final settings = SettingsManager();
      await settings.init(); // Asegúrate de inicializar
      setState(() {
        _temperatureController.text = settings.temperatureMax;
        _humidityController.text = settings.humidityMax;
        _voltageController.text = settings.voltageMax;
        _amperageController.text = settings.amperageMax;
      });
    }

    Future<void> _saveSettings() async {
      try {
        final settings = SettingsManager();
        await settings.setTemperatureMax(_temperatureController.text);
        await settings.setHumidityMax(_humidityController.text);
        await settings.setVoltageMax(_voltageController.text);
        await settings.setAmperageMax(_amperageController.text);

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
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
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
                label: 'Humedad Máxima',
                controller: _humidityController,
                suffix: '%',
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
              style: TextStyle(color: Colors.white),
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
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 185, 15, 15), width: 2.0),
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
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
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
