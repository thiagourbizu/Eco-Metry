const int sensorPin = 1; // Pin donde está conectado el ACS712
const float referenceVoltage = 3.3; // Voltaje de referencia del ESP32
const float offsetVoltage = referenceVoltage / 2; // Voltaje de referencia del sensor (1.65V)
const float sensitivity = 0.1; // Sensibilidad del ACS712-20A en V/A (100 mV/A)

void setup() {
  Serial.begin(115200); // Inicia la comunicación serial a 115200 baudios
}

void loop() {
  int sensorValue = analogRead(sensorPin); // Leer el valor analógico
  int invertedValue = 4095 - sensorValue;  // Invertir el valor leído
  
  // Convertir el valor invertido a voltios
  float voltage = (invertedValue / 4095.0) * referenceVoltage;
  
  // Calcular el amperaje
  float current = (voltage - offsetVoltage) / sensitivity;

  // Muestra los valores en el monitor serial
  Serial.print("Valor leído: ");
  Serial.print(sensorValue);
  Serial.print(" | Valor invertido: ");
  Serial.print(invertedValue);
  Serial.print(" | Voltaje: ");
  Serial.print(voltage, 3); // Muestra el voltaje con 3 decimales
  Serial.print(" V | Corriente: ");
  Serial.print(current, 3); // Muestra la corriente con 3 decimales
  Serial.println(" A");

  delay(1000); // Espera un segundo antes de la siguiente lectura
}
