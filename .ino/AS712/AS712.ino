float multiplier = 0.1; // Sensibilidad en Voltios/Ampere para el modelo de 5A
const int analogInPin = 0; // Pin de entrada analógica donde está conectado el sensor ACS712
float voltageOffset = 1.65; // Voltaje de salida del sensor ACS712 sin corriente (ajustable)
float variableMagica=5.856;

void setup() {
  Serial.begin(115200);
  pinMode(analogInPin, INPUT);
}

void loop() {
  int sensorValue = analogRead(analogInPin); // Leer el pin analógico
  float sensorVoltage = sensorValue * (3.3 / 4095.0); // Convertir el valor leído a voltaje (ESP32 a 3.3V y 12 bits)
  float current = (sensorVoltage - 2.235457897186279)/multiplier; // Calcular la corriente ajustando por el offset
  Serial.print("Sensor: ");
  Serial.print(sensorValue);
  Serial.print(" - ");
  Serial.print("Volt: ");
  Serial.print(sensorVoltage, 15);
  Serial.print(" - ");
  Serial.print("Current: ");
  Serial.println(current, 3); 

  // Agrega un pequeño retardo
  delay(100);  // 1 segundo de retardo entre lecturas
}
// AC712 WORKING
