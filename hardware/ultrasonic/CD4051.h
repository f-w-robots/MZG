#ifndef CD4051_h
#define CD4051_h

class CD4051
{
  public:
    CD4051(uint8_t pin0, uint8_t pin1, uint8_t pin2);
    void switchInput(uint8_t number);
    int read();
  private:
    uint8_t _pins[3];
};

#endif

