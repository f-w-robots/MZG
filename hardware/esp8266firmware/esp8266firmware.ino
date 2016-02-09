#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WebSocketsClient.h>

WebSocketsClient webSocket;

char host[100];
uint16_t port = 0;
char url[100];

boolean setuped = false;
boolean connected = false;
int timeout = 0;

int i = 0;

int indexA = -1;
int indexB = -1;

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
            connected = true;
            break;
        case WStype_TEXT:
            Serial.printf("%s\r\n", payload);
            break;
        case WStype_BIN:
//            USE_SERIAL.printf("[WSc] get binary lenght: %u\n", lenght);
            break;
    }

}

int parseString(String string, int index1) {
  for(i = index1; i<= string.length(); i++) {
    if(string[i] == '+')
      return i;
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
            }
            if(setuped) {
              WiFi.disconnect();
            }
            if(WiFi.status() == WL_CONNECTED || connected)
              Serial.println("FAIL:reset");
            else {
              Serial.println("OK");
              setuped = false;
            }

            return;
         }

         if(string.startsWith("AT:setup") && !setuped) {
              indexA = parseString(string, 0);
              indexB = parseString(string, indexA + 1);
              string.substring(indexA + 1, indexB).toCharArray(ssid, indexB - indexA);
              string.substring(indexB + 1).toCharArray(password, string.length() - indexB);

              WiFi.begin(ssid, password);
              while (WiFi.status() != WL_CONNECTED && timeout < 100) {
                delay(100);
                timeout += 1;
              }
              if(WiFi.status() == WL_CONNECTED) {
                Serial.println("OK");
                setuped = true;
              } else {
                Serial.println("FAIL: WiFi up");
              }

              return;
         }

         if(string.startsWith("AT:connect") && !connected && setuped) {
              indexA = parseString(string, 0);
              indexB = parseString(string, indexA + 1);
              string.substring(indexA + 1, indexB).toCharArray(host, indexB - indexA);
              indexA = parseString(string, indexB + 1);
              port = string.substring(indexB + 1, indexA).toInt();
              string.substring(indexA + 1).toCharArray(url, string.length() - indexA);
              
              webSocket.begin(host, port, url);
              webSocket.onEvent(webSocketEvent);

              timeout = 0;
              while(!connected) {
                webSocket.loop();
                delay(10);
                timeout += 1;
                if(timeout > 100) {
                  Serial.println("FAIL: can't be connected");
                  return;
                }
              }
              Serial.println("OK");

              return;
         }

         if(setuped && connected) {
            webSocket.sendTXT(string);
         } else {
            Serial.println("FAIL: disconnected");
         }
    }
    if(setuped && connected) {
        webSocket.loop();
    }
}

