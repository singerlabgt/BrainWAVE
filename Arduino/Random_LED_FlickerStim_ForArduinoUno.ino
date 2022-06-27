/*
 Random Flicker Stimuation Code
 This code generates randomized flicker during which the light turns on for 12.5 ms and
 then off for a randomized period. Thus the inter light pulse interval averages 12.5 which corresponds ot the average inter light pulse internal of a regular 40 Hz  

 circuit:
     LED strip lights on digital pin 2
     speaker on digital pin 12
     
  modifed 27 Jun 2022
  by Matty Attokaren
 */
 
int LEDPin = 2;
int ranDel;

// the setup routine runs once when you power the Arduino or press the reset button:
void setup() {                
  // initialize pin as an output
  pinMode(LEDPin, OUTPUT);
  randomSeed(analogRead(0));       
}

void loop() 
{   
// the loop routine runs over and over 5min:
   digitalWrite(LEDPin,1);          //Turns ON Relays 1
   delayMicroseconds(12500);        // Wait 12.5 milliseconds

   digitalWrite(LEDPin,0);          // Turns Relay Off
   ranDel=random(0,25);
   delay(ranDel);                   // Wait randomized delay that averages 12.5 milliseconds 
}
