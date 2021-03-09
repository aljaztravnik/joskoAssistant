#include <WiFi.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

const char* ssid = "Telemach-8a1e";
const char* password = "polica20a";
const char* root_ca = \
"-----BEGIN CERTIFICATE-----\n" \
"MIIGQTCCBSmgAwIBAgIQDUK/hzBxxAj+Z10Y9SX9mTANBgkqhkiG9w0BAQsFADBw\n" \
"MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3\n" \
"d3cuZGlnaWNlcnQuY29tMS8wLQYDVQQDEyZEaWdpQ2VydCBTSEEyIEhpZ2ggQXNz\n" \
"dXJhbmNlIFNlcnZlciBDQTAeFw0yMTAxMjQwMDAwMDBaFw0yMTA0MjMyMzU5NTla\n" \
"MGMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRMwEQYDVQQHEwpN\n" \
"ZW5sbyBQYXJrMRcwFQYDVQQKEw5GYWNlYm9vaywgSW5jLjERMA8GA1UEAwwIKi53\n" \
"aXQuYWkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCrhuGaB34oi2vz\n" \
"K9D+Vd5uFaQnkURqwifgfkj2Sq/U9DF8d6SxEeZLsofOvSJp+CYzGM04MBJJRWP5\n" \
"OHQ+qHJjw9Hcn9S9k4g4M/XWpacKLbAIgVH2o0P+VxYzdO0xW8JcC9oj/+prDG50\n" \
"MwsSQ4DYQsnqq7mcJ22Gox+oPbLmo+mqma4CymQujP+YvsPRo9sG71MYczwB6MfU\n" \
"bLCAcxl3LABmYE1zVfB6OZMVKIp05GdigLq/qdQuvxngYvco3WGvwsolgmPdHmsi\n" \
"BNW1LnoaiaMulssEy4GW8OZ2XTv1R8Oy8k5PNZhY5vfcMyl3c4bHERnrXDjzuXIg\n" \
"er56lQURAgMBAAGjggLiMIIC3jAfBgNVHSMEGDAWgBRRaP+QrwIHdTzM2WVkYqIS\n" \
"uFlyOzAdBgNVHQ4EFgQURUy5sEDPZYzF3Wi8YooQ2OXnvFkwGwYDVR0RBBQwEoII\n" \
"Ki53aXQuYWmCBndpdC5haTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYB\n" \
"BQUHAwEGCCsGAQUFBwMCMHUGA1UdHwRuMGwwNKAyoDCGLmh0dHA6Ly9jcmwzLmRp\n" \
"Z2ljZXJ0LmNvbS9zaGEyLWhhLXNlcnZlci1nNi5jcmwwNKAyoDCGLmh0dHA6Ly9j\n" \
"cmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWhhLXNlcnZlci1nNi5jcmwwPgYDVR0gBDcw\n" \
"NTAzBgZngQwBAgIwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5j\n" \
"b20vQ1BTMIGDBggrBgEFBQcBAQR3MHUwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw\n" \
"LmRpZ2ljZXJ0LmNvbTBNBggrBgEFBQcwAoZBaHR0cDovL2NhY2VydHMuZGlnaWNl\n" \
"cnQuY29tL0RpZ2lDZXJ0U0hBMkhpZ2hBc3N1cmFuY2VTZXJ2ZXJDQS5jcnQwDAYD\n" \
"VR0TAQH/BAIwADCCAQMGCisGAQQB1nkCBAIEgfQEgfEA7wB1APZclC/RdzAiFFQY\n" \
"CDCUVo7jTRMZM7/fDC8gC8xO8WTjAAABdzUxoJYAAAQDAEYwRAIgEDP3Za1VKt6h\n" \
"DhP/KiFdnUXgR/D7dmXhhS7OHWPusHICID6pqKu1FCRO6jtabYlzARVsNlWpbYAy\n" \
"cioJuvluD6kVAHYAXNxDkv7mq0VEsV6a1FbmEDf71fpH3KFzlLJe5vbHDsoAAAF3\n" \
"NTGg2QAABAMARzBFAiEA2Vl6XsH1vNTschHcf8BDVT3F0qq+bO20OVYO4RQFbHIC\n" \
"IEvGbp6Oiowam1OlqogKu5e4kaPSNyp8efoiiQTQUreXMA0GCSqGSIb3DQEBCwUA\n" \
"A4IBAQBMr7zlEZSk/EQ51zVOLZLkzhHLnnEmWn4EKD3TUfFjglcCmROpQOUScu8z\n" \
"92OgAoiYtsZGwyxr0+3951cMGLKfwlc5ZfCrADx9pRC3HPbewIcKa8U+TqyvhOKz\n" \
"Qtl6CnFKvcyEKyCUw27tSOwYkuwEZ+e6udgVWw9NEGOifT0eZILk4qBEqYA0cAPO\n" \
"B9IeR4poU1AqQrl8CT5lFV6QMucuKMKHL85O6jvLYb5M55pqHx+4Mfw3u3IFvVmm\n" \
"CXnyfvHgu+aHCnS1AKYH7+KzNCvEfleiJfESGxtCptW5Kny9rwL9Lh1grYMtZ5Pd\n" \
"NaPF4GOiyTw4DUFq8FHM7yAe9tTs\n" \
"-----END CERTIFICATE-----\n";
BLEServer* pServer = NULL;
BLECharacteristic* p_command_characteristic = NULL;

#define COMMAND_SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define COMMAND_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

bool deviceConnected = false;
bool oldDeviceConnected = false;

String httpGETRequest(const char* url)
{
  HTTPClient http;
  http.begin(url, root_ca);
  http.addHeader("Authorization", "Bearer SFVN2BGNZIHYU47BVJE6OUIT7EWXJQUV");
  int httpResponseCode = http.GET();
  
  String payload = "{}";
  
  if (httpResponseCode>0)
  {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = http.getString();
  }
  else
  {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  http.end();
  return payload;
}

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
  String httpGETRequest(const char* url)
  {
    return ::httpGETRequest(url);
  }
  void onWrite(BLECharacteristic* pCharacteristic)
  {
    std::string defaultUrl = "https://api.wit.ai/message?v=20210119&q=";
    std::string rxValue = pCharacteristic->getValue();
    std::string placeholder = " %";
    if(rxValue != "")
      if(rxValue[0] >= 'A' && rxValue[0] <= 'Z') rxValue[0] += 32;
    Serial.print("RECEIVED ON BLE: ");
    Serial.println(rxValue.c_str());
    for(int i = 0; i < rxValue.size(); i++)
    {
      if(rxValue[i] == placeholder[0]) rxValue[i] = placeholder[1];
    }
    const char* url = (defaultUrl + rxValue).c_str();
    //const char* url = "https://api.wit.ai/message?v=20210119&q=turn%the%lights%on";
    Serial.print("URL: ");
    Serial.println(url);
    String reply = httpGETRequest(url);
    Serial.println(reply);
    JSONVar myObject = JSON.parse(reply);
    if (JSON.typeof(myObject) == "undefined")
    {
      Serial.println("Parsing input failed!");
      return;
    }
    Serial.println("JSON object = ");
    Serial.println(myObject);
  }
};

void setup()
{
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  connectWiFi();

  bleInit();
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
