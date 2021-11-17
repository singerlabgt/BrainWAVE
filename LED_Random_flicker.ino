/*
 Random
 This code generates randomized flicker during which the light turns on for 12.5 ms and
 then off for a randomized period. Thus the average inter light pulse interval is 25 ms or 40 Hz  

MKA 2/26/21 NO TIMER
 */
 
int LEDPin = 2;
int ranDel;

// the setup routine runs once when you press reset:
void setup() {                
  // initialize pins as an output.

  Serial.begin(9600);
  pinMode(LEDPin, OUTPUT);
  randomSeed(analogRead(0));       
}

void loop() 
{   
// the loop routine runs over and over 5min:
   digitalWrite(LEDPin,1);          //Turns ON Relays 1
   delayMicroseconds(12500);                     // Wait 12.5 milliseconds

   digitalWrite(LEDPin,0);          // Turns Relay Off
   ranDel=random(8,17);
   delay(ranDel);                   // Wait randomized delay that averages 12.5 milliseconds 
}
