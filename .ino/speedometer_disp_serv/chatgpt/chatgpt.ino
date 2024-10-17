#include <EEPROM.h>   // EEPROM library

unsigned int min_speed = 0;  // minimal speed to display on scale, km/h
unsigned int max_speed = 60; // maximum speed to display on scale, km/h



volatile unsigned long lastturn;
volatile float SPEED;
volatile float DIST;
volatile boolean eeprom_flag;
float w_length = 2.050;      // Variable en metros
float RPM;                   // Variable para almacenar las RPM
boolean flag;
boolean state, button;

void setup() {
  Serial.begin(115200);                // configure serial for debug
  pinMode(3, OUTPUT);                // D3 as power source
  digitalWrite(3, HIGH);
  pinMode(8, INPUT);                 // some button pin

  DIST = (float)EEPROM.read(0) / 10.0; // remember some distance
}

void loop() 
{
 
  
  Serial.println(digitalRead(GPIO9));
  if( digitalRead(GPIO9) == LOW)
  {
    if (millis() - lastturn > 80) 
    {                                             // simple noise cut filter (to limit noise)
      unsigned long time = millis() - lastturn;   // Tiempo entre las dos últimas vueltas
      SPEED = w_length / ((float)time / 1000) * 3.6;   // Calcular velocidad en km/h
      RPM = (60.0 * 1000.0) / time;               // Calcular RPM basadas en el tiempo entre vueltas
      lastturn = millis();                        // Recordar el tiempo de la última vuelta
      DIST = DIST + w_length / 1000;              // Calcular la distancia recorrida
    }
    eeprom_flag = 1;
  }
  
  Serial.print("Velocidad: ");
  Serial.print(SPEED);
  Serial.print(" km/h");
  Serial.print("   ");
  Serial.print("RPM: ");
  Serial.println(RPM);     // Imprimir las RPM calculadas

  if ((millis() - lastturn) > 2000) {       // Si no hay señal por más de 2 segundos
    SPEED = 0;                              // Entonces, la velocidad es 0
    RPM = 0;                                // También, las RPM son 0
    if (eeprom_flag) {                      // Si la bandera de EEPROM está activada
      EEPROM.write(0, (float)DIST * 10.0);  // Guardar la distancia en la EEPROM
      eeprom_flag = 0;                      // Bajar la bandera para evitar reescritura
    }
  }
  if (digitalRead(8) == 1) 
  {  // Si el botón está presionado
    DIST = 0;                 // Borrar la distancia
  }
}
