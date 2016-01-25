#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include <WebSocketsClient.h>

#include <Hash.h>

ESP8266WiFiMulti WiFiMulti;
WebSocketsClient webSocket;

char host[100];
const int port = 2500;
char sha[100];

boolean setuped = false;
boolean connected = false;

int i = 0;

int index1 = -1;
int index2 = -1;

// TODO - use index1, index1
int index1a = -1;
int index2a = -1;

char ssid[100];
char password[100];

// Read String variables
String string = "";
String tmpstring = "";
char last_byte = 0;

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

void webSocketEvent(WStype_t type, uint8_t * payload, size_t lenght) {
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.println("Disconnected");
            connected = false;
            break;
        case WStype_CONNECTED:;
            Serial.println("Connected");
            break;
        case WStype_TEXT:
            Serial.printf("%s\n", payload);
            break;
        case WStype_BIN:
//            USE_SERIAL.printf("[WSc] get binary lenght: %u\n", lenght);
            break;
    }

}

void parseString(String stringx, int &i1, int &i2) {
  i1 == -1;
  i2 == -1;
  for(i = 0; i<= stringx.length(); i++) {
    if(stringx[i] == '+' && i1 == -1)
      i1 = i;
    if(stringx[i] == '+' && i1 != -1)
      i2 = i;
  }
}

void setup() {
    Serial.begin(9600);
    delay(1000);
    Serial.println("ESP8266 loaded");
}

void loop() {  
    if(Serial.available() > 0 && readString(tmpstring, Serial.read(), last_byte)) {
         string = tmpstring;
         tmpstring = "";
         if(string == "AT")
              Serial.println("OK");

         if(string.startsWith("AT:setup") && !setuped) {
              parseString(string, index1, index2);
              string.substring(index1 + 1, index2).toCharArray(ssid, index2 - index1);
              string.substring(index2 + 1).toCharArray(password, string.length() - index2);
              
              WiFiMulti.addAP(ssid, password);

              while(WiFiMulti.run() != WL_CONNECTED) {
                delay(100);
              }
              Serial.println("OK");
              setuped = true;
         }

         if(string.startsWith("AT:connect") && !connected && setuped) {
              parseString(string, index1a, index2a);
              
              string.substring(index1a + 1, index2a).toCharArray(host, index2a - index1a);
              string.substring(index2a + 1).toCharArray(sha, string.length() - index2a);
              
              webSocket.begin(host, 2500, strcat("/", sha));
              webSocket.onEvent(webSocketEvent);

              Serial.println("OK");
              connected = true;
         }

         if(setuped && connected) {
            webSocket.sendTXT(string);
         }
    }
    if(setuped && connected) {
        webSocket.loop();
    }
}

