import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsManager with ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  Box? _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  // Getters para las configuraciones
  bool get isTemperatureEnabled => _settingsBox?.get('temperature_enabled', defaultValue: true) ?? true;
  bool get isHumidityEnabled => _settingsBox?.get('humidity_enabled', defaultValue: true) ?? true;
  bool get isVoltageEnabled => _settingsBox?.get('voltage_enabled', defaultValue: true) ?? true;
  bool get isCurrentEnabled => _settingsBox?.get('current_enabled', defaultValue: true) ?? true;
  bool get isRPMEnabled => _settingsBox?.get('rpm_enabled', defaultValue: true) ?? true;
  bool get isSpeedEnabled => _settingsBox?.get('speed_enabled', defaultValue: true) ?? true;

  // Métodos para establecer valores
  Future<void> setTemperatureEnabled(bool value) async {
    await _settingsBox?.put('temperature_enabled', value);
    notifyListeners();
  }

  Future<void> setHumidityEnabled(bool value) async {
    await _settingsBox?.put('humidity_enabled', value);
    notifyListeners();
  }

  Future<void> setVoltageEnabled(bool value) async {
    await _settingsBox?.put('voltage_enabled', value);
    notifyListeners();
  }

  Future<void> setCurrentEnabled(bool value) async {
    await _settingsBox?.put('current_enabled', value);
    notifyListeners();
  }

  Future<void> setRPMEnabled(bool value) async {
    await _settingsBox?.put('rpm_enabled', value);
    notifyListeners();
  }

  Future<void> setSpeedEnabled(bool value) async {
    await _settingsBox?.put('speed_enabled', value);
    notifyListeners();
  }
  // Getters para las configuraciones existentes
  String get temperatureMax => _settingsBox?.get('temperature_max', defaultValue: '0') ?? '0';
  String get humidityMax => _settingsBox?.get('humidity_max', defaultValue: '0') ?? '0';
  String get voltageMax => _settingsBox?.get('voltage_max', defaultValue: '0') ?? '0';
  String get amperageMax => _settingsBox?.get('amperage_max', defaultValue: '0') ?? '0';

  // Métodos para establecer valores en las configuraciones existentes
  Future<void> setTemperatureMax(String value) async {
    await _settingsBox?.put('temperature_max', value);
  }

  Future<void> setHumidityMax(String value) async {
    await _settingsBox?.put('humidity_max', value);
  }

  Future<void> setVoltageMax(String value) async {
    await _settingsBox?.put('voltage_max', value);
  }

  Future<void> setAmperageMax(String value) async {
    await _settingsBox?.put('amperage_max', value);
  }

}
