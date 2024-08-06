  //https://dl.espressif.com/dl/package_esp32_index.json

#include "BluetoothSerial.h"
#include "esp_adc_cal.h"
#define ADC_VREF_mV    5000.0 // in millivolt
#define ADC_RESOLUTION 4096.0
#define PIN_LM35       35

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;

int Led = 2;

void setup() {
  Serial.begin(9600);
  SerialBT.begin("ESP32_LABVIEW");
  pinMode(Led, OUTPUT);
}
void loop() {
  
// get the ADC value from the temperature sensor
  int adcVal = analogRead(PIN_LM35);
  // convert the ADC value to voltage in millivolt
  float milliVolt = adcVal * (ADC_VREF_mV / ADC_RESOLUTION);
  // convert the voltage to the temperature in Celsius
  float tempC = milliVolt / 10;
 
// print the temperature in the Serial Monitor:
  Serial.println(tempC);   // print the temperature in Celsius
  SerialBT.println (tempC);
  delay(1000);
  if (SerialBT.available()) {
    char Mensaje = SerialBT.read();
    if (Mensaje == 'A') {
      digitalWrite(Led, HIGH);
    }
    else if (Mensaje == 'B') {
      digitalWrite(Led, LOW);
    }
  }
  
}
