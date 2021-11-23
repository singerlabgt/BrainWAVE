/*
  40Hz Audio and Light Flicker

  This code generates 40 Hz flicker during which the light turns on for 12.5 ms and
  then off for 12.5 ms.
  Also plays a 10kHz tone for 12.5 millisecond every 25 milliseconds (40 Hz, 50% Duty Cycle)

  circuit:
   8-ohm speaker on digital pin 8
   LED strip Lights on digital pin 13

  created 23 Aug 2017
  modifed 19 Feb 2018
  by Matty Attokaren

  http://www.arduino.cc/en/Tutorial/Tone

*/

int LEDpin = 2;  // Set pin that will output signals to LED strip
int AudioPin = 12; //Set pin that will output signal to speaker
unsigned long previousTime = 0;
unsigned long totalTime;
int ranDel;
int halfPeriod = 10550;


void setup() {
  // initialize pins as an output. (Light Flicker)
  //Serial.begin(9600);
  pinMode(LEDpin, OUTPUT);
  pinMode(AudioPin, OUTPUT);
}

void loop() {
  unsigned long totalTime = millis();

  if ((unsigned long)(totalTime < 3600000))
  {
    //Audio 10KHz tone played at 40Hz for 12.5 millisecond
    // Speaker should be connected to pin 12
    tone(AudioPin, 10000, 12.5);

    digitalWrite(LEDpin, 1);         //Sned signal to turn on LED
   // Serial.println("Light ON");
    delayMicroseconds(halfPeriod);        // Wait 12.5 milliseconds

    digitalWrite(LEDpin, 0);         // Turns Relay Off
   // Serial.println("Light OFF");
    delayMicroseconds(halfPeriod+1800);        // Wait 12.5 milliseconds
  }
}
