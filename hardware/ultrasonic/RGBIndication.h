#ifndef RGBIndication_h
#define RGBIndication_h

class RGBIndication
{
  public:
    RGBIndication(uint8_t red, uint8_t green, uint8_t blue);
    void power();
    void error();
    void connection();
  private:
    uint8_t _red;
    uint8_t _green;
    uint8_t _blue;
};

#endif

