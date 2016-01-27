#include "Arduino.h"
#include "Engine.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine::Engine(int ena, int en1, int en2, int en3, int en4, int enb)
{
  _ena = ena;
  _en1 = en1;
  _en2 = en2;
  _en3 = en3;
  _en4 = en4;
  _enb = enb;

 pinMode(_ena,OUTPUT);
 pinMode(_enb,OUTPUT);
 pinMode(_en1,OUTPUT);
 pinMode(_en2,OUTPUT);
 pinMode(_en3,OUTPUT);
 pinMode(_en4,OUTPUT);
 stop(); 
 rightDirection(true);
 leftDirection(true);
}

void Engine::stop() {
 digitalWrite(_ena,LOW);
 digitalWrite(_enb,LOW);
}


void Engine::rightSpeed(int speed)
{
  digitalWrite(_ena,LOW);
  if(speed > -1) {
    rightDirection(true);
    digitalWrite(_ena, speed);
  } else {
    rightDirection(false);
    digitalWrite(_ena, abs(speed));
  }
}

void Engine::leftSpeed(int speed)
{
  digitalWrite(_enb,LOW);
  if(speed > -1) {
    rightDirection(true);
    digitalWrite(_enb, speed);
  } else {
    rightDirection(false);
    digitalWrite(_enb, abs(speed));
  }
}

// true - forward, false - back
void Engine::rightDirection(boolean direction) {
  if(direction) {
    digitalWrite(_en1,LOW);
    digitalWrite(_en2,HIGH);
  } else {
    digitalWrite(_en1,HIGH);
    digitalWrite(_en2,LOW);
  }
}

void Engine::leftDirection(boolean direction) {
  if(direction) {
    digitalWrite(_en3,LOW);
    digitalWrite(_en4,HIGH);
  } else {
    digitalWrite(_en3,HIGH);
    digitalWrite(_en4,LOW);
  }
}  

