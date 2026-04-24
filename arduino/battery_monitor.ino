// Battery Monitor — V, I, T
// Sends data to MATLAB via Serial
// Format: voltage,current,temperature

#include <OneWire.h>
#include <DallasTemperature.h>

// Pin definitions
#define VOLTAGE_PIN  A0
#define CURRENT_PIN  A1
#define TEMP_PIN     2

// DS18B20 setup
OneWire oneWire(TEMP_PIN);
DallasTemperature sensors(&oneWire);

// Calibration constants
const float VOLTAGE_RATIO  = 5.1692;  // your calibrated value
const float ZERO_OFFSET    = 2.5122;     // ACS712 zero current offset
const float SENSITIVITY    = 0.1;     // ACS712 20A = 100mV/A

void setup()
{
    Serial.begin(9600);
    sensors.begin();
    delay(1000);
    Serial.println("READY");  // signals MATLAB that Arduino is ready
}

void loop()
{
    // Read voltage
    int rawV = analogRead(VOLTAGE_PIN);
    float voltage = (rawV / 1023.0) * 5.0 * VOLTAGE_RATIO;

    // Read current
    int rawI = analogRead(CURRENT_PIN);
    float current = ((rawI / 1023.0) * 5.0 - ZERO_OFFSET) / SENSITIVITY;
// Filter small noise — ignore readings below 50mA
if(abs(current) < 0.05)
{
    current = 0.0;
}

    // Read temperature
    sensors.requestTemperatures();
    float temperature = sensors.getTempCByIndex(0);

    // Send to MATLAB as comma separated values
    Serial.print(voltage, 4);
    Serial.print(",");
    Serial.print(current, 4);
    Serial.print(",");
    Serial.println(temperature, 2);

    delay(1000);  // 1 second between readings
}