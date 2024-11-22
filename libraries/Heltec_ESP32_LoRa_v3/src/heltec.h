/**
 * @file heltec.h
 * @brief Header file for the Heltec library.
 *
 * This file contains the definitions and declarations for the Heltec library.
 * The library provides functions for controlling the Heltec ESP32 LoRa V3
 * board, including LED brightness control, voltage measurement, deep sleep
 * mode, and more.
 */

#ifndef heltec_h
#define heltec_h

// 'PRG' Button
#define BUTTON    GPIO_NUM_0
// LED pin & PWM parameters
#define LED_PIN   GPIO_NUM_35
#define LED_FREQ  5000
#define LED_CHAN  0
#define LED_RES   8
// External power control
#define VEXT      GPIO_NUM_36
// Battery voltage measurement
#define VBAT_CTRL GPIO_NUM_37
#define VBAT_ADC  GPIO_NUM_1
// SPI pins
#define SS        GPIO_NUM_8
#define MOSI      GPIO_NUM_10
#define MISO      GPIO_NUM_11
#define SCK       GPIO_NUM_9
// Radio pins
#define DIO1      GPIO_NUM_14
#define RST_LoRa  GPIO_NUM_12
#define BUSY_LoRa GPIO_NUM_13
// Display pins
#define SDA_OLED  GPIO_NUM_17
#define SCL_OLED  GPIO_NUM_18
#define RST_OLED  GPIO_NUM_21

#ifndef HELTEC_NO_RADIOLIB
  #include "RadioLib/RadioLib.h"
  // make sure the power off button works when using RADIOLIB_OR_HALT
  // (See RadioLib_convenience.h)
  #define RADIOLIB_DO_DURING_HALT heltec_delay(10)
  #include "RadioLib_convenience.h"
#endif

#ifdef HELTEC_NO_DISPLAY
  #define HELTEC_NO_DISPLAY_INSTANCE
#else
  #include "display/SSD1306Wire.h"
  #include "display/OLEDDisplayUi.h"
#endif

#include "HotButton.h"

#ifndef HELTEC_NO_RADIO_INSTANCE
  #ifndef HELTEC_NO_RADIOLIB
    SX1262 radio = new Module(SS, DIO1, RST_LoRa, BUSY_LoRa);
  #endif
#endif

// Don't you just hate it when battery percentages are wrong?
//
// I measured the actual voltage drop on a LiPo battery and these are the
// average voltages, expressed in 1/256'th steps between min_voltage and
// max_voltage for each 1/100 of the time it took to discharge the battery. The
// code for a telnet server that outputs battery voltage as CSV data is in
// examples, and a python script that outputs the constants below is in
// src/tools.
const float min_voltage = 3.04;
const float max_voltage = 4.26;
const uint8_t scaled_voltage[100] = {
  254, 242, 230, 227, 223, 219, 215, 213, 210, 207,
  206, 202, 202, 200, 200, 199, 198, 198, 196, 196,
  195, 195, 194, 192, 191, 188, 187, 185, 185, 185,
  183, 182, 180, 179, 178, 175, 175, 174, 172, 171,
  170, 169, 168, 166, 166, 165, 165, 164, 161, 161,
  159, 158, 158, 157, 156, 155, 151, 148, 147, 145,
  143, 142, 140, 140, 136, 132, 130, 130, 129, 126,
  125, 124, 121, 120, 118, 116, 115, 114, 112, 112,
  110, 110, 108, 106, 106, 104, 102, 101, 99, 97,
  94, 90, 81, 80, 76, 73, 66, 52, 32, 7,
};

/**
 * @class PrintSplitter
 * @brief A class that splits the output of the Print class to two different
 *        Print objects.
 *
 * The PrintSplitter class is used to split the output of the Print class to two
 * different Print objects. It overrides the write() function to write the data
 * to both Print objects.
 */
