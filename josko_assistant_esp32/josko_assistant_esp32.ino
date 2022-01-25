#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define COMMAND_SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define COMMAND_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
const char* ssid = "Telemach-8a1e";
const char* password = "polica20a";
BLEServer* pServer = NULL;
BLECharacteristic* p_command_characteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
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
  }
  
  void naredKej(const char ukaz[])
  {
    typedef void (MyCallbacks::*ScriptFunction)(int, bool);
    int pini[] = {2, 3, 99, 99, 99}; // light, computer
    ScriptFunction arrayFunkcij[] = {
      &MyCallbacks::togglePin,        // light
      &MyCallbacks::togglePin,        // computer
      &MyCallbacks::toggleMusic,      // song
      &MyCallbacks::toggleMusic,      // music
      &MyCallbacks::tellTheTime       // time
    };

    int ukazInt[2] = {ukaz[0] - '0', ukaz[2] - '0'};
    
    Serial.print("Prva stevilka: ");
    Serial.print(ukazInt[0]);
    Serial.print(", druga stevilka: ");
    Serial.println(ukazInt[1]);

    MyCallbacks a;
    (a.*arrayFunkcij[ukazInt[0]])(pini[ukazInt[0]], (bool)ukazInt[1]);
  }
  
  void onWrite(BLECharacteristic* pCharacteristic)
  {
    std::string rxValue = pCharacteristic->getValue();
    if(rxValue.size() > 0)
    {
      Serial.print("Received: ");
      Serial.println(rxValue.c_str());
      naredKej(rxValue.c_str());
    }
    else Serial.println("Received nothing");
  }
};

void setup()
{
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  connectWiFi();

  bleInit();

  pinMode(16, OUTPUT); // LED
}

void loop()
{
  if(WiFi.status() != WL_CONNECTED) connectWiFi();
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
  BLEDevice::init("Josko Assistant");
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
