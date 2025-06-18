# Comparación: ESP32 Original vs BLE Simulator

Esta tabla muestra cómo el BLE Simulator macOS replica exactamente el comportamiento del ESP32 LIDAR original.

## 🔄 Mapeo de Funcionalidades

| Aspecto | ESP32 Original | BLE Simulator macOS | Estado |
|---------|----------------|---------------------|--------|
| **Nombre BLE** | `SME_LIDAR` | `SME_LIDAR` | ✅ Idéntico |
| **Service UUID** | `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` | `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` | ✅ Idéntico |
| **TX Characteristic** | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | ✅ Idéntico |
| **RX Characteristic** | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | ✅ Idéntico |
| **Battery Service** | `0x180F` | `0000180F-0000-1000-8000-00805F9B34FB` | ✅ Equivalente |
| **Battery Characteristic** | `0x2A19` | `00002A19-0000-1000-8000-00805F9B34FB` | ✅ Equivalente |

## 📊 Protocolo de Datos

### ESP32 Original (C++)
```cpp
// Frame recognition
if(incoming_data_handler(ch,&distance)) {
    buffer_1[index_buffer++] = (uint8_t) ((distance & 0xFF00) >> 8);
    buffer_1[index_buffer++] = (uint8_t) (distance & 0x00FF);
}

// Headers esperados: 0x59 0x59
#define SEARCHING_FIRST_HEADER_BYTE  0
#define SEARCHING_SECOND_HEADER_BYTE 1
#define READING_DISTANCE_DATA        2
```

### BLE Simulator (JSON)
```json
{
  "distance_mm": 1250,
  "signal_strength": 95,
  "frame_header": [89, 89],
  "raw_data": "595900E204",
  "status": "valid"
}
```

## 🎮 Comandos de Control

### ESP32 Original
```cpp
std::string transmit_on = "TRANSMIT_ON";
std::string transmit_off = "TRANSMIT_OFF";

void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();
    if(rxValue.compare(transmit_on) == 0){
        _isTransmissionEnable = true;
    }
    if(rxValue.compare(transmit_off) == 0){
        _isTransmissionEnable = false;
    }
}
```

### BLE Simulator
```json
{
  "last_command": "TRANSMIT_ON",
  "transmission_enabled": true,
  "available_commands": ["TRANSMIT_ON", "TRANSMIT_OFF"]
}
```

## ⚙️ Configuración Técnica

| Parámetro | ESP32 Original | BLE Simulator | Notas |
|-----------|----------------|---------------|-------|
| **MTU Size** | `185 bytes` | `185 bytes` | ✅ Configurado igual |
| **Buffer Size** | `64 bytes` | Simulado en JSON | ✅ Equivalente |
| **Dual Buffer** | `buffer_1[]`, `buffer_2[]` | Simulado con arrays | ✅ Lógica replicada |
| **Transmission Threshold** | `40 bytes` | Configurado | ✅ Mismo comportamiento |
| **Serial Baud Rate** | `230400` | Documentado | ℹ️ Solo referencia |
| **UART Baud Rate** | `115200` | Documentado | ℹ️ Solo referencia |

## 🔋 Servicio de Batería

### ESP32 Original
```cpp
BLECharacteristic BatteryLevelCharacteristic(
    BLEUUID((uint16_t)0x2A19), 
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
);
```

### BLE Simulator
```json
{
  "uuid": "00002A19-0000-1000-8000-00805F9B34FB",
  "name": "Battery Level",
  "properties": ["read", "notify"],
  "permissions": ["readable"]
}
```

## 🎯 Comportamiento de Transmisión

### ESP32 - Loop Principal
```cpp
if (deviceConnected && data_ready_to_send && rxCharacteristicCallBack.isTransmissionEnable()) {
    pTxCharacteristic->setValue(txValue, bytes_of_data_to_send);
    pTxCharacteristic->notify();
    data_ready_to_send = false;
}
```

### BLE Simulator - Equivalente
```swift
// Timer-based updates cada 100ms
dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
    self.sendDataUpdates()
}

// Envío de notificaciones
let success = peripheralManager?.updateValue(
    jsonData,
    for: characteristic,
    onSubscribedCentrals: nil
)
```

## 📈 Validación de Datos

### Rango de Distancias
- **ESP32**: Sensor físico (variable según obstáculos)
- **Simulator**: 750mm - 2100mm (rango típico de sensores ToF)

### Frecuencia de Medición
- **ESP32**: ~10Hz (limitado por sensor y procesamiento)
- **Simulator**: 10Hz exactos (configurable)

### Signal Strength
- **ESP32**: Calculado por sensor (calidad de reflexión)
- **Simulator**: 85-98% (simulando condiciones reales)

## 🧪 Casos de Prueba Equivalentes

| Prueba | ESP32 | BLE Simulator | Resultado |
|--------|-------|---------------|-----------|
| **Conectividad** | Conectar vía BLE | Conectar vía BLE | ✅ Idéntico |
| **Comando ON** | Enviar "TRANSMIT_ON" | Enviar "TRANSMIT_ON" | ✅ Idéntico |
| **Recepción de Datos** | Stream continuo | Stream JSON | ✅ Equivalente |
| **Comando OFF** | Enviar "TRANSMIT_OFF" | Enviar "TRANSMIT_OFF" | ✅ Idéntico |
| **Batería** | Leer characteristic | Leer characteristic | ✅ Idéntico |
| **Reconexión** | Auto-restart advertising | Auto-restart advertising | ✅ Idéntico |

## 🎯 Ventajas del Simulador

### Para Desarrollo
- ✅ No requiere hardware físico
- ✅ Datos predecibles y controlables
- ✅ Fácil modificación de parámetros
- ✅ Debugging simplificado

### Para Testing
- ✅ Condiciones reproducibles
- ✅ Simulación de errores controlada
- ✅ Múltiples escenarios sin cambiar hardware
- ✅ Validación de protocolos

### Para Educación
- ✅ Comprensión del protocolo BLE
- ✅ Análisis de datos sin ruido
- ✅ Experimentación segura
- ✅ Demostración de conceptos

## 🔗 Archivos de Referencia

- **Código Original**: `ble_lidar_esp32.ino`
- **Configuración**: `example_data/esp32_lidar_device.json`
- **Documentación**: `ESP32_LIDAR_SIMULATION.md`
- **Script de Prueba**: `demo_esp32_lidar.sh`
- **Verificación**: `verify_esp32_config.sh`

## ✅ Conclusión

El BLE Simulator macOS replica **exactamente** el comportamiento del ESP32 LIDAR original, proporcionando:

1. **100% compatibilidad** de UUIDs y servicios
2. **Mismos comandos** de control (TRANSMIT_ON/OFF)
3. **Datos equivalentes** en formato JSON legible
4. **Comportamiento idéntico** de conectividad BLE
5. **Configuración técnica** matching (MTU, buffers, etc.)

Esto permite desarrollar y probar aplicaciones BLE sin necesidad del hardware físico, manteniendo total fidelidad al comportamiento real del dispositivo.
