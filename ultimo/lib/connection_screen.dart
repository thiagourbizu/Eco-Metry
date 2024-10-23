import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'data_screen.dart'; // Importar la nueva pantalla de datos
import 'charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
import 'settings_manager.dart';
import 'settings_screen.dart';
//import 'package:kdgaugeview/kdgaugeview.dart';

Color bordeA = Colors.grey;
Color bordeT = Colors.grey;
Color bordeVel = Colors.grey;
Color bordeVolt = Colors.grey;

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  ConnectionScreen({required this.device});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothConnection? connection;
  List<double> temperatureData = [];
  List<double> speedData = [];
  List<double> voltageData = [];
  List<double> currentData = [];
  List<double> rpmData = [];
  List<double> humidityData = [];
  List<String> receivedLines = [];
  bool isConnecting = true;
  double currentTemperature = 0.0;
  double currentSpeed = 0.0;
  double currentVoltage = 0.0;
  double currentCurrent = 0.0;
  double currentRPM = 0.0;
  double currentHumedad = 0.0;
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _voltageController = TextEditingController();
  final TextEditingController _amperageController = TextEditingController();
  final StreamController<List<String>> _streamController =
      StreamController<List<String>>.broadcast();

  Timer? _updateTimer;

  @override
   void initState() {
    super.initState();
    _connectToDevice();
    _startSpeedometerUpdate();
    _loadSettings(); // Iniciar actualización del velocímetro
  }
  //Clases para el drawer
