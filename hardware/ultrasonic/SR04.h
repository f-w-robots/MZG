#ifndef SR04_h
#define SR04_h

#include "Arduino.h"

class SR04
{
  public:
    SR04(uint8_t trig, uint8_t echo);
    unsigned int distance();

  private:
    uint8_t _trig;
    uint8_t _echo;
};

#endif

