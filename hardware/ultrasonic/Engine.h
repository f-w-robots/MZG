#ifndef Enigne_h
#define Engine_h

class Engine
{
  public:
    Engine(uint8_t ena, uint8_t en1, uint8_t en2, uint8_t en3, uint8_t en4, uint8_t enb);
    void rightSpeed(int speed);
    void leftSpeed(int speed);
    void stop();
  private:
    void rightDirection(boolean direction);
    void leftDirection(boolean direction);
    uint8_t _ena;
    uint8_t _en1;
    uint8_t _en2;
    uint8_t _en3;
    uint8_t _en4;
    uint8_t _enb;
};

#endif

