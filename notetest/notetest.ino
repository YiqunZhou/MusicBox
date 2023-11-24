int buzzerPin = 9;
//import the library that can read notes
#include "pitches.h"
// this array provide the notes that processing calls from
int melody[] = { NOTE_C5, NOTE_B4,NOTE_A4,NOTE_G4,NOTE_F4,NOTE_E4,NOTE_D4,NOTE_C4};

void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available() > 0) {
    // listen to processing
    int frequency = Serial.parseInt();
    // play the note by the command of processing
    tone(buzzerPin, melody[frequency]);
  
  }
    else{
    noTone(buzzerPin);
  }
}