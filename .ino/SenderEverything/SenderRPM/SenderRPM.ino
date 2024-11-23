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
// Temp
#include <DHT.h> 

// Hall
#include <EEPROM.h>

// Bluetooth
HardwareSerial BTserial(1);
/*
 * set LoraWan_RGB to 1, the RGB active in loraWan
 * RGB red means sending;
 * RGB green means received done;
 */
#ifndef LoraWan_RGB
#define LoraWan_RGB 1
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

#define BUFFER_SIZE 50 // Increase buffer size to accommodate larger payload

// Declaramos los baudios
#define BAUD_RATE 115200

char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

static RadioEvents_t RadioEvents;

bool lora_idle = true;

// Definicion de pines
#define PinA 1
#define PinV 2
#define PinT 0

// Temperature Settings
#define DHTTYPE DHT11
#define DHTPIN 8

// Inicializamos
DHT dht(DHTPIN, DHTTYPE);

// Definimos el pin donde conectaremos el sensor Hall
#define hallSensorPin 9

// Variables para contar!
int contador = 0;
boolean flag=0;

volatile unsigned long lastturn;
volatile float SPEED;
volatile float RPM;
volatile float DIST;
volatile boolean eeprom_flag;

float w_length = 1.57075; // Pone el diametro de la rueda 3.1415 
boolean state, button;

// Variable de iteraciones de ambos Promedios
#define iteracionesPromedio 150

// Variable para manejar el tiempo de la última detección
unsigned long tiempoInicioSegundos = 0;
unsigned long tiempoInicioMinuto = 0;  // Para medir un minuto

void setup() {
    Serial.begin(BAUD_RATE);
    BTserial.begin(BAUD_RATE);
    dht.begin();
    
    // Pinmodes
    pinMode(PinA, INPUT);
    pinMode(PinV, INPUT);
    pinMode(PinT, INPUT);
    pinMode(hallSensorPin, INPUT);
    
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
    // Current ------------------------------------
    float LecturaA=0;
    float PromedioA = 0;
    float LecturaA_1;
    float current=0;
    for (int i=0;i<=iteracionesPromedio;i++)
    {
       LecturaA = analogRead(PinA) * (3.3/4095);
       LecturaA_1 = (LecturaA - 2.24303144561052336669604301278013736) / 0.1;
       PromedioA += LecturaA_1;
       // 100 vueltas...
    }
    // Promedio
    current=PromedioA/iteracionesPromedio;
    
    // Volts ------------------------------------
    float LecturaV = analogRead(PinV) * (3.3/4095);   
    float R1 = 15600000; // resistencia R1 en ohm
    float R2 = 1000000;  // resistencia R2 en ohm

    // Calculo
    float voltaje = LecturaV * (R1 + R2) / R2; 
    
    // Velocidad ------------------------------------
    // Tiempo actual
    unsigned long tiempoActual = millis();

    if(digitalRead(hallSensorPin) == HIGH)
      flag=0;
    
    if(digitalRead(hallSensorPin) == LOW && flag == 0)
    {
      if (tiempoActual - lastturn > 80)  // simple noise cut filter (based on fact that you will not be ride your bike more than 120 km/h =)
      {    
        unsigned long time = millis() - lastturn;
        SPEED = w_length / ((float)(millis() - lastturn) / 1000) * 3.6;// calculate speed
        lastturn = tiempoActual;
        RPM = (60.0 * 1000.0) / time;// remember time of last revolution
        DIST = DIST + w_length / 1000;// calculate distance
      }
      eeprom_flag = 1;
      flag=1;
    }

    if ((millis() - lastturn) > 3500)// if there is no signal more than 2 seconds
    {       
      SPEED = 0;
      RPM = 0;
      if (eeprom_flag)// if eeprom flag is true
      {                      
        EEPROM.write(0, (float)DIST * 10.0);  // write ODO in EEPROM
        eeprom_flag = 0;// flag down. To prevent rewritind
      }
    }
    
    // Temperature ------------------------------------
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if(isnan(humidity) || isnan(temperature))
    {
      humidity = 0.1;
      temperature= 0.1;
    }
    
    // Transmisión cada X ms
    if (tiempoActual - tiempoInicioSegundos >= 150) 
    {
      tiempoInicioSegundos = tiempoActual;
      if (lora_idle) 
      {
        // Formatea la cadena con 4 valores
        sprintf(txpacket,"%.2f,%.2f,%.2f,%.2f,%.2f,%.2f", temperature, humidity, RPM, voltaje, current, SPEED);
        //Serial.printf("\r\nsending packet \"%s\" , length %d\r\n", txpacket, strlen(txpacket));
        //turnOnRGB(COLOR_SEND, 0); // Cambia el color del RGB
        Radio.Send((uint8_t *)txpacket, strlen(txpacket)); // Envía el paquete
        //lora_idle = false;
         
        
        String cadena = String(temperature) + "," + String(humidity) + "," + String(RPM) + "," +  String(voltaje) + "," + String(current) + "," + String(SPEED);  
        // Enviar el dato leído a través del módulo Bluetooth
        //BTserial.print(cadena);
        Serial.println(cadena);
        
      }
      Radio.IrqProcess( );
    }
    
}
 
void OnTxDone(void) {
    //turnOffRGB();
    //Serial.println("TX done......");
    lora_idle = true;
}

void OnTxTimeout(void) {
    //turnOffRGB();
    Radio.Sleep();
    //Serial.println("TX Timeout......");
    lora_idle = true;
}
