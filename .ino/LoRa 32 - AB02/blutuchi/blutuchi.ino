#include <SoftwareSerial.h> // Incluimos la librería  SoftwareSerial  
SoftwareSerial  BT(0,1);
char myChar;

void setup(){
  Serial.begin(9600);
  BT.begin(9600);
  BT.println("Conexion exitosa");
}
void loop() {
  while(BT.available())
  {
    myChar=BT.read(); 
    Serial.print(myChar);
  }
  while(Serial.available())
  {
    myChar=BT.read();
    BT.print(myChar);
  }
} 