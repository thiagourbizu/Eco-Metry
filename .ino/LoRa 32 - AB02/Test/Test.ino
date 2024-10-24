#include "LoRaWan_APP.h"
#include "Arduino.h"
#include <HardwareSerial.h>

//NO TOCAR NUNCA EN LA VIDA
#define RX_PIN 1
#define TX_PIN 2

HardwareSerial BTSerial(1);  // UART1 Heltec AB02
/*
 * set LoraWan_RGB to 1,the RGB active in loraWan
 * RGB red means sending;
 * RGB green means received done;
 */
#ifndef LoraWan_RGB
#define LoraWan_RGB 0
#endif

#define RF_FREQUENCY                                915000000 // Hz

#define TX_OUTPUT_POWER                             14        // dBm

#define LORA_BANDWIDTH                              0         // [0: 125 kHz,
                                                              //  1: 250 kHz,
                                                              //  2: 500 kHz,
                                                              //  3: Reserved]
#define LORA_SPREADING_FACTOR                       7         // [SF7..SF12]
#define LORA_CODINGRATE                             1         // [1: 4/5,
                                                              //  2: 4/6,
                                                              //  3: 4/7,
                                                              //  4: 4/8]
#define LORA_PREAMBLE_LENGTH                        8         // Same for Tx and Rx
#define LORA_SYMBOL_TIMEOUT                         0         // Symbols
#define LORA_FIX_LENGTH_PAYLOAD_ON                  false
#define LORA_IQ_INVERSION_ON                        false


#define RX_TIMEOUT_VALUE                            1000
#define BUFFER_SIZE                                 30 // Define the payload size here

char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

static RadioEvents_t RadioEvents;

int16_t txNumber;

int16_t rssi, rxSize;

bool lora_idle = true;
String cadena;  // Variable para almacenar la cadena recibida

void setup() {
    Serial.begin(115200);
    BTSerial.begin(115200);

    txNumber = 0;
    rssi = 0;

    RadioEvents.RxDone = OnRxDone;
    Radio.Init(&RadioEvents);
    Radio.SetChannel(RF_FREQUENCY);

    Radio.SetRxConfig(MODEM_LORA, LORA_BANDWIDTH, LORA_SPREADING_FACTOR,
                                   LORA_CODINGRATE, 0, LORA_PREAMBLE_LENGTH,
                                   LORA_SYMBOL_TIMEOUT, LORA_FIX_LENGTH_PAYLOAD_ON,
                                   0, true, 0, 0, LORA_IQ_INVERSION_ON, true);
}

void loop() {
    if (lora_idle) {
        turnOffRGB();
        lora_idle = false;
        //Serial.println("into RX mode");
        Radio.Rx(0);
    }
}

void OnRxDone(uint8_t *payload, uint16_t size, int16_t rssi, int8_t snr) {
    rssi = rssi;
    rxSize = size;
    memcpy(rxpacket, payload, size);
    rxpacket[size] = '\0';

    cadena = String((char*)rxpacket);  // Convertir el buffer a un String

    turnOnRGB(COLOR_RECEIVED, 0);
    Radio.Sleep();
    
    // Mostrar solo la cadena recibida
    //Serial.printf("\r\nreceived packet: \"%s\" with rssi %d, length %d\r\n", cadena.c_str(), rssi, rxSize);
    Serial.println(cadena);
    BTSerial.print(cadena);
    lora_idle = true;
}
