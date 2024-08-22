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

  // Inicializa la generación de números aleatorios
  randomSeed(analogRead(0)); // Usa la lectura del pin analógico para inicializar la semilla aleatoria
}

void loop() {
  // Leer el valor del sensor de temperatura
  int sensorValue = analogRead(sensorPin); // Lee el valor del sensor (0-1023)
  temperatureC = sensorValue * (5.0 / 1023.0) * 100.0; // Convierte el valor a grados Celsius

  // Generar un número aleatorio entre 5 y 60 para la velocidad
  int velocidad = random(5, 61); // El límite superior es exclusivo, así que usa 61 para incluir 60

  int voltaje = 1;
  int amperaje = 2;

  // Crear la cadena para enviar
  String cadena = String(temperatureC) + "," + String(velocidad) + "," + String(voltaje) + "," + String(amperaje);

  // Mostrar la temperatura en el monitor serial
  Serial.println(cadena);

  // Enviar el dato leído a través del módulo Bluetooth
  BTSerial.println(cadena);
  
  delay(1000); // Espera 1 segundo
}
