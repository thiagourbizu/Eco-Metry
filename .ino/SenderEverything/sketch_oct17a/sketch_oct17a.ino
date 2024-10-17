#include <EEPROM.h>   // EEPROM library

#define hallSensorPin GPIO9
#define noise_filter_time 80  // Tiempo mínimo entre pulsos (80 ms)

unsigned int min_speed = 0;  // velocidad mínima en km/h
unsigned int max_speed = 60; // velocidad máxima en km/h

unsigned long lastturn = 0;
unsigned long currentMillis = 0;
volatile float SPEED = 0;
volatile float DIST = 0;
volatile boolean eeprom_flag = false;
float w_length = 3.1416;  // Longitud de la circunferencia de la rueda (en metros)
float RPM = 0;            // Variable para almacenar las RPM
boolean sensorState = LOW; // Estado del sensor Hall
boolean lastSensorState = LOW; // Estado anterior del sensor Hall

void setup() {
  Serial.begin(115200);                // Configurar serial para depuración
  pinMode(GPIO9, INPUT);               // Pin GPIO9 para el sensor Hall
  pinMode(8, INPUT);                   // Pin para el botón

  DIST = (float)EEPROM.read(0) / 10.0; // Recordar la distancia almacenada en EEPROM
}

void loop() {
  currentMillis = millis();                // Obtener el tiempo actual
  sensorState = digitalRead(GPIO9);         // Leer el estado del sensor Hall en GPIO9

  // Detectar cuando el sensor cambia de estado (borde de subida)
  if (sensorState == LOW && lastSensorState == HIGH) {
    // Asegurarse de que el tiempo transcurrido desde la última detección sea mayor que el filtro de ruido
    if (currentMillis - lastturn > noise_filter_time) {
      unsigned long time = currentMillis - lastturn;  // Tiempo entre las dos últimas vueltas
      SPEED = w_length / ((float)time / 1000) * 3.6;  // Calcular velocidad en km/h
      RPM = (60.0 * 1000.0) / time;                   // Calcular RPM
      lastturn = currentMillis;                       // Recordar el tiempo de la última vuelta
      DIST = DIST + w_length / 1000;                  // Calcular la distancia recorrida
      eeprom_flag = true;                             // Marcar para escribir en EEPROM
    }
  }

  lastSensorState = sensorState;  // Actualizar el estado anterior del sensor

  // Si no se detecta ninguna vuelta en 2 segundos
  if ((currentMillis - lastturn) > 2000) {
    SPEED = 0;  // La velocidad es 0
    RPM = 0;    // Las RPM son 0
    if (eeprom_flag) {
      EEPROM.write(0, (float)DIST * 10.0);  // Escribir la distancia en EEPROM
      eeprom_flag = false;                  // Restablecer la bandera de EEPROM
    }
  }

  // Imprimir velocidad y RPM en el monitor serial
  Serial.print("Velocidad: ");
  Serial.print(SPEED);
  Serial.println(" km/h");

  Serial.print("RPM: ");
  Serial.println(RPM);

  // Si el botón está presionado, reiniciar la distancia
  if (digitalRead(8) == HIGH) {
    DIST = 0;  // Reiniciar distancia
  }

}
