/* Heltec Automation send communication test example
 *
 * Function:
 * 1. Send data from a CubeCell device over hardware 
 * 
 * 
 * this project also realess in GitHub:
 * https://github.com/HelTecAutomation/ASR650x-Arduino
 * */

#include "LoRaWan_APP.h"
#include "Arduino.h"

/*
 * set LoraWan_RGB to 1, the RGB active in loraWan
 * RGB red means sending;
 * RGB green means received done;
 */
#ifndef LoraWan_RGB
#define LoraWan_RGB 0

#define RF_FREQUENCY 915000000 // Hz

#define TX_OUTPUT_POWER 14 // dBm

#define LORA_BANDWIDTH 0 // [0: 125 kHz,
                         //  1: 250 kHz,
                         //  2: 500 kHz,
                         //  3: Reserved]
#define LORA_SPREADING_FACTOR 7 // [SF7..SF12]
#define LORA_CODINGRATE 1       // [1: 4/5,
                                //  2: 4/6,
                                //  3: 4/7,
                                //  4: 4/8]
#define LORA_PREAMBLE_LENGTH 8  // Same for Tx and Rx
#define LORA_SYMBOL_TIMEOUT 0   // Symbols
#define LORA_FIX_LENGTH_PAYLOAD_ON false
#define LORA_IQ_INVERSION_ON false

#define RX_TIMEOUT_VALUE 1000
#define BUFFER_SIZE 50 // Increase buffer size to accommodate larger payload

char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

static RadioEvents_t RadioEvents;

float txNumber;
bool lora_idle = true;

void setup() {
    Serial.begin(115200);
    pinMode(0, INPUT);
    txNumber = 0;
    Serial.println("Test");

    RadioEvents.TxDone = OnTxDone;
    RadioEvents.TxTimeout = OnTxTimeout;
    Radio.Init(&RadioEvents);
    Radio.SetChannel(RF_FREQUENCY);
    Radio.SetTxConfig(MODEM_LORA, TX_OUTPUT_POWER, 0, LORA_BANDWIDTH,
                      LORA_SPREADING_FACTOR, LORA_CODINGRATE,
                      LORA_PREAMBLE_LENGTH, LORA_FIX_LENGTH_PAYLOAD_ON,
                      true, 0, 0, LORA_IQ_INVERSION_ON, 3000);
}

void loop() {
    //int Lectura0 = analogRead(0);  // Simulación de lectura analógica
    float PinVoltaje = analogRead(0) * (3.3/4095);
    float current = (PinVoltaje - 2.24303144561052336669604301278013736) / 0.1;
    float voltaje = 10;       // Ejemplo de segundo valor
    float velocidad= 1;       // Ejemplo de tercer valor
    float temperature = 3;       // Ejemplo de cuarto valor

    if (lora_idle) {
        txNumber += 1;
        delay(100);
        // Formatea la cadena con 4 valores
        sprintf(txpacket,"%.2f,%.2f,%.2f,%.2f", temperature, velocidad, voltaje, current);
        Serial.printf("\r\nsending packet \"%s\" , length %d\r\n", txpacket, strlen(txpacket));
        turnOnRGB(COLOR_SEND, 0); // Cambia el color del RGB
        Radio.Send((uint8_t *)txpacket, strlen(txpacket)); // Envía el paquete
        lora_idle = false;
    }
}
 
void OnTxDone(void) {
    turnOffRGB();
    Serial.println("TX done......");
    lora_idle = true;
}

void OnTxTimeout(void) {
    turnOffRGB();
    Radio.Sleep();
    Serial.println("TX Timeout......");
    lora_idle = true;
}
