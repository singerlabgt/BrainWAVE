/*
  40Hz Audio and Light Flicker Stimuation Code for an Arduino Uno microcontroller

  This code generates 40 Hz flicker during which the light turns on for 12.5 ms and
  then off for 12.5 ms.
  Also plays a 10kHz tone for 12.5 milliseconds every 25 milliseconds (40 Hz, 50% Duty Cycle)

  circuit:
     LED strip lights on digital pin 2
     speaker on digital pin 12

  created 23 Aug 2017
  modifed 27 Jun 2022
  by Matty Attokaren

  http://www.arduino.cc/en/Tutorial/Tone

*/

int LEDpin = 2;  // pin that will output signals to LED strip
int AudioPin = 12; // pin that will output signal to speaker

unsigned long totalTime;
int stimDuration = 3600000;  // flicker stim duration. 3600000 ms = 1 hr

int halfPeriod = 12500;  // 12500 microseconds for 40 Hz w/ 50% duty cycle


void setup() {
  // initialize pins as an outputs
  pinMode(LEDpin, OUTPUT);
  pinMode(AudioPin, OUTPUT);
}


void loop() {
  unsigned long totalTime = millis();

  if ((unsigned long)(totalTime < stimDuration)) // runs stimulation loop for 1 hour
  {
    tone(AudioPin, 10000, 12.5); //Audio Stim: 10KHz tone played for 12.5 milliseconds (for 40 Hz w/ 50% duty cycle)

    digitalWrite(LEDpin, 1);         //Send signal to turn on LED
    delayMicroseconds(halfPeriod);        // Wait 12.5 milliseconds before proceeding to next line of code

    digitalWrite(LEDpin, 0);         // Turns Off LED
    delayMicroseconds(halfPeriod);        // Wait 12.5 milliseconds before proceeding to next line of code
  }
}