class PrintSplitter : public Print {
  public:
    PrintSplitter(Print &_a, Print &_b) : a(_a), b(_b) {}
    size_t write(uint8_t c) {
      a.write(c);
      return b.write(c);
    }
    size_t write(const char* str) {
      a.write(str);
      return b.write(str);
    }
  private:
    Print &a;
    Print &b;
};

#ifndef HELTEC_NO_DISPLAY_INSTANCE
  #ifdef HELTEC_WIRELESS_STICK
    #define DISPLAY_GEOMETRY GEOMETRY_64_32
  #else
    #define DISPLAY_GEOMETRY GEOMETRY_128_64
  #endif
  SSD1306Wire display(0x3c, SDA_OLED, SCL_OLED, RST_OLED, DISPLAY_GEOMETRY);
  PrintSplitter both(Serial, display);
#else
  Print &both = Serial;
#endif

HotButton button(BUTTON);

/**
 * @brief Controls the LED brightness based on the given percentage.
 *
 * This function sets up the LED channel, frequency, and resolution, and then
 * adjusts the LED brightness based on the given percentage. If the percentage
 * is 0 or less, the LED pin is set as an input pin.
 *
 * @param percent The brightness percentage of the LED (0-100).
 */
void heltec_led(int percent) {
  if (percent > 0) {
    ledcSetup(LED_CHAN, LED_FREQ, LED_RES);
    ledcAttachPin(LED_PIN, LED_CHAN);
    ledcWrite(LED_CHAN, percent * 255 / 100);
  } else {
    ledcDetachPin(LED_PIN);
    pinMode(LED_PIN, INPUT);
  }
}

/**
 * @brief Controls the VEXT pin to enable or disable external power.
 *
 * This function sets the VEXT pin as an output pin and sets its state based on
 * the given parameter. If the state is true, the VEXT pin is set to LOW to
 * enable external power. If the state is false, the VEXT pin is set to INPUT to
 * disable external power.
 *
 * @param state The state of the VEXT pin (true = enable, false = disable).
 */
void heltec_ve(bool state) {
  if (state) {
    pinMode(VEXT, OUTPUT);
    digitalWrite(VEXT, LOW);
  } else {
    // pulled up, no need to drive it
    pinMode(VEXT, INPUT);
  }
}

/**
 * @brief Measures the battery voltage.
 *
 * This function measures the battery voltage by controlling the VBAT_CTRL pin
 * and reading the analog value from the VBAT_ADC pin. The measured voltage is
 * then converted to a float value and returned.
 *
 * @return The battery voltage in volts.
 */
float heltec_vbat() {
  pinMode(VBAT_CTRL, OUTPUT);
  digitalWrite(VBAT_CTRL, LOW);
  delay(5);
  float vbat = analogRead(VBAT_ADC) / 238.7;
  // pulled up, no need to drive it
  pinMode(VBAT_CTRL, INPUT);
  return vbat;
}

/**
 * @brief Puts the device into deep sleep mode.
 *
 * This function prepares the device for deep sleep mode by disconnecting from
 * WiFi, turning off the display, disabling external power, and turning off the
 * LED. It can also be configured to wake up after a certain number of seconds
 * using the optional parameter.
 *
 * @param seconds The number of seconds to sleep before waking up (default = 0).
 */
void heltec_deep_sleep(int seconds = 0) {
  #ifdef WiFi_h
    WiFi.disconnect(true);
  #endif
  #ifndef HELTEC_NO_DISPLAY_INSTANCE
    display.displayOff();
  #endif
  #ifndef HELTEC_NO_RADIO_INSTANCE
    // It seems to make no sense to do a .begin() here, but in case the radio is
    // not interacted with at all before sleep, it will not respond to just
    // .sleep() and then consumes 800 µA more than it should in deep sleep.
    radio.begin();
    // 'false' here is to not have a warm start, we re-init the after sleep.
    radio.sleep(false);
  #endif
  // Turn off external power
  heltec_ve(false);
  // Turn off LED
  heltec_led(0);
  // Set all pins to input to save power
  pinMode(VBAT_CTRL, INPUT);
  pinMode(VBAT_ADC, INPUT);
  pinMode(DIO1, INPUT);
  pinMode(RST_LoRa, INPUT);
  pinMode(BUSY_LoRa, INPUT);
  pinMode(SS, INPUT);
  pinMode(MISO, INPUT);
  pinMode(MOSI, INPUT);
  pinMode(SCK, INPUT);
  pinMode(SDA_OLED, INPUT);
  pinMode(SCL_OLED, INPUT);
  pinMode(RST_OLED, INPUT);
  // Set button wakeup if applicable
  #ifdef HELTEC_POWER_BUTTON
    esp_sleep_enable_ext0_wakeup(BUTTON, LOW);
    button.waitForRelease();
  #endif
  // Set timer wakeup if applicable
  if (seconds > 0) {
    esp_sleep_enable_timer_wakeup(seconds * 1000000);
  }
  // and off to bed we go
  esp_deep_sleep_start();
}

