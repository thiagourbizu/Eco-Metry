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
#endif

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

bool lora_idle = true;

// Definicion de pines
int PinA = 0;
int PinV = 2;
int PinT = 1;
const int hallSensorPin = GPIO9;

void setup() {
    Serial.begin(115200);
    
    pinMode(PinA, INPUT);
    pinMode(PinV, INPUT);
    pinMode(PinT, INPUT);
    
    pinMode(hallSensorPin, INPUT);


    // Guardamos el tiempo de inicio
    unsigned long int tiempoInicioMinuto = millis();
    
    //Serial.println("Test");

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
    Current();
    Voltaje();
    Velocidad();
    Temperature();
    
    if (lora_idle) {
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
void Current(){
    // Current
    int LecturaA = analogRead(PinA) * (3.3/4095);
    float Current = (LecturaA - 2.24303144561052336669604301278013736) / 0.1;
    return Current;
}
void Voltaje(){
    // Volts
    int LecturaV = analogRead(PinV) * (3.3/4095);   
    int R1 = 18600000;
    int R2 = 1000000;
    float Volts = LecturaV * (R2/(R1+R2));
    return Volts;
}
void Velocidad(){
  // Variables para contar las veces que pasa el imán
  int contadorRevoluciones = 0;  // Contador que se reinicia cada minuto para calcular las RPM

  // Variable para manejar el tiempo de la última detección
  unsigned long ultimoTiempo = 0;
  unsigned long tiempoInicioMinuto = 0;  // Para medir un minuto

  int lectura = digitalRead(hallSensorPin);
  
  // Obtener el tiempo actual
  unsigned long tiempoActual = millis();

  // Si pasa el IMAN
  if (lectura == LOW) 
  {
    // Incrementamos el contador de revoluciones
    contadorRevoluciones++;
    
    // Actualizamos el tiempo de la última detección
    ultimoTiempo = tiempoActual;
    while(true)
    {
      //Serial.println(".");
      if(digitalRead(GPIO9) == HIGH)
        break;
    }
    
  }
  
  // Verificamos si ha pasado un minuto (60,000 ms)
  if (tiempoActual - tiempoInicioMinuto >= 60000) 
  {
    // Calculamos las RPM (revoluciones por minuto)
    int rpm = contadorRevoluciones;
    
    // Imprimimos las RPM
    Serial.print("Revoluciones por minuto (RPM): ");
    Serial.println(rpm);
    // Reiniciamos el contador de revoluciones y el tiempo de inicio del minuto
    contadorRevoluciones = 0;
    tiempoInicioMinuto = tiempoActual;
  }
}
void Temperature(){
  float Temperature = analogRead(PinT);     
}
