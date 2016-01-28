#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WebSocketsClient.h>

WebSocketsClient webSocket;

char host[100];
const int port = 2500;
char url[100];

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

void webSocketEvent(WStype_t type, uint8_t * payload, size_t lenght) {
    switch(type) {
        case WStype_DISCONNECTED:
            connected = false;
            break;
        case WStype_CONNECTED:
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
    Serial.println();
}

void loop() {  
    if(Serial.available() > 0 && readString(Serial.read())) {
         string = String(buff);
         buff[0] = 0;

         if(string == "AT") {
           Serial.println("OK");
           return;
         }
              
         if(string == "AT:status") {
            if(setuped) {
              Serial.print("connected to ssid:");
              Serial.println(ssid);
            } else {
              Serial.println("disconnected");
            }
            if(connected) {
              Serial.print("connection with host: ");
              Serial.print(host);
              Serial.print(":2500");
              Serial.println(url);
            }
            return;
         }

         if(string == "AT:reset") {
            if(connected) {
              webSocket.disconnect();
              while(connected) {
                delay(10);
              }                
            }
            if(setuped) {
              WiFi.disconnect();
              while (WiFi.status() == WL_CONNECTED) {
                delay(10);
              }
              setuped = false;
            }
            delay(10);
            Serial.println("OK");
            return;
         }

         if(string.startsWith("AT:setup") && !setuped) {
              parseString(string, index1, index2);
              string.substring(index1 + 1, index2).toCharArray(ssid, index2 - index1);
              string.substring(index2 + 1).toCharArray(password, string.length() - index2);
              
              WiFi.begin(ssid, password);
              while (WiFi.status() != WL_CONNECTED) {
                delay(100);
              }
              Serial.println("OK");
              setuped = true;
              return;
         }

         if(string.startsWith("AT:connect") && !connected && setuped) {
              parseString(string, index1a, index2a);
              
              string.substring(index1a + 1, index2a).toCharArray(host, index2a - index1a);
              ("/" + string.substring(index2a + 1)).toCharArray(url, string.length() - index2a + 1);

              
              webSocket.begin(host, 2500, url);
              webSocket.onEvent(webSocketEvent);

              Serial.println("OK");
              connected = true;
              return;
         }

         if(setuped && connected) {
            webSocket.sendTXT(string);
         } else {
            Serial.println("fail");
         }
    }
    if(setuped && connected) {
        webSocket.loop();
    }
}