/**
 * @brief Calculates the battery percentage based on the measured battery
 * voltage.
 *
 * This function calculates the battery percentage based on the measured battery
 * voltage. If the battery voltage is not provided as a parameter, it will be
 * measured using the heltec_vbat() function. The battery percentage is then
 * returned as an integer value.
 *
 * @param vbat The battery voltage in volts (default = -1).
 * @return The battery percentage (0-100).
 */
int heltec_battery_percent(float vbat = -1) {
  if (vbat == -1) {
    vbat = heltec_vbat();
  }
  for (int n = 0; n < sizeof(scaled_voltage); n++) {
    float step = (max_voltage - min_voltage) / 256;
    if (vbat > min_voltage + (step * scaled_voltage[n])) {
      return 100 - n;
    }
  }
  return 0;
}

/**
 * @brief Checks if the device woke up from deep sleep due to button press.
 * 
 * @return True if the wake-up cause is a button press, false otherwise.
 */
bool heltec_wakeup_was_button() {
  return esp_sleep_get_wakeup_cause() == ESP_SLEEP_WAKEUP_EXT0;
}

/**
 * @brief Checks if the device woke up from deep sleep due to a timer.
 * 
 * This function checks if the device woke up from deep sleep due to a timer.
 * 
 * @return True if the wake-up cause is a timer interrupt, false otherwise.
 */
bool heltec_wakeup_was_timer() {
  return esp_sleep_get_wakeup_cause() == ESP_SLEEP_WAKEUP_TIMER;
}

/**
 * @brief Initializes the Heltec library.
 *
 * This function should be the first thing in setup() of your sketch. It
 * initializes the Heltec library by setting up serial port and display.
 */
void heltec_setup() {
  Serial.begin(115200);
  #ifndef HELTEC_NO_DISPLAY_INSTANCE
    #ifdef HELTEC_WIRELESS_STICK
      // They hooked the display to "external" power, and didn't tell anyone
      heltec_ve(true);
      delay(5);
    #endif
    display.init();
    display.setContrast(255);
    display.flipScreenVertically();
  #endif
}

/**
 * @brief The main loop function for the Heltec library.
 *
 * This function should be called in loop() of the Arduino sketch. It updates
 * the state of the power button and implements long-press power off if used.
 */
void heltec_loop() {
  button.update();
  #ifdef HELTEC_POWER_BUTTON
    // Power off button checking
    if (button.pressedFor(1000)) {
      // Visually confirm it's off so user releases button
      display.displayOff();
      // Deep sleep (has wait for release so we don't wake up immediately)
      heltec_deep_sleep();
    }
  #endif
}

/**
 * @brief Delays the execution of the program for the specified number of
 *        milliseconds.
 *
 * This function delays the execution of the program for the specified number of
 * milliseconds. During the delay, it also calls the heltec_loop() function to
 * allow for the power off button to be checked.
 *
 * @param ms The number of milliseconds to delay.
 */
void heltec_delay(int ms) {
  uint64_t start = millis();
  while (true) {
    heltec_loop();
    delay(1);
    if (millis() - start >= ms) {
      break;
    }
  }
}

#endif
