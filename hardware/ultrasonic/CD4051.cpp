#include "Arduino.h"

#include "CD4051.h"

CD4051::CD4051(uint8_t pin0, uint8_t pin1, uint8_t pin2) {
  _pins[0] = pin0;
  pinMode(pin0, OUTPUT);
  _pins[1] = pin1;
  pinMode(pin1, OUTPUT);
  _pins[2] = pin2;
  pinMode(pin2, OUTPUT);
}

void CD4051::switchInput(uint8_t number) {
  uint8_t i = 0;
  uint8_t m = 0;

  while(i < 3) {
    m = number % 2;
    number = number / 2;
    digitalWrite(_pins[i], m);
    
    i++;
  }
}


