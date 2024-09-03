import 'package:hive/hive.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  Box? _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  String get temperatureMax => _settingsBox?.get('temperature_max', defaultValue: '0') ?? '0';
  String get speedMax => _settingsBox?.get('speed_max', defaultValue: '0') ?? '0';
  String get voltageMax => _settingsBox?.get('voltage_max', defaultValue: '0') ?? '0';
  String get amperageMax => _settingsBox?.get('amperage_max', defaultValue: '0') ?? '0';

  Future<void> setTemperatureMax(String value) async {
    await _settingsBox?.put('temperature_max', value);
  }

  Future<void> setSpeedMax(String value) async {
    await _settingsBox?.put('speed_max', value);
  }

  Future<void> setVoltageMax(String value) async {
    await _settingsBox?.put('voltage_max', value);
  }

  Future<void> setAmperageMax(String value) async {
    await _settingsBox?.put('amperage_max', value);
  }
}
