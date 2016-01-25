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
String string = "";
String tmpstring = "";
char last_byte = 0;

void setup() {
  Serial.begin(9600);
  sw.begin(9600);
}

boolean readString(String &str, char b, char &last_byte) {
  if(b == 0x0D) {
    last_byte = 0x0D;
    return false;
  }
  if(b == 0x0A && last_byte == 0x0D) {
    last_byte = 0;
    return true;
  } else {
    str += b;
    return false;
  }
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
    sw.println("AT");
    delay(100);
    while(sw.available()>0) {
      if(readString(tmpstring, sw.read(), last_byte)) {
        string = tmpstring;
        tmpstring = "";
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
        readString(string, sw.read(), last_byte);
      }
      delay(10);
    }
    sw.println("AT:connect+" + host + "+" + sha);
    string = "";
    while(string != "OK") {
      if(sw.available()>0){
        readString(string, sw.read(), last_byte);
      }
      delay(10);
    }
    conn1 = true;   
    return;
  }
}

