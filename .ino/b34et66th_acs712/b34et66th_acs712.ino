#include "Arduino.h"

// Configuración del puerto serie
#define BT_BAUD_RATE 115200 // Velocidad de comunicación con HC-05
#define DELAY_MS 100     // Retraso entre transmisiones (milisegundos)

float multiplier = 0.1; // Sensibilidad en Voltios/Ampere para el modelo de 5A
const int analogInPin = 0; // Pin de entrada analógica donde está conectado el sensor ACS712
float voltageOffset = 1.65; // Voltaje de salida del sensor ACS712 sin corriente (ajustable)

HardwareSerial BTserial(1); // UART1 para el HC-05

void setup() {
    // Inicializa el puerto serie principal para depuración
    Serial.begin(115200);
    
    // Inicializa el puerto serie para la comunicación con el HC-05
    BTserial.begin(BT_BAUD_RATE);
}

void loop() {
  // Leer el valor del sensor de temperatura
  //int sensorValue = analogRead(sensorPin); // Lee el valor del sensor (0-1023)
  //temperatureC = sensorValue * (5.0 / 1023.0) * 100.0; // Convierte el valor a grados Celsius
  int temperatureC = 100;
  int velocidad = 100;
  int voltaje = 1;
  int amperaje = 2;
  //int roundedTempC = round(temperatureC);
  int sensorValue = analogRead(analogInPin); // Leer el pin analógico
  float sensorVoltage = sensorValue * (3.3 / 4095.0); // Convertir el valor leído a voltaje (ESP32 a 3.3V y 12 bits)
  float current = (sensorVoltage - 2.235457897186279)/multiplier; // Calcular la corriente ajustando por el offset
  // También mostrar la temperatura en el monitor serial
 // Serial.println(temperatureC,hola);
  String cadena = String(temperatureC) + "," + String(velocidad) + "," +  String(voltaje) + "," + String(current);
  // Enviar el dato leído a través del módulo Bluetooth
  Serial.println(cadena);
  BTserial.print(cadena);
    // Esperar un segundo antes de enviar el siguiente paquete
  delay(DELAY_MS);
}
