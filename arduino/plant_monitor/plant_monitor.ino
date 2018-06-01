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
  lcd.clear();
  
  lcd.setCursor(0, 0);  
  lcd.print("light ");
  lcd.print(lightVal);

  int tempVal = analogRead(pinTemp);
  
  lcd.setCursor(0, 1);  
  lcd.print("temperature ");
  lcd.print(tempVal);

  char str[10], len[10];  
  char *tempStr = itoa(tempVal, str, 10);
  Serial.write("t"); 
  Serial.write(itoa(strlen(tempStr), len, 10)); 
  Serial.write(tempStr); 

  char *lightStr = itoa(lightVal, str, 10);  
  Serial.write("l"); 
  Serial.write(itoa(strlen(lightStr), len, 10)); 
  Serial.write(lightStr); 

  digitalWrite(ledRed, tempVal > 500 ? HIGH : LOW);  
  digitalWrite(ledGreen, lightVal > 500 ? HIGH : LOW);
  digitalWrite(ledBlue, HIGH);
  
  delay(5000);
}
