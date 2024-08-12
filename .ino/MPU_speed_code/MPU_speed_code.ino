<<<<<<< HEAD
#include "MPU6050.h"
#include "Wire.h"
#include "I2Cdev.h"
#include <SoftwareSerial.h>

const float CONST_16G = 2048;
const float CONST_2000 = 16.4;
const float CONST_G = 9.81;
const float RADIANS_TO_DEGREES = 180 / 3.14159;
const float ALPHA = 0.96;
const float KMPH = 3.6;

MPU6050 accelgyro;

unsigned long last_read_time;
int16_t ax, ay, az, gx, gy, gz;
int16_t gyro_angle_x_l, gyro_angle_y_l;
int16_t angle_x_l, angle_y_l;
int16_t ax_offset, ay_offset, az_offset, gx_offset, gy_offset, gz_offset;
int16_t temperature;

void setup() {
  Wire.begin();
  Serial.begin(9600);

  Serial.println("Bluetooth Connected");

  // initialize device
  Serial.println("Initializing I2C devices...");
  accelgyro.initialize();

  Serial.println("Testing device connections...");
  Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

  accelgyro.setFullScaleAccelRange(0x03);
  accelgyro.setFullScaleGyroRange(0x03);

  calibrate_sensors();
  set_last_time(millis());
}

void loop() {
  unsigned long t_now = millis();
  float dt = get_delta_time(t_now);
  accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  float ax_p = (ax - ax_offset) / CONST_16G;
  float ay_p = (ay - ay_offset) / CONST_16G;
  float az_p = (az / CONST_16G);

  float accel_angle_y = atan(-1 * ax_p / sqrt(pow(ay_p, 2) + pow(az_p, 2))) * RADIANS_TO_DEGREES;
  float accel_angle_x = atan(ay_p / sqrt(pow(ax_p, 2) + pow(az_p, 2))) * RADIANS_TO_DEGREES;

  float gx_p = (gx - gx_offset) / CONST_2000;
  float gy_p = (gy - gy_offset) / CONST_2000;
  float gz_p = (gz - gz_offset) / CONST_2000;

  float gyro_angle_x = gx_p * dt + get_last_angle_x();
  float gyro_angle_y = gy_p * dt + get_last_angle_y();

  float angle_x = ALPHA * gyro_angle_x + (1.0 - ALPHA) * accel_angle_x;
  float angle_y = ALPHA * gyro_angle_y + (1.0 - ALPHA) * accel_angle_y;

  float vel_x = (ax_p * dt * CONST_G);
  float vel_y = (ay_p * dt * CONST_G);
  float vel = sqrt(pow(vel_x, 2) + pow(vel_y, 2)) * KMPH;

  temperature = (accelgyro.getTemperature() + 12412) / 340;

  Serial.print("  vel: ");
  Serial.print(vel, 4);
  Serial.print("km/hr");
  Serial.print("  pitch: ");
  Serial.print(angle_x);
  Serial.print("deg");
  Serial.print("  roll: ");
  Serial.print(angle_y);
  Serial.print("deg");
  Serial.print("  temp: ");
  Serial.println(temperature);
  Serial.print(" C");

  set_last_time(t_now);

  set_last_gyro_angle_x(gyro_angle_x);
  set_last_gyro_angle_y(gyro_angle_y);

  set_last_angle_x(angle_x);
  set_last_angle_y(angle_y);

  delay(500);
}

void calibrate_sensors() {
  int                   num_readings = 100;
  float                 x_accel = 0;
  float                 y_accel = 0;
  float                 z_accel = 0;
  float                 x_gyro = 0;
  float                 y_gyro = 0;
  float                 z_gyro = 0;

  Serial.println("Starting Calibration");

  // Discard the first set of values read from the IMU
  accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  // Read and average the raw values from the IMU
  for (int i = 0; i < num_readings; i++) {
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    Serial.print(i);
    Serial.print("-CALIBRATION: ");
    Serial.print((ax / CONST_16G));
    Serial.print(",");
    Serial.print((ay / CONST_16G));
    Serial.print(",");
    Serial.print((az / CONST_16G));
    Serial.print(",");
    Serial.print(gx / CONST_2000);
    Serial.print(",");
    Serial.print(gy / CONST_2000);
    Serial.print(",");
    Serial.println(gz / CONST_2000);
    
    x_accel += ax;
    y_accel += ay;
    z_accel += az;
    x_gyro += gx;
    y_gyro += gy;
    z_gyro += gz;
    delay(10);
  }
  x_accel /= num_readings;
  y_accel /= num_readings;
  z_accel /= num_readings;
  x_gyro /= num_readings;
  y_gyro /= num_readings;
  z_gyro /= num_readings;

  // Store the raw calibration values globally
  ax_offset = x_accel;a
  ay_offset = y_accel;
  az_offset = z_accel;
  gx_offset = x_gyro;
  gy_offset = y_gyro;
  gz_offset = z_gyro;

  Serial.print("Offsets: ");
  Serial.print(ax_offset);
  Serial.print(", ");
  Serial.print(ay_offset);
  Serial.print(", ");
  Serial.print(az_offset);
  Serial.print(", ");
  Serial.print(gx_offset);
  Serial.print(", ");
  Serial.print(gy_offset);
  Serial.print(", ");
  Serial.println(gz_offset);

  Serial.println("Finishing Calibration");
}

inline unsigned long get_last_time() {
  return last_read_time;
}

inline void set_last_time(unsigned long _time) {
  last_read_time = _time;
}

inline float get_delta_time(unsigned long t_now) {
  return (t_now - get_last_time()) / 1000.0;
}

inline int16_t get_last_gyro_angle_x() {
  return gyro_angle_x_l;
}

inline void set_last_gyro_angle_x(int16_t _gyro_angle_x) {
  gyro_angle_x_l = _gyro_angle_x;
}

inline int16_t get_last_gyro_angle_y() {
  return gyro_angle_y_l;
}

inline void set_last_gyro_angle_y(int16_t _gyro_angle_y) {
  gyro_angle_y_l = _gyro_angle_y;
}

inline int16_t get_last_angle_x() {
  return angle_x_l;
}

inline void set_last_angle_x(int16_t _ang_x) {
  angle_x_l = _ang_x;
}

inline int16_t get_last_angle_y() {
  return angle_y_l;
}

inline void set_last_angle_y(int16_t _ang_y) {
  angle_y_l = _ang_y;
}

inline float get_accel_xy(float ax_p, float ay_p) {
  return sqrt(pow(ax_p, 2) + pow(ay_p, 2));
=======
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
>>>>>>> 25591e4e433829c968b9edfa8f5aaf8e0f55a4b6
}
