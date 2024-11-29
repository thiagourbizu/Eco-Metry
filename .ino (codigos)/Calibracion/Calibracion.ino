#include "Arduino.h"

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

}

void loop() {
  // Volts ------------------------------------
    float LecturaV = 0;
    float PromedioV = 0;
    float voltaje = 0;
    for(int i=0;i<1500000;i++)
    {
      //Serial.print(i);
      LecturaV = analogRead(1); 
      PromedioV += LecturaV;
    } 
    voltaje = PromedioV/1500000;

    Serial.println(voltaje);
}
