#include "Arduino.h"
#include "Engine.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine::Engine(uint8_t ena, uint8_t en1, uint8_t en2, uint8_t en3, uint8_t en4, uint8_t enb)
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
//  if(speed > 35)
//    speed = speed * 1.142;
//  if(speed < -35)
//    speed = speed * -1.142;
  digitalWrite(_ena,LOW);
  if(speed > -1) {
    rightDirection(true);
    analogWrite(_ena, speed);
  } else {
    rightDirection(false);
    analogWrite(_ena, abs(speed));
  }
}

void Engine::leftSpeed(int speed)
{
  digitalWrite(_enb,LOW);
  if(speed > -1) {
    leftDirection(true);
    analogWrite(_enb, speed);
  } else {
    leftDirection(false);
    analogWrite(_enb, abs(speed));
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

