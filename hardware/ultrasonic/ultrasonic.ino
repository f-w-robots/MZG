#include "Engine.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine engine(3, 2, 4, 5, 7, 6);

void setup()
{
 
}
void loop()
{
  engine.rightSpeed(255);
  engine.leftSpeed(255); 
}
