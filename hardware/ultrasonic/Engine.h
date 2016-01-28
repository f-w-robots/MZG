#ifndef Enigne_h
#define Engine_h

class Engine
{
  public:
    Engine(int ena, int en1, int en2, int en3, int en4, int enb);
    void rightSpeed(int speed);
    void leftSpeed(int speed);
    void stop();
  private:
    void rightDirection(boolean direction);
    void leftDirection(boolean direction);
    byte _ena;
    byte _en1;
    byte _en2;
    byte _en3;
    byte _en4;
    byte _enb;
};

#endif

