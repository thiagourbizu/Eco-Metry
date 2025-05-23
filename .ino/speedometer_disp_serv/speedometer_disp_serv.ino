#include <EEPROM.h>   // EEPROM library

unsigned int min_speed = 0;  // minimal speed to display on scale, km/h
unsigned int max_speed = 60; // maximum speed to display on scale, km/h

volatile unsigned long lastturn, time_press;
volatile float SPEED;
volatile float DIST;
volatile boolean eeprom_flag;
float w_length = 2.050;
boolean flag;
boolean state, button;

void setup() {
  Serial.begin(115200); 
  pinMode(GPIO9, OUTPUT);  
  attachInterrupt(GPIO9, sens, RISING);  // hall sensor interrupt
            
  DIST = (float)EEPROM.read(0) / 10.0; // remember some distance
}

void sens() {
  if (millis() - lastturn > 80) {    // simple noise cut filter (based on fact that you will not be ride your bike more than 120 km/h =)
    SPEED = w_length / ((float)(millis() - lastturn) / 1000) * 3.6;   // calculate speed
    lastturn = millis();                                              // remember time of last revolution
    DIST = DIST + w_length / 1000;                                    // calculate distance
  }
  eeprom_flag = 1;
}

void loop() {
  if ((millis() - lastturn) > 2000) {       // if there is no signal more than 2 seconds
    SPEED = 0;                              // so, speed is 0
    if (eeprom_flag) {                      // if eeprom flag is true
      EEPROM.write(0, (float)DIST * 10.0);  // write ODO in EEPROM
      eeprom_flag = 0;                      // flag down. To prevent rewritind
    }
  }
  Serial.print(SPEED);
  Serial.println(" km/h");
  if (digitalRead(8) == 1) {  // if button pressed
    DIST = 0;                 // clear distance
  }
}
