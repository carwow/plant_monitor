#include <Wire.h>
#include "rgb_lcd.h"


rgb_lcd lcd;

const int colorR = 0;
const int colorG = 255;
const int colorB = 0;
const int pinLight = A0; 
const int pinTemp = A1; 
const int ledRed = 4;
const int ledGreen = 5;
const int ledBlue = 6;

void setup() {
  Serial.begin(9600);
  
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
    
  lcd.setRGB(colorR, colorG, colorB);
    
  pinMode(ledRed, OUTPUT);
  pinMode(ledGreen, OUTPUT);
  pinMode(ledBlue, OUTPUT);

  digitalWrite(ledRed, LOW);
  digitalWrite(ledGreen, LOW);
  digitalWrite(ledBlue, LOW);
  
  delay(1000);
}

void loop() {
  int lightVal = analogRead(pinLight);
  
  lcd.setCursor(0, 0);
  lcd.print(lightVal);

  int tempVal = analogRead(pinTemp);
  
  lcd.setCursor(0, 1);
  lcd.print(tempVal);

  Serial.print("temperature value ");
  Serial.println(tempVal);
  Serial.print("light value ");
  Serial.println(lightVal);
  
  digitalWrite(ledGreen, tempVal > 530 ? HIGH : LOW);  
  digitalWrite(ledRed, lightVal > 500 ? HIGH : LOW);
  digitalWrite(ledBlue, HIGH);
  
  delay(100);
}
