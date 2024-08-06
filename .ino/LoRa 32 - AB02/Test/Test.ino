#include <HardwareSerial.h>

//NO TOCAR NUNCA EN LA VIDA
#define RX_PIN 1
#define TX_PIN 2

HardwareSerial BTserial(1);  // UART1 Heltec AB02

void setup() {
  Serial.begin(9600);
  BTserial.begin(9600, SERIAL_8N1, RX_PIN, TX_PIN); // Serial, RX, TX
  
  delay(1000); 
}

void loop() {


  // Mostrar el mensaje enviado en el monitor serial   
  Serial.println("1");

  delay(2000); // Esperar 2 segundos antes de enviar el próximo mensaje (ajustable según sea necesario)
}
