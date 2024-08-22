// Definición del pin del ADC
const int shuntPin = 4; // Pin ADC del ESP32 para leer el voltaje del shunt

// Configuración de parámetros del ADC
const int adcResolution = 12; // Resolución del ADC (12 bits)
const float adcMaxVoltage = 3.3; // Voltaje de referencia del ADC del ESP32

// Parámetros del shunt
const float shuntVoltagePerAmpere = 75.0 / 100.0; // mV por A
const float referenceVoltage = 75.0; // mV para 100 A

void setup() {
  Serial.begin(115200); // Iniciar comunicación serial
}

void loop() {
  // Leer valor del ADC
  int adcValue = analogRead(shuntPin);
  
  // Convertir valor del ADC a voltaje
  float voltage = (adcValue / float(pow(2, adcResolution))) * adcMaxVoltage;

  // Calcular el amperaje
  float current = (voltage * 100.0) / referenceVoltage;

  // Mostrar el voltaje y el amperaje
  Serial.print("Voltaje del shunt: ");
  Serial.print(voltage, 6); // Mostrar con 6 decimales
  Serial.print(" V, ");

  Serial.print("Amperaje: ");
  Serial.print(current, 2); // Mostrar con 2 decimales
  Serial.println(" A");
  
  // Esperar antes de la siguiente lectura
  delay(1000); // 1 segundo
}
