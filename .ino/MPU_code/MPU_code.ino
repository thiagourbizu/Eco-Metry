#include "MPU6050.h"
#include "Wire.h"
#include "I2Cdev.h"

// Configuración del puerto serie
#define BT_BAUD_RATE 115200 // Velocidad de comunicación con HC-05
#define DELAY_MS 100     // Retraso entre transmisiones (milisegundos)

HardwareSerial BTserial(1); // UART1 para el HC-05

const float CONST_16G = 2048.0;
const float CONST_2000 = 16.4;
const float CONST_G = 9.81;
const float RADIANS_TO_DEGREES = 180.0 / 3.14159;
const float ALPHA = 0.96;
const float KMPH = 3.6;

MPU6050 accelgyro;

unsigned long last_read_time;
int16_t ax, ay, az, gx, gy, gz;
float angle_x = 0, angle_y = 0;
float ax_offset, ay_offset, az_offset;

float velocity_x = 0, velocity_y = 0; // Velocidades en m/s

void setup() {
  Wire.begin(GPIO9, GPIO8 );
  Serial.begin(115200);
  BTserial.begin(115200);

  BTserial.println("Bluetooth Connected");

  accelgyro.initialize();
  if (!accelgyro.testConnection()) {
    Serial.println("MPU6050 connection failed");
    while (1);
  }

  accelgyro.setFullScaleAccelRange(0x03);
  accelgyro.setFullScaleGyroRange(0x03);

  calibrate_sensors();
  set_last_time(millis());
}

void loop() {
  unsigned long t_now = millis();
  float dt = get_delta_time(t_now);
  accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  // Calibración de aceleración
  float ax_p = (ax - ax_offset) / CONST_16G;
  float ay_p = (ay - ay_offset) / CONST_16G;

  // Compensar gravedad
  ax_p -= (sin(angle_x * RADIANS_TO_DEGREES) * CONST_G);
  ay_p -= (sin(angle_y * RADIANS_TO_DEGREES) * CONST_G);

  // Actualizar velocidades
  velocity_x += ax_p * dt; // Integración
  velocity_y += ay_p * dt;

  // Calcular magnitud de la velocidad
  float velocity = sqrt(velocity_x * velocity_x + velocity_y * velocity_y) * KMPH;

  // Imprimir valores
  Serial.print("Vel: ");
  Serial.print(velocity, 4);
  Serial.println(" km/hr");
  int temperature_1= 100;
  int voltaje = 1;
  int amperaje = 2;
  //int roundedTempC = round(temperatureC);

  // También mostrar la temperatura en el monitor serial
 // Serial.println(temperatureC,hola);
  String cadena = String(temperature_1) + "," + String(velocity) + "," +  String(voltaje) + "," + String(amperaje);

  BTserial.print(cadena);
  
  set_last_time(t_now);
  delay(100); // Reducción del delay
}

void calibrate_sensors() {
  const int num_readings = 1000;
  float x_accel = 0, y_accel = 0, z_accel = 0;

  for (int i = 0; i < num_readings; i++) {
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
    x_accel += ax;
    y_accel += ay;
    z_accel += az;
    delay(10);
  }
  ax_offset = x_accel / num_readings;
  ay_offset = y_accel / num_readings;
  az_offset = z_accel / num_readings; // No es necesario para el cálculo horizontal, pero puede ser útil

  Serial.println("Calibration finished");
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