Future<void> _loadSettings() async {
  final settings = SettingsManager();
  await settings.init(); // Asegúrate de inicializar

  setState(() {
    // Inicializa en 0 si no hay configuración guardada
    _temperatureController.text = settings.temperatureMax.isNotEmpty ? settings.temperatureMax : '0';
    _humidityController.text = settings.humidityMax.isNotEmpty ? settings.humidityMax : '0';
    _voltageController.text = settings.voltageMax.isNotEmpty ? settings.voltageMax : '0';
    _amperageController.text = settings.amperageMax.isNotEmpty ? settings.amperageMax : '0';
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

  void _updateValue(TextEditingController controller, int delta) {
    final currentValue = int.tryParse(controller.text) ?? 0;
    final newValue = (currentValue + delta).clamp(0, double.infinity).toInt();
    controller.text = newValue.toString();
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              TextStyle(color: Colors.white, fontSize: 14), // Tamaño del texto
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Reducir el tamaño del TextField
            Expanded(
              child: SizedBox(
                height: 60, // Ajusta la altura según sea necesario
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    suffixText: suffix,
                    filled: true,
                    fillColor: Colors.blueGrey[600],
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10.0), // Ajusta el padding
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            // Reducir el tamaño de los iconos y ajustar espaciado
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward, color: Colors.white),
                  iconSize: 16, // Tamaño del ícono reducido
                  padding: EdgeInsets.all(4.0), // Ajustar padding del botón
                  onPressed: () => _updateValue(controller, 1),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward, color: Colors.white),
                  iconSize: 16, // Tamaño del ícono reducido
                  padding: EdgeInsets.all(4.0), // Ajustar padding del botón
                  onPressed: () => _updateValue(controller, -1),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataContainer(
    String label,
    String value,
    String unit,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      //onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
        String valueString = String.fromCharCodes(data).trim();
        List<String> values = valueString.split(',');

        // Depuración
        print('Datos recibidos: $valueString');

        setState(() {
          if (receivedLines.length >= 25) {
            receivedLines.removeAt(0);
          }
          receivedLines.add(valueString);

          _streamController.add(receivedLines);

          if (values.length == 6) {
            double tempValue = double.tryParse(values[0]) ?? 0.0;
            double humedadValue = double.tryParse(values[1]) ?? 0.0;
            double rpmValue = double.tryParse(values[2]) ?? 0.0;
            double voltageValue = double.tryParse(values[3]) ?? 0.0;
            double currentValue = double.tryParse(values[4]) ?? 0.0;
            double speedValue = double.tryParse(values[5]) ?? 0.0;

            currentTemperature = tempValue;
            currentSpeed = speedValue;
            currentVoltage = voltageValue;
            currentCurrent = currentValue;
            currentRPM = rpmValue;
            currentHumedad = humedadValue;

            // Almacenar los últimos 30 datos
            if (temperatureData.length >= 50) {
              temperatureData.removeAt(0);
            }
            temperatureData.add(currentTemperature);

            if (speedData.length >= 40) {
              speedData.removeAt(0);
            }
            speedData.add(currentSpeed);

            if (voltageData.length >= 40) {
              voltageData.removeAt(0);
            }
            voltageData.add(currentVoltage);

            if (currentData.length >= 40) {
              currentData.removeAt(0);
            }
            currentData.add(currentCurrent);

            if (rpmData.length >= 40) {
              rpmData.removeAt(0);
            }
            rpmData.add(currentRPM);

            if (humidityData.length >= 40) {
              humidityData.removeAt(0);
            }
            humidityData.add(currentHumedad);
          }
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

  void _startSpeedometerUpdate() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        // Forzar la actualización del velocímetro
      });
    });
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
    _streamController
        .close(); // Cerrar el StreamController al deshacerse del widget
    _updateTimer?.cancel(); // Cancelar el temporizador al deshacerse del widget
    super.dispose();
  }

  void _navigateToChart(String chartType) {
    List<double> dataToPass;
    switch (chartType) {
      case 'temperature':
        dataToPass = List.from(temperatureData);
        break;
      case 'humidity':
        dataToPass = List.from(humidityData);
      case 'voltage':
        dataToPass = List.from(voltageData);
        break;
      case 'current':
        dataToPass = List.from(currentData);
        break;
      case 'rpm':
        dataToPass = List.from(rpmData);
        break;
      case 'speed':
        dataToPass = List.from(speedData);
        break;
      default:
        dataToPass = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartsScreen(
          data: dataToPass,
          chartType: chartType,
        ),
      ),
    );
  }

  void _navigateToDataScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataScreen(stream: _streamController.stream),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    Color colorT =
        double.parse(SettingsManager().temperatureMax) <= currentTemperature
            ? const Color.fromARGB(
                255, 167, 35, 26) // Red if current temperature exceeds max
            : const Color.fromARGB(255, 26, 60, 79); // Default color

    Color colorH = double.parse(SettingsManager().humidityMax) <= currentHumedad
        ? const Color.fromARGB(
            255, 167, 35, 26) // Red if current temperature exceeds max
        : const Color.fromARGB(255, 26, 60, 79); // Default color

    Color colorV = double.parse(SettingsManager().voltageMax) <= currentVoltage
        ? const Color.fromARGB(
            255, 167, 35, 26) // Red if current temperature exceeds max
        : const Color.fromARGB(255, 26, 60, 79); // Default color

    Color colorA = double.parse(SettingsManager().amperageMax) <= currentCurrent
        ? const Color.fromARGB(
            255, 167, 35, 26) // Red if current temperature exceeds max
        : const Color.fromARGB(255, 26, 60, 79); // Default color

    Color colorRPM = currentSpeed <= 5
        ? const Color.fromARGB(255, 26, 60,
            79) // Color predeterminado si la velocidad es <= 5 km/h
        : currentSpeed <= 20
            ? const Color.fromARGB(
                255, 0, 255, 0) // Verde si la velocidad es > 5 y <= 20 km/h
            : currentSpeed <= 40
                ? const Color.fromARGB(255, 255, 165,
                    0) // Naranja si la velocidad es > 20 y <= 40 km/h
                : const Color.fromARGB(
                    255, 167, 35, 26); // Rojo si la velocidad es > 40 km/h

    if (orientation == Orientation.landscape) {
      // Modo horizontal
      return Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 161, 202),
          title: Text(
            'Tablero',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Icon(
                Icons.settings, // Ícono de engranaje
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 79, 104),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        body: Center(
          child: Row(
            children: [
              // Nuevo velocímetro a la izquierda con margen izquierdo
              Padding(
                padding: const EdgeInsets.only(
                    left: 60.0, top: 15.0), // Margen izquierdo
                child: Container(
                  width: 250, // Tamaño del velocímetro
                  height: 250, // Tamaño del velocímetro
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.0, end: currentSpeed),
                    duration: const Duration(
                        milliseconds: 100), // Duración de la animación
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Center(
                        child: Stack(
                          children: [
                            // Fondo redondeado detrás del velocímetro
                            Container(
                              width: 310,
                              height: 310,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    155), // Radio de borde redondeado
                                border: Border.all(
                                  width: 20, // Grosor del borde
                                  color: Colors.black
                                      .withOpacity(0.3), // Color del borde
                                ),
                              ),
                            ),
                            SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                  minimum: 0,
                                  maximum:
                                      60.2, // Ajustado para un máximo de 60 km/h
                                  ranges: <GaugeRange>[
                                    // Color verde
                                    GaugeRange(
                                      startValue: 0,
                                      endValue: value < 20 ? value : 20,
                                      color: Colors.green,
                                      startWidth: 20,
                                      endWidth: 20,
                                    ),
                                    // Color naranja
                                    GaugeRange(
                                      startValue: 21,
                                      endValue: value < 40 ? value : 40,
                                      color: Colors.orange,
                                      startWidth: 20,
                                      endWidth: 20,
                                    ),
                                    // Color rojo
                                    GaugeRange(
                                      startValue: 41,
                                      endValue: value < 60 ? value : 60,
                                      color: Colors.red,
                                      startWidth: 20,
                                      endWidth: 20,
                                    ),
                                    GaugeRange(
                                      startValue: 70,
                                      endValue: value < 70 ? value : 70,
                                      color:
                                          const Color.fromARGB(255, 85, 85, 85),
                                      startWidth: 20,
                                      endWidth: 20,
                                    )
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(value: value),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      widget: Padding(
                                        padding: const EdgeInsets.only(
                                            top:
                                                50.0), // Ajusta la posición hacia abajo
                                        child: Text(
                                          'km/h',
                                          style: TextStyle(
                                            fontSize:
                                                20, // Tamaño de fuente para "km/h"
                                            fontWeight: FontWeight
                                                .bold, // Velocidad en negrita
                                            color:
                                                Colors.white, // Color del texto
                                          ),
                                        ),
                                      ),
                                      angle: 90,
                                      positionFactor: 0.5,
                                    ),
                                  ],
                                  axisLabelStyle: GaugeTextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        20, // Tamaño de fuente agrandado para las etiquetas
                                  ),
                                  majorTickStyle: MajorTickStyle(
                                    length: 15,
                                    thickness: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              //SizedBox(width: 155),
              // Column of remaining boxes
              // Reubicar los cuadros en modo horizontal
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDataContainer(
                          'RPM',
                          currentRPM.toStringAsFixed(2),
                          '',
                          colorRPM,
                          () => _navigateToChart('rpm'),
                        ),
                        SizedBox(
                          width: 22,
                        ),
                        _buildDataContainer(
                          'Temperatura',
                          currentTemperature.toStringAsFixed(2),
                          'ºC',
                          colorT,
                          () => _navigateToChart('temperature'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDataContainer(
                          'Tensión',
                          currentVoltage.toStringAsFixed(2),
                          'V',
                          colorV,
                          () => _navigateToChart('voltage'),
                        ),
                        SizedBox(
                          width: 22,
                        ),
                        _buildDataContainer(
                          'Corriente',
                          currentCurrent.toStringAsFixed(2),
                          'A',
                          colorA,
                          () => _navigateToChart('current'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Modo vertical
      return Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 161, 202),
          title: Text(
            'Gráfico',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                Icons.insert_chart,
                color: Colors.white,
              ),
              onPressed:
                  _navigateToDataScreen, // Navegar a la pantalla de datos
            ),
            Builder(
              // Usamos Builder para obtener el contexto correcto
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu), // Ícono de hamburguesa
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer(); // Abre el EndDrawer
                  },
                );
              },
            )
          ],
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
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('temperature'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorT,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Temperatura',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentTemperature.toStringAsFixed(1)} °C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('humidity'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorH,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Humedad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentHumedad.toStringAsFixed(0)} %',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
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
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('voltage'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorV,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tensión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentVoltage.toStringAsFixed(1)} V',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('current'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorA,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Corriente',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentCurrent.toStringAsFixed(1)} A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
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
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('speed'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorRPM,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Velocidad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentSpeed.toStringAsFixed(0)} km/h',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () => _navigateToChart('rpm'),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorRPM,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'RPM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${currentRPM.toStringAsFixed(0)} ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
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
            ],
          ),
        ),
        endDrawer: Drawer(
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
                SizedBox(height: 5),
                Text(
                  'Configuraciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 1), // Espacio adicional para bajar los campos
                _buildInputField(
                  label: 'Temperatura Máxima',
                  controller: _temperatureController,
                  suffix: '°C',
                ),
                SizedBox(height: 2),
                _buildInputField(
                  label: 'Humedad Máxima',
                  controller: _humidityController,
                  suffix: '%',
                ),
                SizedBox(height: 6),
                _buildInputField(
                  label: 'Tensión Máximo',
                  controller: _voltageController,
                  suffix: 'V',
                ),
                SizedBox(height: 6),
                _buildInputField(
                  label: 'Corriente Máximo',
                  controller: _amperageController,
                  suffix: 'A',
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: Icon(Icons.save), // Icono de guardado
                  label: Text('Guardar Configuraciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
