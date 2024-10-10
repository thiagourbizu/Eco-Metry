#include "LoRaWan_APP.h"
#include "Arduino.h"

#define LoraWan_RGB 0
#define RF_FREQUENCY 915000000 // Hz
#define TX_OUTPUT_POWER 14     // dBm
#define LORA_BANDWIDTH 0       // 125 kHz
#define LORA_SPREADING_FACTOR 7
#define LORA_CODINGRATE 1
#define LORA_PREAMBLE_LENGTH 8
#define LORA_SYMBOL_TIMEOUT 0
#define LORA_FIX_LENGTH_PAYLOAD_ON false
#define LORA_IQ_INVERSION_ON false

#define RX_TIMEOUT_VALUE 1000
#define BUFFER_SIZE 50 // Increase buffer size to accommodate larger payload

char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

HardwareSerial BTserial(1); // UART1 para el HC-05

static RadioEvents_t RadioEvents;

bool lora_idle = true;

// Definicion de pines
int PinA = 0;
int PinV = 2;
int PinT = 1;
const int hallSensorPin = GPIO9;

// Variables para control de tiempo
unsigned long previousMillis = 0;
const long interval = 100; // 100ms

void setup() {
    Serial.begin(115200);

    // Inicializa el puerto serie para la comunicación con el HC-05
    BTserial.begin(115200);
    
    pinMode(PinA, INPUT);
    pinMode(PinV, INPUT);
    pinMode(PinT, INPUT);
    pinMode(hallSensorPin, INPUT);

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
    unsigned long currentMillis = millis();

    // Si han pasado 100 ms desde la última transmisión
    if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;

        // Obtener todas las lecturas
        float current = Current();
        float voltaje = Voltaje();
        float velocidad = Velocidad();
        float temperature = Temperature();

        // Serial.println(temperatureC,hola);
        String cadena = String(temperature) + "," + String(velocidad) + "," +  String(voltaje) + "," + String(current);
        // Enviar el dato leído a través del módulo Bluetooth

        BTserial.print(cadena);
        
        // Formatear la cadena de datos
        sprintf(txpacket, "%.2f,%.2f,%.2f,%.2f", temperature, velocidad, voltaje, current);
        Serial.printf("\r\nEnviando paquete \"%s\" , longitud %d\r\n", txpacket, strlen(txpacket));

        // Enviar datos por LoRa
        if (lora_idle) {
            turnOnRGB(COLOR_SEND, 0); // Cambiar color del RGB
            Radio.Send((uint8_t *)txpacket, strlen(txpacket)); // Enviar paquete
            lora_idle = false;
        }
    }
}

void OnTxDone(void) {
    turnOffRGB();
    Serial.println("TX hecho...");
    lora_idle = true;
}

void OnTxTimeout(void) {
    turnOffRGB();
    Radio.Sleep();
    Serial.println("TX Timeout...");
    lora_idle = true;
}

float Current() {
    // Leer corriente
    int LecturaA = analogRead(PinA) * (3.3 / 4095);
    float current = (LecturaA - 2.243) / 0.1;
    return current;
}

float Voltaje() {
    // Leer voltaje
    int LecturaV = analogRead(PinV) * (3.3 / 4095);
    int R1 = 18600000;
    int R2 = 1000000;
    float voltaje = LecturaV * (R2 / (R1 + R2));
    return voltaje;
}

float Velocidad() {
    // Velocidad basada en RPM del sensor Hall
    static int contadorRevoluciones = 0;
    static unsigned long tiempoInicioMinuto = millis();
    int lectura = digitalRead(hallSensorPin);

    if (lectura == LOW) {
        contadorRevoluciones++;
        while (digitalRead(hallSensorPin) == HIGH) {} // Espera hasta que el imán se aleje
    }

    unsigned long tiempoActual = millis();
    if (tiempoActual - tiempoInicioMinuto >= 60000) {
        int rpm = contadorRevoluciones;
        contadorRevoluciones = 0;
        tiempoInicioMinuto = tiempoActual;
        return rpm * 0.10472; // Convertir RPM a rad/s
    }
    return 0; // Si no ha pasado un minuto, devolver 0
}

float Temperature() {
    // Leer temperatura
    float temperature = analogRead(PinT);
    return temperature;
}
