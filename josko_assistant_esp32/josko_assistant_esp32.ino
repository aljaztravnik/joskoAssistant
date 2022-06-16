#include <WiFi.h>
#include <EEPROM.h>
#include "time.h"
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define COMMAND_SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define COMMAND_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
std::string podatki[] = {"", "", "", "", ""};
BLEServer* pServer = NULL;
BLECharacteristic* p_command_characteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
bool initData = false;
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 3600;
const int daylightOffset_sec = 3600;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device connected");
      BLEDevice::startAdvertising();
    };
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks
{
  void togglePin(int pin, bool vrednost)
  {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, vrednost);
    Serial.println("TOGGLE PIN");
  }
  
  void toggleMusic(int worthless, bool vrednost)
  {
    Serial.println("TOGGLE MUSIC");
  }

  void tellTheTime(int worthless, bool worthless2)
  {
    Serial.println("TELL THE TIME");
    configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
    struct tm timeinfo;
    if(!getLocalTime(&timeinfo)){
      Serial.println("Failed to obtain time");
      return;
    }
    Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
  }
  
  void naredKej(const char ukaz[], int n)
  {
    typedef void (MyCallbacks::*ScriptFunction)(int, bool);
    ScriptFunction arrayFunkcij[] = {  
      &MyCallbacks::togglePin,        // light
      &MyCallbacks::toggleMusic,      // music
      &MyCallbacks::tellTheTime       // time
    }; /* ta array more na koncu met samo 3 elemente
          togglePin, toggleMusic, toggleTime
       */

    int ukazDeli[3]; // function, value, pin
    int st = 0, j = 0;
    for(int i = 0; i < n; i++)
    {
      if(ukaz[i] == ' ')
      {
        ukazDeli[j] = st;
        j++;
        st = 0;
      }
      else
      {
        st *= 10;
        st += ukaz[i] - '0';
      }
    }
    ukazDeli[j] = st;

    for(int i = 0; i < 3; i++)
    {
      Serial.print("Stevilka ");
      Serial.print(i+1);
      Serial.print(": ");
      Serial.println(ukazDeli[i]);
    }

    MyCallbacks a;
    (a.*arrayFunkcij[ukazDeli[0]])(ukazDeli[2], (bool)ukazDeli[1]);
  }
  
  void onWrite(BLECharacteristic* pCharacteristic)
  {
    std::string rxValue = pCharacteristic->getValue();
    if(rxValue.size() > 0)
    {
      Serial.print("Received: ");
      Serial.println(rxValue.c_str());
      if((rxValue.find("initData") != std::string::npos) && !initData)
      {
        Serial.println("Dobil init");
        bool prepisuj = false;
        int j = 0;
        for(int i = 0; i < rxValue.size(); ++i)
        {
          if(rxValue[i] == ','){
            if(prepisuj) j++;
            else prepisuj = true;
          }
          else if(prepisuj) podatki[j] += rxValue[i];
        }
        if(j == 1)
        {
          writeSsidPword();
          initData = true;
          WiFi.begin(podatki[0].c_str(), podatki[1].c_str());
        }
      }
      else if(rxValue.find("user") != std::string::npos)
      {
        Serial.println("Dobil login");
        bool prepisuj = false;
        std::string tempUser = "";
        for(int i = 0; i < rxValue.size(); ++i)
        {
          if(rxValue[i] == ',') prepisuj = true;
          else if(prepisuj) tempUser += rxValue[i];
        }
        if(tempUser.size() > 0)
        {
          int res = loginStuff(tempUser);
          // posli nazaj login result
        }
        else Serial.println("Brez UserID");
      }
      else if(initData) naredKej(rxValue.c_str(), rxValue.size());
    }
    else Serial.println("Received nothing");
  }

  void writeSsidPword()
  {
    for(int i = 0; i < podatki[0].size(); ++i)
      EEPROM.write(i, podatki[0][i]);
    for(int i = 0; i < podatki[1].size(); i++)
      EEPROM.write(32 + i, podatki[1][i]);
    EEPROM.commit();
  }

  int loginStuff(std::string login)
  {
    std::string users[] = {"", "", ""};
    int koliko = 0, i = 64, meja = 96;
    char tmp;
    for(int j = 0; j < 3; j++)
    {
      for(i; i < meja; i++)
      {
        tmp = EEPROM.read(i);
        if(tmp == 255) break;
        users[j] += (char)tmp;
      }
      if(login == users[j]) return 1; // uspesen navaden login
      i = meja;
      meja += 32;
    }

    for(int k = 0; k < 3; k++)
      if(users[k].size() > 0) koliko++;

    if(koliko == 3) return 0; // vsa mesta so polna in ni blo prej matcha
    else
    {
      for(int k = 0; k < login.size(); k++)
      {
        EEPROM.write((64 + (koliko*32) + k), login[k]);
      }
      EEPROM.commit();
      return (koliko == 0) ? 2 : 1; // vrne 2 (admin) ali pa 1 (navaden login)
    }
  }
};

void setup()
{
  Serial.begin(115200);

  EEPROM.begin(512);
  readData();

  if(initData)
  {
    WiFi.begin(podatki[0].c_str(), podatki[1].c_str());
    connectWiFi();
  }

  bleInit();
}

void loop()
{
  if(initData)
  {
    if(WiFi.status() != WL_CONNECTED) connectWiFi();
  }
}

void readData()
{
  int j = 0, meja = 32;
  for(int i = 0; i < 5; i++)
  {
    for(j; j < meja; j++)
    {
      int tmp = EEPROM.read(j);
      if(tmp == 255) break;
      podatki[i] += (char)tmp;
    }
    j = meja;
    meja += 32;
  }
    
  Serial.print("PREBRAL SSID: ");
  Serial.println(podatki[0].c_str());
  Serial.print("PWORD: ");
  Serial.println(podatki[1].c_str());
  Serial.print("USER 1: ");
  Serial.println(podatki[2].c_str());
  Serial.print("USER 2: ");
  Serial.println(podatki[3].c_str());
  Serial.print("USER 3: ");
  Serial.println(podatki[4].c_str());

  if(podatki[0][0] != 255 && podatki[1][0] != 255) initData = true;
  else initData = false;
}

void connectWiFi()
{
  Serial.println("Connecting");
  while(WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to: ");
  Serial.println(WiFi.localIP());
}

void bleInit()
{
  BLEDevice::init("Josko asistent");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pCommandService = pServer->createService(COMMAND_SERVICE_UUID);
  p_command_characteristic = pCommandService->createCharacteristic(
    COMMAND_CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ   |
    BLECharacteristic::PROPERTY_WRITE  |
    BLECharacteristic::PROPERTY_NOTIFY |
    BLECharacteristic::PROPERTY_INDICATE);
  p_command_characteristic->addDescriptor(new BLE2902());
  p_command_characteristic->setCallbacks(new MyCallbacks());
  pCommandService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(COMMAND_SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();
}
