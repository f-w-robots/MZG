const uint8_t pinC = 7;
const uint8_t pinB = 6;
const uint8_t pinA = 5;

int xvalues[2][8] = {
  {-1, -1, -1, -1, -1, -1, -1, -1},
  {-1, -1, -1, -1, -1, -1, -1, -1}
};

void readCD4051(int values[][8], int count = 1) {
  digitalWrite(pinC, LOW);
  digitalWrite(pinB, LOW);
  digitalWrite(pinA, LOW);   
  values[0][0] = analogRead(A0);
  values[1][0] = analogRead(A1);

  digitalWrite(pinC, LOW);
  digitalWrite(pinB, LOW);
  digitalWrite(pinA, HIGH);
  values[0][1] = analogRead(A0);
  values[1][1] = analogRead(A1);

  digitalWrite(pinC, LOW);
  digitalWrite(pinB, HIGH);
  digitalWrite(pinA, LOW);
  values[0][2] = analogRead(A0);
  values[1][2] = analogRead(A1);

  digitalWrite(pinC, LOW);
  digitalWrite(pinB, HIGH);
  digitalWrite(pinA, HIGH);
  values[0][3] = analogRead(A0);
  values[1][3] = analogRead(A1);

  digitalWrite(pinC, HIGH);
  digitalWrite(pinB, LOW);
  digitalWrite(pinA, LOW);
  values[0][4] = analogRead(A0);
  values[1][4] = analogRead(A1);

  digitalWrite(pinC, HIGH);
  digitalWrite(pinB, LOW);
  digitalWrite(pinA, HIGH);
  values[0][5] = analogRead(A0);
  values[1][5] = analogRead(A1);

  digitalWrite(pinC, HIGH);
  digitalWrite(pinB, HIGH);
  digitalWrite(pinA, LOW);
  values[0][6] = analogRead(A0);
  values[1][6] = analogRead(A1);

  digitalWrite(pinC, HIGH);
  digitalWrite(pinB, HIGH);
  digitalWrite(pinA, HIGH);
  values[0][7] = analogRead(A0);
  values[1][7] = analogRead(A1);

}

void setup()
{
  Serial.begin(9600);

  pinMode(pinC, OUTPUT);
  pinMode(pinB, OUTPUT);
  pinMode(pinA, OUTPUT);
}

void loop()
{
  readCD4051(xvalues, 2);
  
  for(int i = 0; i < 8; i++) {
    Serial.print(xvalues[0][i]);
    Serial.print(" ");
  }
  Serial.print(" - ");

  for(int i = 0; i < 8; i++) {
    Serial.print(xvalues[1][i]);
    Serial.print(" ");
  }
  Serial.println();

  delay(1000);

}
