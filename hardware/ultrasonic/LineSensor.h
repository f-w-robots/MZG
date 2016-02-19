#include "CD4051.h"

#ifndef LineSensor_h
#define LineSensor_h

class LineSensor
{
  public:
    LineSensor(uint8_t pin0, uint8_t pin1, uint8_t pin2, uint8_t analog);
    void readSensors();
    String printSensors();
    int sensorsPosition();
  private:
    int correctPath(boolean v0, boolean vc, boolean vr, boolean vl, boolean vr2, boolean vl2);
    uint8_t _pins[3];
    uint8_t _analog;
    int _sensors[6];
    CD4051* _cd4051;
    int _sensorsColibration[6] = {90, 97, 134, 155, 75, 73};
};

#endif

