#include <DHT.h>

#define DHTTYPE DHT11
#define DHTPIN GPIO8

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();
}

void loop(){
  float humidity = dht.readHumidity();
  float temp = dht.readTemperature();

  if(isnan(humidity) || isnan(temp))
  {
    Serial.println("Error 404.");
    return;
  }

  Serial.print(humidity);
  Serial.print("% ");
  Serial.print(temp);
  Serial.println("°C");
 
}
