/*
 * Use esp8266 through serial(software)
 * send messages to server and print response into default Serial
 */

#include <SoftwareSerial.h>

// 
String host = "192.168.1.2";
String sha = "sha1";
String ssid = "ssid";
String password = "password";

SoftwareSerial sw(11, 10);

boolean conn = false;
boolean conn1 = false;

// Read String variables
String string;
char buff[255] = "";

boolean readString(char b) {
  int len = strlen(buff);

  if(len >= 255) {
    return true;
  }

  if(b == 0x0A) {
    if(len > 0 && buff[len - 1] == 0x0D) {
      buff[len - 1] = 0;
      return true;
    }
  } else {
    buff[len] = b;
    buff[len + 1] = 0;
    return false;
  }
}

void setup() {
  Serial.begin(9600);
  sw.begin(9600);
}

void loop() {
  if(conn1) {
    if(Serial.available() > 0 )
      sw.write(Serial.read());
    if(sw.available() > 0 )
      Serial.write(sw.read());
    return;
  }
  
  if(!conn) {
    Serial.println("try eps");
    sw.println("AT:reset");
    delay(200);
    while(sw.available()>0) {
      if(readString(sw.read())) {
        string = String(buff);
         buff[0] = 0;
         
        if(string == "OK") {
          conn = true;
        }
      }  
      delay(10);
    }
    return;
  }
  
  if(conn) {
    delay(100);
    Serial.println("try wifi");
    sw.println("AT:setup+" + ssid + "+" + password);
    string = "";
    while(string != "OK") {
      if(sw.available()>0){
        if(readString(sw.read())) {
          string = String(buff);
          buff[0] = 0;
        }        
      }
      delay(1000);
    }
    sw.println("AT:connect+" + host + "+" + sha);
    Serial.println("AT:connect+" + host + "+" + sha);
    string = "";
    Serial.println("try connect");
    while(string != "OK") {
      if(sw.available()>0){
        if(readString(sw.read())) {
          string = String(buff);
          buff[0] = 0;
        }        
      }
      delay(10);
    }
    conn1 = true;   
    return;
  }
}

