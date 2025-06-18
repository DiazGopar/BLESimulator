/*
 * 
 *  
 * 
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer *pServer = NULL;
BLECharacteristic * pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;
bool data_ready_to_send = false;
uint8_t *txValue;



// Create two arrays to send data while reading from lidar
uint8_t buffer_1[64] = {0}, buffer_2[64] = {0};

//Commands
std::string transmit_on = "TRANSMIT_ON";
std::string transmit_off = "TRANSMIT_OFF";


// See the following for generating UUIDs:
// https://www.uuidgenerator.net/
//UART Services UUIDS
#define UART_SERVICE_UUID      "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

//Battery Services UUIDS
#define BATTERY_SERVICE_UUID BLEUUID((uint16_t)0x180F)

//Baterry Service Characterictics and descriptor
BLECharacteristic BatteryLevelCharacteristic(BLEUUID((uint16_t)0x2A19), BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor BatteryLevelDescriptor(BLEUUID((uint16_t)0x2901));

// State Machine of frame recognition declarations
#define SEARCHING_FIRST_HEADER_BYTE                0
#define SEARCHING_SECOND_HEADER_BYTE               1
#define READING_DISTANCE_DATA                      2
   
int distance = 0;

// BLE related callbacks
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    
    private:
      bool _isTransmissionEnable = false;

    public:
      bool isTransmissionEnable(){
        return _isTransmissionEnable;
      }

      void onWrite(BLECharacteristic *pCharacteristic) {
        
        std::string rxValue = pCharacteristic->getValue();
  
        if (rxValue.length() > 0) {
          if(rxValue.compare(transmit_on) == 0){
            Serial.println("*********");
            Serial.print("Received Value: ");
            Serial.println("TRANSMIT_ON");
            Serial.println("*********");
            _isTransmissionEnable = true;
          }
          if(rxValue.compare(transmit_off) == 0){
            Serial.println("*********");
            Serial.print("Received Value: ");
            Serial.println("TRANSMIT_OFF");
            Serial.println("*********");
            _isTransmissionEnable = false;
          }
        }
      }
};

MyCallbacks rxCharacteristicCallBack;

// Frame recognition State Machine 
bool incoming_data_handler(int incoming_data, int *distance)
{
    static uint8_t data_array[4];
    static uint8_t index = 0;
    static uint8_t state = SEARCHING_FIRST_HEADER_BYTE;
    static uint32_t time_counter = 0;
    bool return_value = false;



    switch(state)
    {
        case SEARCHING_FIRST_HEADER_BYTE:
            return_value = false;
            if(incoming_data == 0x59)
            {
                state = SEARCHING_SECOND_HEADER_BYTE;
            } 
            else
            {
                state = SEARCHING_FIRST_HEADER_BYTE; //reset state machine
            }
            break;
        
        case SEARCHING_SECOND_HEADER_BYTE:
            if(incoming_data == 0x59)
            {
                state = READING_DISTANCE_DATA;
                *distance = 0;
            }
            else
            {
                state = SEARCHING_FIRST_HEADER_BYTE; //reset state machine
            }
            break;

        case READING_DISTANCE_DATA:
            if(index < 2)
            {
                *distance += ((uint16_t) incoming_data) << (index << 3);
                index++;
            }
            else if(index == 6)
            {
                index = 0;
                return_value = true;
                state = SEARCHING_FIRST_HEADER_BYTE;
            } else {
                index++;
            }                    
            break;


        default:
            break;
    }

    return return_value;
}



void setup() {
  Serial.begin(230400);
  Serial1.begin(115200, SERIAL_8N1, 12, 13);

  // Create the BLE Device
  BLEDevice::init("SME_LIDAR");
  BLEDevice::setMTU(185);

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(UART_SERVICE_UUID);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(
                    CHARACTERISTIC_UUID_TX,
                    BLECharacteristic::PROPERTY_NOTIFY
                  );
                      
  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic * pRxCharacteristic = pService->createCharacteristic(
                       CHARACTERISTIC_UUID_RX,
                      BLECharacteristic::PROPERTY_WRITE
                    );

 pRxCharacteristic->setCallbacks(&rxCharacteristicCallBack);

  BLEService *pBatteryService = pServer->createService(BATTERY_SERVICE_UUID);
  
  pBatteryService->addCharacteristic(&BatteryLevelCharacteristic);
  BatteryLevelDescriptor.setValue("Battery Level");
  BatteryLevelCharacteristic.addDescriptor(&BatteryLevelDescriptor);
  BatteryLevelCharacteristic.addDescriptor(new BLE2902());

  
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  
  pAdvertising->addServiceUUID(UART_SERVICE_UUID);
  pAdvertising->addServiceUUID(BATTERY_SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();
  
  
  // Start the service
  pService->start();
  pBatteryService->start();

  // Start advertising
  //pServer->getAdvertising()->start();
  
  Serial.println("Starting...");
  Serial.println("Waiting a client connection to notify...");
}

void loop() {

  uint8_t static index_buffer = 0;
  uint8_t bytes_of_data_to_send = 0;
  bool static buffer_number_one_used = true;
  
  if(Serial1.available()) {
    
    int ch = Serial1.read();
    
    if(incoming_data_handler(ch,&distance)) {
      if(buffer_number_one_used) {
        buffer_1[index_buffer++] = (uint8_t) ((distance & 0xFF00) >> 8);
        buffer_1[index_buffer++] = (uint8_t) (distance & 0x00FF);
      } else {
        buffer_2[index_buffer++] = (uint8_t) ((distance & 0xFF00) >> 8);
        buffer_2[index_buffer++] = (uint8_t) (distance & 0x00FF);
      }
      Serial.println(distance);
    } 
  }

  if(index_buffer >= 40) {
    bytes_of_data_to_send = index_buffer;
    if(buffer_number_one_used) {
      txValue = buffer_1;  
    } else {
      txValue = buffer_2;
    }
    buffer_number_one_used = !buffer_number_one_used;
    index_buffer = 0;
    data_ready_to_send = true;
  }

  if (deviceConnected && data_ready_to_send && rxCharacteristicCallBack.isTransmissionEnable()) {
    pTxCharacteristic->setValue(txValue, bytes_of_data_to_send);
    pTxCharacteristic->notify();
    data_ready_to_send = false;
    //delay(10); // bluetooth stack will go into congestion, if too many packets are sent
  }

    // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500); // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising(); // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}
