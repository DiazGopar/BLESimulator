# 📚 Documentación del BLE Simulator

Índice completo de toda la documentación disponible para el BLE Simulator macOS.

## 📋 Documentos Principales

### 🏠 Información General
- **[README.md](README.md)** - Documentación principal y guía de inicio
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - Estado actual del proyecto
- **[COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md)** - Resumen de funcionalidades completadas
- **[ESP32_FINAL_SUMMARY.md](ESP32_FINAL_SUMMARY.md)** - ⭐ RESUMEN FINAL COMPLETO ESP32

### 🔧 Configuración y Uso
- **[BLE_NAME_IDENTIFICATION.md](BLE_NAME_IDENTIFICATION.md)** - Solución al problema del nombre BLE en macOS
- **[ESP32_LIDAR_SIMULATION.md](ESP32_LIDAR_SIMULATION.md)** - Guía completa de simulación ESP32 LIDAR
- **[ESP32_COMPARISON.md](ESP32_COMPARISON.md)** - Comparación entre ESP32 original y simulador
- **[ESP32_CORRECTIONS_IMPLEMENTED.md](ESP32_CORRECTIONS_IMPLEMENTED.md)** - Correcciones de precisión implementadas

## 🎮 Scripts de Demostración

### Scripts Principales
| Script | Propósito | Comando |
|--------|-----------|---------|
| **`demo.sh`** | Demostración general | `./demo.sh` |
| **`demo_esp32_lidar.sh`** | Demo ESP32 LIDAR específico | `./demo_esp32_lidar.sh` |
| **`demo_name_issue.sh`** | Demo problema nombre BLE | `./demo_name_issue.sh` |

### Scripts de Construcción
| Script | Propósito | Comando |
|--------|-----------|---------|
| **`build.sh`** | Compilar la aplicación | `./build.sh` |
| **`test.sh`** | Ejecutar tests | `./test.sh` |
| **`verify_esp32_config.sh`** | Verificar configuración ESP32 | `./verify_esp32_config.sh` |

## 📁 Archivos de Configuración

### Dispositivos Pre-configurados

#### ESP32 LIDAR
- **Archivo**: `example_data/esp32_lidar_device.json`
- **Descripción**: Simulación exacta del ESP32 con sensor LIDAR
- **UUIDs**: Compatibles con código Arduino original
- **Comandos**: `TRANSMIT_ON` / `TRANSMIT_OFF`
- **Demo**: `./demo_esp32_lidar.sh`

#### Sensor de Temperatura Avanzado
- **Archivo**: `example_data/complete_device_config.json`
- **Descripción**: Dispositivo IoT completo con múltiples sensores
- **Características**: Temperatura, humedad, presión, batería
- **Formato**: Configuración JSON completa

#### Monitor Cardíaco Simple
- **Archivo**: `example_data/heart_rate_monitor.json`
- **Descripción**: Simulador de monitor de frecuencia cardíaca
- **Datos**: Mediciones de BPM realistas
- **Servicios**: Heart Rate Service estándar

#### Ejemplos Simples
- **`sensor_data.json`**: Datos de sensor básicos
- **`sensor_sequence.json`**: Secuencia de mediciones

## 🔨 Código Fuente

### Archivos Swift Principales
| Archivo | Propósito |
|---------|-----------|
| **`BLESimulatorApp.swift`** | Punto de entrada de la aplicación |
| **`ContentView.swift`** | Interfaz principal de usuario |
| **`BLEPeripheralManager.swift`** | Gestión del periférico BLE |
| **`DeviceConfigurationModels.swift`** | Modelos de datos para configuración |
| **`DeviceConfigurationView.swift`** | Editor de configuración UI |

### Archivos de Configuración
- **`Package.swift`** - Configuración Swift Package Manager
- **`Info.plist`** - Información de la aplicación

### Código de Referencia
- **`ble_lidar_esp32.ino`** - Código Arduino original del ESP32 LIDAR

## 🚀 Guías de Uso Rápido

### 🏃‍♂️ Inicio Rápido
```bash
# 1. Compilar
swift build

# 2. Ejecutar con configuración ESP32
swift run BLESimulator example_data/esp32_lidar_device.json

# 3. O usar el demo completo
./demo_esp32_lidar.sh
```

### 🔍 Identificación de Dispositivos
```bash
# Si tienes problemas identificando el dispositivo BLE
./demo_name_issue.sh

# Leer la guía completa
open BLE_NAME_IDENTIFICATION.md
```

### ⚙️ Verificación de Configuración
```bash
# Verificar que tu JSON está correcto
./verify_esp32_config.sh

# Validar sintaxis JSON
python3 -m json.tool example_data/esp32_lidar_device.json
```

## 📱 Testing y Debugging

### Aplicaciones BLE Recomendadas
- **iOS**: LightBlue Explorer
- **Android**: BLE Scanner, nRF Connect
- **macOS**: Bluetooth Explorer, LightBlue Explorer

### Datos de Prueba
- **Service UUID ESP32**: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- **TX Characteristic**: `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`
- **RX Characteristic**: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- **Comandos**: Enviar "TRANSMIT_ON" para activar datos

## 🎯 Casos de Uso

### Para Desarrolladores
- ✅ Desarrollo de apps BLE sin hardware
- ✅ Testing de protocolos de comunicación
- ✅ Validación de parsers de datos
- ✅ Simulación de errores y reconexiones

### Para Educación
- ✅ Aprendizaje de conceptos BLE
- ✅ Demostración de protocolos
- ✅ Comprensión de servicios y características
- ✅ Experimentación segura

### Para Testing
- ✅ Automatización de pruebas BLE
- ✅ Simulación de múltiples dispositivos
- ✅ Condiciones reproducibles
- ✅ Validación de rendimiento

## 🔗 Enlaces Útiles

### Documentación Técnica
- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [ESP32 BLE Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/esp_ble_gatt.html)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Especificaciones BLE
- [Bluetooth GATT Services](https://www.bluetooth.com/specifications/specs/)
- [UART Service Specification](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
- [Battery Service Specification](https://www.bluetooth.com/specifications/assigned-numbers/)

## 📧 Soporte

Para preguntas o problemas:
1. Consulta esta documentación
2. Ejecuta `./verify_esp32_config.sh` para problemas de configuración
3. Revisa `BLE_NAME_IDENTIFICATION.md` para problemas de conectividad
4. Verifica logs en la aplicación para debugging

---

*Última actualización: Junio 2025*
*Versión: 2.0 - ESP32 LIDAR Edition*
