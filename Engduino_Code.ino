#include <EngduinoAccelerometer.h>
#include <EngduinoButton.h>
#include <Wire.h>
float trigger = 0.75;
void setup() {
  // put your setup code here, to run once:
  EngduinoAccelerometer.begin();
  EngduinoButton.begin();
  Serial.begin(9600);
}
bool switchOnOff = false;
boolean onX = false;
boolean onY = true;
void loop() {
  // put your main code here, to run repeatedly:
  int reading = Serial.read();
  if (reading == 1)
  {
    switchOnOff = !switchOnOff;
  }
  if (switchOnOff)
  {
    float outPut[3];
    EngduinoAccelerometer.xyz(outPut);
    if (abs(outPut[0]) > abs(outPut[1]) && abs(outPut[0]) > trigger && !onX)
    {
      onX = true;
      onY = false;
      if (outPut[0] < 0 )
      {
        Serial.print("down.");
      }
      else
      {
        Serial.print("up.");
      }
    }
    else if (abs(outPut[1]) > abs(outPut[0]) && abs(outPut[1]) > trigger && !onY)
    {
      onX = false;
      onY = true;
      if (outPut[1]<0)
      {
        Serial.print("left.");
      }
      else
      {
        Serial.print("right.");
      }
    }
  }
  else
  {
    Serial.println("OFF.");
  }
  delay(5);
}
