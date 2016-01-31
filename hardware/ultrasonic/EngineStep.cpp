#include "Arduino.h"
#include "EngineStep.h"

// ENA, EN1, EN2, EN3, EN4, ENB
EngineStep::EngineStep(Engine *engine)
{
  _engine = engine;
}

void EngineStep::command(String command) {
  if(command == "rf") {
    right();
    forward();
  } else if(command == "lf") {
    left();
    forward();
  } else if(command == "f") {
    forward();    
  } else if(command == "r") {
    right();
  } else if(command == "l") {
    left();
  } else if(command == "s") {
    revert();
  }
}

void EngineStep::forward() {
  _engine->rightSpeed(defaultSpeed);
  _engine->leftSpeed(defaultSpeed);
  delay(950);
  _engine->stop();
}

void EngineStep::right() {
  _engine->leftSpeed(defaultSpeed);
  delay(900);
  _engine->stop();
}

void EngineStep::left() {
  _engine->rightSpeed(defaultSpeed);
  delay(900);
  _engine->stop();
}

void EngineStep::revert() {
  _engine->rightSpeed(defaultSpeed);
  _engine->leftSpeed(-defaultSpeed);
  delay(1200);
  _engine->stop();
}
