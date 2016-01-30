#ifndef EnigneStep_h
#define EngineStep_h

#include "Engine.h"

class EngineStep
{
  public:
    EngineStep(Engine* engine);
    void command(String command);
  private:
    void forward();
    void revert();
    void left();
    void right();
    Engine* _engine;
    const int defaultSpeed = 150;
};

#endif

