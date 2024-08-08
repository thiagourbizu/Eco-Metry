#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

float velocidad = 0.0;  // Velocidad en m/s
unsigned long tiempoAnterior = 0;  // Último tiempo de lectura
float ax, ay, az;  // Aceleraciones en m/s²
float offsetAx = 0.0, offsetAy = 0.0, offsetAz = 0.0;  // Offset de aceleración
const int numCalibrations = 1000;  // Número de lecturas para la calibración

void calibrate() {
  float sumAx = 0.0, sumAy = 0.0, sumAz = 0.0;
  
  Serial.println("Iniciando calibración...");
  for (int i = 0; i < numCalibrations; i++) {
    mpu.getAcceleration(&ax, &ay, &az);
    sumAx += ax;
    sumAy += ay;
    sumAz += az;
    delay(10);  // Esperar para la próxima lectura
  }

  // Calcular los offsets promedio
  offsetAx = (sumAx / numCalibrations) / 16384.0 * 9.81;
  offsetAy = (sumAy / numCalibrations) / 16384.0 * 9.81;
  offsetAz = (sumAz / numCalibrations) / 16384.0 * 9.81 - 9.81;  // Ajustar para la gravedad

  Serial.println("Calibración completada.");
  Serial.print("Offset Ax: "); Serial.println(offsetAx);
  Serial.print("Offset Ay: "); Serial.println(offsetAy);
  Serial.print("Offset Az: "); Serial.println(offsetAz);
}

void setup() {
  Serial.begin(9600);
  Wire.begin();
  mpu.initialize();

  if (!mpu.testConnection()) {
    Serial.println("MPU6050 no se pudo conectar.");
    while (1);
  }

  calibrate();  // Calibrar el sensor
}

void loop() {
  unsigned long tiempoActual = millis();
  float deltaTiempo = (tiempoActual - tiempoAnterior) / 1000.0;  // Tiempo en segundos
  tiempoAnterior = tiempoActual;

  mpu.getAcceleration(&ax, &ay, &az);
  float aceleracionX = (ax / 16384.0 * 9.81) - offsetAx;  // Convertir a m/s² y aplicar offset
  float aceleracionY = (ay / 16384.0 * 9.81) - offsetAy;  // Convertir a m/s² y aplicar offset
  float aceleracionZ = (az / 16384.0 * 9.81) - offsetAz;  // Convertir a m/s² y aplicar offset

  // Calcular la magnitud de la aceleración
  float aceleracionTotal = sqrt(aceleracionX * aceleracionX + aceleracionY * aceleracionY + aceleracionZ * aceleracionZ);

  // Integrar la aceleración para obtener la velocidad
  velocidad += aceleracionTotal * deltaTiempo;

  // Convertir la velocidad a km/h
  float velocidadKmh = velocidad * 3.6;

  // Mostrar la velocidad en el monitor serie
  Serial.print("Velocidad: ");
  Serial.print(velocidadKmh);
  Serial.println(" km/h");

  delay(100);  // Esperar un poco antes de la siguiente lectura
}
