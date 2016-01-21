/*
 * Connect to server by web socket
 * and control 1-digit display depend lightresistor value
 * 
 * ruby code:
  hash = {
    0 => "01111110",
    1 => "01001000",
    2 => "10111100",
    3 => "11101100",
    4 => "11001010",
    5 => "11100110",
    6 => "11110110",
    7 => "01001100",
    8 => "11111110",
    9 => "11101110",
  }
  hash.each{|k,v|hash[k]=v.to_i(2).to_s}

  case msg.to_i
  when 0..50
    hash[0]
  when 50..100
    hash[1]
  when 100..150
    hash[2]
  when 150..200
    hash[3]
  when 200..250
    hash[4]
  when 250..300
    hash[5]
  when 300..350
    hash[6]
  when 300..350
    hash[7]
  when 300..350
    hash[8]
  else
    hash[9]
  end
 * 
 * 
 */
 
#include "Arduino.h"
#include <WiFi.h>
#include <SPI.h>
#include <WebSocketClient.h>

char ssid[] = "kernel";
char pass[] = "axtr456E";

char server[] = "192.168.1.2";
char path[] = "/testsha";
int port = 2500;
WebSocketClient client;

const int DATA = 8;
const int CLK = 6;
const int LATCH = 5;
const int LIGHT = A3;

boolean sendUpdate = true;

void setup() {
  pinMode(DATA, OUTPUT);
  pinMode(LATCH, OUTPUT);
  pinMode(CLK, OUTPUT);
  updateNum(0);

  SocketConnect();
}

void loop() {
  client.catchMessages();
  if(sendUpdate == true) {
    sendUpdate = false;
    client.sendMessage(String(getLight()));
  }
}

void dataArrived(WebSocketClient client, String data) {
  updateNum(data.toInt());
  sendUpdate = true;
}

void SocketConnect() {
  WiFi.begin(ssid, pass);
  client.connect(server, path, port);
  client.setDataArrivedDelegate(dataArrived);
}

void updateNum(byte n) {
  digitalWrite(LATCH, LOW);
  shiftOut(DATA, CLK, MSBFIRST, n);
  digitalWrite(LATCH, HIGH);
}

int getLight() {
  return analogRead(LIGHT);
}

