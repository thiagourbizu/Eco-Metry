/* Heltec Automation send communication test example
 *
 * Function:
 * 1. Send data from a esp32 device over hardware 
 *  
 * Description:
 * 
 * HelTec AutoMation, Chengdu, China
 * 成都惠利特自动化科技有限公司
 * www.heltec.org
 *
 * this project also realess in GitHub:
 * https://github.com/Heltec-Aaron-Lee/WiFi_Kit_series
 * */

#include "LoRaWan_APP.h"
#include "Arduino.h"

#include <DHT.h> 
// Hall
#include <EEPROM.h>

// Bluetooth
HardwareSerial BTserial(1);

#define RF_FREQUENCY                                915000000 // Hz

#define TX_OUTPUT_POWER                             5        // dBm

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

// Temperature Settings
#define DHTTYPE DHT11
#define DHTPIN 35

// Inicializamos
DHT dht(DHTPIN, DHTTYPE);

// Definicion de pines
#define PinA 2
#define PinV 1
#define hallSensorPin 36

// Variables para contar!
int contador = 0;
boolean flag=0;

volatile unsigned long lastturn;
volatile float SPEED;
volatile float RPM;
volatile float DIST;
volatile boolean eeprom_flag;

float w_length = 1.57075; // Diametro de la rueda
boolean state, button;


char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

double txNumber;

bool lora_idle=true;

static RadioEvents_t RadioEvents;
void OnTxDone( void );
void OnTxTimeout( void );

unsigned long lastSendTime = 0;  // Almacena el último tiempo de envío


void setup() {
    Serial.begin(115200);
    BTserial.begin(115200);
    pinMode(PinA, INPUT);
    pinMode(PinV, INPUT);
    pinMode(DHTPIN, INPUT);
    pinMode(hallSensorPin, INPUT);
    
    Mcu.begin(HELTEC_BOARD,SLOW_CLK_TPYE);
    dht.begin();
	
    txNumber=0;

    RadioEvents.TxDone = OnTxDone;
    RadioEvents.TxTimeout = OnTxTimeout;
    
    Radio.Init( &RadioEvents );
    Radio.SetChannel( RF_FREQUENCY );
    Radio.SetTxConfig( MODEM_LORA, TX_OUTPUT_POWER, 0, LORA_BANDWIDTH,
                                   LORA_SPREADING_FACTOR, LORA_CODINGRATE,
                                   LORA_PREAMBLE_LENGTH, LORA_FIX_LENGTH_PAYLOAD_ON,
                                   true, 0, 0, LORA_IQ_INVERSION_ON, 3000 ); 
   }



void loop()
{
  // Current ------------------------------------
    float LecturaA=0;
    float PromedioA = 0;
    float LecturaA_1;
    float current=0;
    for (int i=0;i<=150;i++)
    {
       //Serial.println(i);
       LecturaA = analogRead(PinA) * (3.3/4095);
       LecturaA_1 = (LecturaA - 2.24303144561052336669604301278013736) / 0.1;
       PromedioA += LecturaA_1;
       // 100 vueltas...
    }
    // Promedio
    current=PromedioA/150;
    current+=6.9;
    //   Filtro para ruido
    if (current < 0)
      current = 0;
    

    // Volts ------------------------------------
    float LecturaV=0;
    float LecturaV_1=0;
    float PromedioV=0;
    float voltaje=0;
    float R1 = 22601200 ; // resistencia R1 en ohm
    float R2 = 1000000;  // resistencia R2 en ohm
    
    for (int i=0;i<=150;i++)
    {
       //Serial.println(i);
       LecturaV = analogRead(PinV) * (3.3/4095);
  
       LecturaV_1 = LecturaV * (R1 + R2) / R2;
       PromedioV += LecturaV_1;
       // 100 vueltas...
    }
    // Promedio
    voltaje=PromedioV/150;
    //   Filtro para ruido
    if (voltaje < 18.40)
      voltaje = 0;
    
    // Velocidad ------------------------------------
    if(digitalRead(hallSensorPin) == HIGH)
      flag=0;
    
    if(digitalRead(hallSensorPin) == LOW && flag == 0)
    {
      if (millis() - lastturn > 80)  // simple noise cut filter (based on fact that you will not be ride your bike more than 120 km/h =)
      {    
        unsigned long time = millis() - lastturn;
        SPEED = w_length / ((float)(millis() - lastturn) / 1000) * 3.6;// calculate speed
        lastturn = millis();
        RPM = (60.0 * 1000.0) / time;// remember time of last revolution
        DIST = DIST + w_length / 1000;// calculate distance
      }
      eeprom_flag = 1;
      flag=1;
    }

     // Temperature ------------------------------------
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if(isnan(humidity) || isnan(temperature))
    {
      humidity = 0.1;
      temperature= 0.1;
    }
    
    if ((millis() - lastturn) > 2000)// if there is no signal more than 2 seconds
    {       
      SPEED = 0;
      RPM = 0;
      if (eeprom_flag)// if eeprom flag is true
      {                      
        EEPROM.write(0, (float)DIST * 10.0);  // write ODO in EEPROM
        eeprom_flag = 0;// flag down. To prevent rewritind
      }
    }
   
	if (lora_idle && (millis() - lastSendTime > 150)) {
        // Formatea la cadena con 4 valores
        sprintf(txpacket,"%.2f,%.2f,%.2f,%.2f,%.2f,%.2f", temperature, humidity, RPM, voltaje, current, SPEED);
        //Serial.print(LecturaV);
        //Serial.printf("\r\nsending packet \"%s\" , length %d\r\n", txpacket, strlen(txpacket));
        //turnOnRGB(COLOR_SEND, 0); // Cambia el color del RGB
        Radio.Send((uint8_t *)txpacket, strlen(txpacket)); // Envía el paquete
        lora_idle = false;
         
        
        String cadena = String(temperature) + "," + String(humidity) + "," + String(RPM) + "," +  String(voltaje) + "," + String(current) + "," + String(SPEED);  
        // Enviar el dato leído a través del módulo Bluetooth
        //BTserial.print(cadena);
        Serial.println(cadena);
    }

    Radio.IrqProcess();  // Procesa interrupciones del LoRa
}

void OnTxDone( void )
{
	//Serial.println("TX done......");
	lora_idle = true;
}

void OnTxTimeout( void )
{
    Radio.Sleep( );
    //Serial.println("TX Timeout......");
    lora_idle = true;
}
