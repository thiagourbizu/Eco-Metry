// Definimos el pin donde conectaremos el sensor Hall
const int hallSensorPin = GPIO9;  // Pin analógico para el sensor

// Variables para contar las veces que pasa el imán
int contadorRevoluciones = 0;  // Contador que se reinicia cada minuto para calcular las RPM

// Variable para manejar el tiempo de la última detección
unsigned long ultimoTiempo = 0;
unsigned long tiempoInicioMinuto = 0;  // Para medir un minuto

void setup() {
  // Inicializamos la comunicación serial
  Serial.begin(115200);
  
  // Inicializamos el pin del sensor como entrada
  pinMode(hallSensorPin, INPUT);
  
  // Guardamos el tiempo de inicio
  tiempoInicioMinuto = millis();
  
  Serial.println("Esperando detecciones del imán...");
}

void loop() {
  // Leemos el valor analógico del sensor
  int valor = digitalRead(hallSensorPin);
  
  // Obtener el tiempo actual
  unsigned long tiempoActual = millis();

  // Si el valor analógico es menor que el umbral y ha pasado suficiente tiempo desde la última detección
  if (valor == LOW) {
    // Incrementamos el contador total y el de revoluciones
    contadorRevoluciones++;
    
    // Actualizamos el tiempo de la última detección
    ultimoTiempo = tiempoActual;
    while(true)
    {
      //Serial.println(".");
      if(digitalRead(GPIO9) == HIGH)
        break;
    }
    
    // Imprimimos que se ha detectado el imán
    Serial.print("Detección! El imán ha pasado ");
    Serial.print(contadorRevoluciones);
    Serial.println(" veces.");
  }
  
  // Verificamos si ha pasado un minuto (60,000 ms)
  if (tiempoActual - tiempoInicioMinuto >= 60000) {
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
