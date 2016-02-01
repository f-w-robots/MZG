#ifndef SR04_h
#define SR04_h

#include "Arduino.h"

class SR04
{
  public:
    SR04(int trig, int echo);
    long distance();

  private:
    int _trig;
    int _echo;    
};

#endif

