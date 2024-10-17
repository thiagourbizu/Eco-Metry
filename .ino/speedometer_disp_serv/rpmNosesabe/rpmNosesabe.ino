#include <EEPROM.h>   // EEPROM library
#define hallSensorPin GPIO9

volatile unsigned long lastturn, time_press;
volatile float SPEED;
volatile float RPM;
volatile float DIST;
volatile boolean eeprom_flag;

float w_length = 2.050; // Pone el diametro de la rueda
boolean flag;
boolean state, button;

void setup() {
  Serial.begin(115200); 
  pinMode(hallSensorPin, INPUT);
  
  DIST = (float)EEPROM.read(0) / 10.0; // remember some distance
}


void loop() 
{
  if(digitalRead(hallSensorPin) == HIGH)
    flag = 0;
    
  if(digitalRead(hallSensorPin) == LOW && flag == 0)
  {
    if (millis() - lastturn > 80)  // simple noise cut filter (based on fact that you will not be ride your bike more than 120 km/h =)
    {    
      unsigned long time = millis() - lastturn;
      SPEED = w_length / ((float)(millis() - lastturn) / 1000) * 3.6;// calculate speed
      lastturn = millis();
      RPM = (60.0 * 1000.0) / time;// remember time of last revolution
      DIST = DIST + w_length / 1000;// calculate distance
    }
    
    eeprom_flag = 1;
    flag = 1;
  }

  if ((millis() - lastturn) > 2000)// if there is no signal more than 2 seconds
  {       
    SPEED = 0;
    RPM = 0;
    if (eeprom_flag)// if eeprom flag is true
    {                      
      EEPROM.write(0, (float)DIST * 10.0);  // write ODO in EEPROM
      eeprom_flag = 0;// flag down. To prevent rewritind
    }
  }
  Serial.print(RPM);
  Serial.print(" ");
  Serial.print(SPEED);
  Serial.println(" km/h");
}
