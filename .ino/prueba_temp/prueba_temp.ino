
void setup() {
  Serial.begin(115200);
}
void loop() {
  
  int valorAnalogico = analogRead(1);
  
  // Calcular el voltaje basado en la lectura del ADC (resolución de 12 bits)
  float voltaje = valorAnalogico * (3.3 / 4095.0);

  // Conversión a temperatura, considerando 10mV por grado Celsius
  float temperaturaCelsius = voltaje * 100.0;
  Serial.print(valorAnalogico);
  Serial.print(" | ");
  Serial.print(voltaje);
  Serial.print("V | ");
  Serial.print(temperaturaCelsius);
  Serial.println("C");
  delay(500);

  
}
