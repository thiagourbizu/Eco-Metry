#include "Arduino.h"

// Configuración del puerto serie
#define BT_BAUD_RATE 9600 // Velocidad de comunicación con HC-05
#define DELAY_MS 100     // Retraso entre transmisiones (milisegundos)

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

  // También mostrar la temperatura en el monitor serial
 // Serial.println(temperatureC,hola);
  String cadena = String(temperatureC) + "," + String(velocidad) + "," +  String(voltaje) + "," + String(amperaje);
  // Enviar el dato leído a través del módulo Bluetooth
  Serial.println(cadena);

  BTserial.print(cadena);
    // Esperar un segundo antes de enviar el siguiente paquete
  delay(DELAY_MS);
}

