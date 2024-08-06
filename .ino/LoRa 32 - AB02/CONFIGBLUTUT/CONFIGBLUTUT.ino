#include <SoftwareSerial.h>

// Definir los pines de SoftwareSerial (RX, TX)
SoftwareSerial BTserial(0, 1); // RX, TX

void setup() {
  // Iniciar comunicación serie con el monitor serial
  Serial.begin(9600);
  
  // Iniciar comunicación con el módulo Bluetooth HC-05
  BTserial.begin(9600);
  
  delay(1000); // Esperar 1 segundo para que el módulo Bluetooth se estabilice
}

void loop() {
  // Enviar el mensaje al módulo Bluetooth HC-05
  BTserial.println("1");

  // Mostrar el mensaje enviado en el monitor serial (opcional)
  Serial.println("2");

  delay(2000); // Esperar 2 segundos antes de enviar el próximo mensaje (ajustable según sea necesario)
}
