#include <SoftwareSerial.h>

// Configuración del módulo Bluetooth
int bluRX = 3;
int bluTX = 2;
SoftwareSerial BTSerial(bluRX, bluTX); // RX, TX

// Pin del sensor de temperatura LM35
const int sensorPin = A5;
float temperatureC;

void setup() {
  // Inicia la comunicación serie con el PC
  Serial.begin(115200);
  
  // Inicia la comunicación serie con el módulo Bluetooth HC-05
  BTSerial.begin(115200); // Velocidad de comunicación para datos normales
}

void loop() {
  // Leer el valor del sensor de temperatura
  int sensorValue = analogRead(sensorPin); // Lee el valor del sensor (0-1023)
  temperatureC = sensorValue * (5.0 / 1023.0) * 100.0; // Convierte el valor a grados Celsius
  int hola = 100;
  //int roundedTempC = round(temperatureC);

  // También mostrar la temperatura en el monitor serial
 // Serial.println(temperatureC,hola);
  String cadena = String(temperatureC) + "," + String(hola);
  // Enviar el dato leído a través del módulo Bluetooth
  Serial.println(cadena);
  
  BTSerial.print(cadena);
  delay(1000);
  
}

  //Leer datos del monitor serial y enviarlos a través de Bluetooth
  //if (Serial.available()) {
  //  char dato = Serial.read();
  //  BTSerial.write(dato);
  //}
