

// Configuración del módulo Bluetooth
HardwareSerial BTSerial(1);

// Pin del sensor de temperatura LM35
const int sensorPin = 2;
float temperatureC;

// Variable para la velocidad
int velocidad = 0;

void setup() {
  // Inicia la comunicación serie con el PC
  Serial.begin(115200);
  
  // Inicia la comunicación serie con el módulo Bluetooth HC-05
  BTSerial.begin(115200); // Velocidad de comunicación para datos normales

}

void loop() {
  // Leer el valor del sensor de temperatura
  int sensorValue = analogRead(sensorPin); // Lee el valor del sensor (0-1023)
  float lectura = sensorValue * (3.3 / 4095.0); // Convierte el valor a grados Celsius
  float R1 = 18600000; // resistencia R1 en ohmios
  float R2 = 1000000;  // resistencia R2 en ohmios
  
  float Voltaje = lectura * (R1 + R2) / R2; // fórmula inversa para obtener Vin
 
  // Incrementar la velocidad y reiniciar a 0 si llega a 60
  velocidad++;
  if (velocidad >= 60) {
    velocidad = 0;
  }

  // Asignar valores fijos para voltaje y amperaje
  int amperaje = 2;

  // Crear la cadena para enviar
  String cadena = String(lectura) + "," + String(velocidad) + "," + String(Voltaje) + "," + String(amperaje);

  // Mostrar la temperatura en el monitor serial
  Serial.println(cadena);

  // Enviar el dato leído a través del módulo Bluetooth
  BTSerial.println(cadena);
  
  delay(100); // Espera 100 milisegundos
}
