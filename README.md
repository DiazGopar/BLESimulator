# BLE Simulator - macOS Bluetooth Low Energy Peripheral Simulator

An advanced macOS application that acts as a fully configurable Bluetooth Low Energy (BLE) peripheral device. The application simulates BLE devices using JSON files that define **the complete device configuration**.

## 🚀 Quick Start

```bash
# Build and run
swift build
swift run BLESimulator

# Or run with ESP32 LIDAR configuration
swift run BLESimulator ConfigurationExamples/esp32_lidar_device.json

# Complete ESP32 LIDAR demo
./Scripts/demo_esp32_lidar.sh
```

## 📁 Project Structure

```
BLESimulator/
├── README.md                     # This file
├── Package.swift                 # Swift Package Manager configuration
├── Info.plist                   # Application information
│
├── Sources/                      # Swift source code
│   ├── BLESimulator/            # Main application
│   │   ├── BLESimulatorApp.swift        # Entry point
│   │   └── BLEPeripheralManager.swift   # BLE management
│   ├── Views/                   # User interfaces
│   │   ├── ContentView.swift            # Main UI
│   │   └── DeviceConfigurationView.swift # Configuration editor
│   └── Models/                  # Data models
│       └── DeviceConfigurationModels.swift # JSON structures
│
├── ConfigurationExamples/        # Device configurations
│   ├── esp32_lidar_device.json         # ESP32 LIDAR (main)
│   ├── complete_device_config.json     # Advanced sensor
│   ├── heart_rate_monitor.json         # Heart rate monitor
│   ├── sensor_data.json               # Simple data
│   └── sensor_sequence.json           # Data sequence
│
├── Scripts/                      # Automation scripts
│   ├── demo_esp32_lidar.sh            # Main ESP32 demo
│   ├── demo_name_issue.sh             # BLE name issue demo
│   ├── demo.sh                        # General demo
│   ├── build.sh                       # Build script
│   ├── test_esp32.sh                  # ESP32 specific test
│   ├── test.sh                        # General tests
│   ├── validate_complete.sh           # Complete validation
│   └── verify_esp32_config.sh         # ESP32 verification
│
├── Documentation/                # Complete documentation
│   ├── ESP32_LIDAR_SIMULATION.md      # ESP32 LIDAR guide
│   ├── ESP32_COMPARISON.md            # Comparison with original
│   ├── ESP32_CORRECTIONS_IMPLEMENTED.md # Applied corrections
│   ├── ESP32_FINAL_SUMMARY.md         # ESP32 final summary
│   ├── BLE_NAME_IDENTIFICATION.md     # BLE name solution
│   ├── DOCUMENTATION_INDEX.md         # Documentation index
│   ├── PROJECT_STATUS.md              # Project status
│   └── COMPLETION_SUMMARY.md          # Features summary
│
├── Reference/                    # Reference files
│   └── ble_lidar_esp32.ino           # Original Arduino code
│
└── Tests/                        # (Future: unit tests)
```

## 🎯 Simulated Devices

### 🔥 ESP32 LIDAR (Featured)
**Exact simulation of ESP32 device with LIDAR sensor**

```bash
# Complete demo
./Scripts/demo_esp32_lidar.sh

# Direct usage
swift run BLESimulator ConfigurationExamples/esp32_lidar_device.json
```

**Features:**
- ✅ **Exact timing**: 200ms for LIDAR data
- ✅ **40 binary bytes**: 20 distances × 2 bytes little-endian
- ✅ **Identical UUIDs**: To original Arduino code
- ✅ **Real commands**: `TRANSMIT_ON` / `TRANSMIT_OFF`
- ✅ **Realistic battery**: Only updates when changed or hourly

📖 **Documentation**: [ESP32 LIDAR Simulation](Documentation/ESP32_LIDAR_SIMULATION.md)

### Other Devices
- **Advanced Sensor**: `ConfigurationExamples/complete_device_config.json`
- **Heart Rate Monitor**: `ConfigurationExamples/heart_rate_monitor.json`
- **Basic Sensors**: `ConfigurationExamples/sensor_data.json`

## 🛠️ Installation and Usage

### Requirements
- macOS 13.0+
- Swift 5.9+
- Xcode 14.0+ (for development)

### Building
```bash
# Method 1: Swift Package Manager
swift build
swift run BLESimulator

# Method 2: Build script
./Scripts/build.sh

# Method 3: Xcode
open Package.swift
```

### Basic Usage
```bash
# 1. Run with default configuration
swift run BLESimulator

# 2. Load specific configuration
swift run BLESimulator ConfigurationExamples/esp32_lidar_device.json

# 3. Interactive demo
./Scripts/demo_esp32_lidar.sh
```

## 🔍 Testing and Validation

### Complete Validation
```bash
# Verify entire system
./Scripts/validate_complete.sh

# Verify ESP32 only
./Scripts/verify_esp32_config.sh

# Quick test
./Scripts/test_esp32.sh
```

### Testing with BLE Scanners
1. **Connect**: Look for `SME_LIDAR` or UUID `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
2. **Activate**: Send `TRANSMIT_ON` to RX characteristic (`6E400002...`)
3. **Receive**: Subscribe to TX characteristic (`6E400003...`)
4. **Verify**: 40 bytes every 200ms

## ⚠️ Common Issue: BLE Identification in macOS

**Problem**: In macOS, the BLE name may appear as the computer name.

**Solution**: [Complete guide](Documentation/BLE_NAME_IDENTIFICATION.md)

```bash
# Demo of the problem and solutions
./Scripts/demo_name_issue.sh
```

## 🎯 Pre-configured Devices

### ESP32 LIDAR Simulator
Exact simulation of an ESP32 device with ToF LIDAR sensor:

```bash
# Run complete ESP32 LIDAR simulation
./Scripts/demo_esp32_lidar.sh

# Or load configuration directly
swift run BLESimulator ConfigurationExamples/esp32_lidar_device.json
```

**ESP32 LIDAR Features**:
- ✅ **Name**: `SME_LIDAR` (identical to original)
- ✅ **UART Service**: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- ✅ **Commands**: `TRANSMIT_ON` / `TRANSMIT_OFF`
- ✅ **Data**: LIDAR measurements in realistic JSON format
- ✅ **Battery**: Standard BLE battery service
- ✅ **Frequency**: 5Hz (200ms per measurement)

📖 **Complete Documentation**: [ESP32 LIDAR Simulation](Documentation/ESP32_LIDAR_SIMULATION.md)  
🔍 **Comparison**: [ESP32 Original vs Simulator](Documentation/ESP32_COMPARISON.md)  
⚙️ **Verification**: `./Scripts/verify_esp32_config.sh`

### Other Devices
- **Temperature Sensor**: `ConfigurationExamples/complete_device_config.json`
- **Heart Rate Monitor**: `ConfigurationExamples/heart_rate_monitor.json`
- **Simple Sensors**: `ConfigurationExamples/sensor_data.json`

## System Requirements

- macOS 13.0 or higher
- Xcode 14.0+ (for development)
- Swift 5.9+
- Bluetooth enabled on Mac

## Project Structure

```
BLESimulator/
├── BLESimulatorApp.swift       # Application entry point
├── ContentView.swift           # Main user interface
├── BLEPeripheralManager.swift  # Bluetooth LE management
├── Package.swift               # Swift Package Manager configuration
├── Info.plist                  # Application configuration
├── build.sh                    # Build script
├── ConfigurationExamples/      # Example JSON files
│   ├── sensor_data.json        # Individual sensor data
│   ├── sensor_sequence.json    # Sensor data sequence
│   └── heart_rate_monitor.json # Heart rate monitor data
└── README.md                   # This file
```

## Installation and Setup

### Option 1: Use Swift Package Manager (Recommended)

1. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

2. **Or use terminal**:
   ```bash
   # Build the application
   swift build
   
   # Run the application
   swift run BLESimulator
   ```

### Option 2: Use the build script

```bash
chmod +x Scripts/build.sh
./Scripts/build.sh
```

## Application Usage

### 1. Initial Configuration

1. **Run the application**: Open BLE Simulator
2. **Verify Bluetooth**: Make sure Bluetooth is enabled on your Mac
3. **Select JSON file**: Click "Select JSON File" and choose a JSON file

### 2. Complete Configuration JSON File Format

The application now supports an advanced JSON format that defines the entire device configuration:

#### Configuration JSON Structure
```json
{
  "device_config": {
    "name": "Device Name",
    "manufacturer": "Manufacturer",
    "model": "Model",
    "serial_number": "Serial Number"
  },
  "ble_config": {
    "advertised_name": "BLE Name",
    "service_uuid": "12345678-1234-1234-1234-123456789012",
    "characteristics": [
      {
        "uuid": "87654321-4321-4321-4321-210987654321",
        "name": "Sensor Data",
        "properties": ["read", "notify", "write"],
        "permissions": ["readable", "writeable"],
        "data_key": "sensor_readings"
      }
    ]
  },
  "data_config": {
    "update_interval_seconds": 2.0,
    "data_format": "sequence",
    "auto_cycle": true,
    "randomize_values": true,
    "randomize_range": 0.1
  },
  "data_streams": {
    "sensor_readings": {
      "type": "sequence",
      "data": [
        {"temperature": 22.1, "humidity": 58.3},
        {"temperature": 22.8, "humidity": 59.1}
      ]
    }
  }
}
```

#### Data Configuration
- **update_interval_seconds**: Data transmission frequency (in seconds)
- **auto_cycle**: Whether sequence data should repeat automatically
- **randomize_values**: Apply random variation to numeric values
- **randomize_range**: Variation range (0.0-1.0, where 0.1 = ±10%)

#### BLE Configuration
- **service_uuid**: Main BLE service UUID
- **advertised_name**: Name that appears in BLE scans
- **characteristics**: Array of characteristics with their properties

#### Data Streams
- **type**: "sequence" (data array) or "static" (single object)
- **data**: The data to send for each characteristic

### 2. Formatos JSON Simples (Compatibilidad)

#### Objeto JSON Individual
```json
{
  "temperature": 23.5,
  "humidity": 65.2,
  "battery": 87,
  "status": "active"
}
```

#### Array de Objetos JSON (Secuencia)
```json
[
  {
    "sequence": 1,
    "temperature": 22.1,
    "timestamp": "2025-06-18T08:00:00Z"
  },
  {
    "sequence": 2,
    "temperature": 22.8,
    "timestamp": "2025-06-18T08:05:00Z"
  }
]
```

### 3. Iniciar Simulación

1. **Selecciona un archivo JSON** desde el directorio `example_data/` o crea el tuyo propio
2. **Haz clic en "Start Advertising"** para comenzar la simulación BLE
3. **Monitorea el log** para ver la actividad de conexiones y transferencia de datos
4. **Usa "Stop Advertising"** para detener la simulación

### 4. Conexión desde Otras Aplicaciones

Tu aplicación BLE central debe buscar dispositivos con:
- **Nombre del servicio**: "BLE Simulator"
- **UUID del servicio**: `12345678-1234-1234-1234-123456789012`
- **UUID de característica**: `87654321-4321-4321-4321-210987654321`

## Configuración BLE

### UUIDs por Defecto

- **Service UUID**: `12345678-1234-1234-1234-123456789012`
- **Characteristic UUID**: `87654321-4321-4321-4321-210987654321`

### Propiedades de Característica

- **Read**: Permite leer datos actuales
- **Write**: Permite escribir datos al dispositivo
- **Notify**: Envía actualizaciones automáticas cada 2 segundos

### Permisos

- **Readable**: Los dispositivos pueden leer el valor
- **Writeable**: Los dispositivos pueden escribir valores

## Personalización

### Cambiar UUIDs

Edita `BLEPeripheralManager.swift` y modifica:

```swift
private let serviceUUID = CBUUID(string: "TU-SERVICE-UUID-AQUI")
private let characteristicUUID = CBUUID(string: "TU-CHARACTERISTIC-UUID-AQUI")
```

### Cambiar Intervalo de Actualización

Modifica el timer en `BLEPeripheralManager.swift`:

```swift
// Cambiar de 2.0 segundos a tu intervalo deseado
dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
    self.sendDataUpdate()
}
```

### Agregar Más Características

Puedes agregar características adicionales en el método `setupService()`:

```swift
let additionalCharacteristic = CBMutableCharacteristic(
    type: CBUUID(string: "TU-NUEVO-UUID"),
    properties: [.read, .notify],
    value: nil,
    permissions: [.readable]
)
```

## Desarrollo y Depuración

### Log de Eventos

La aplicación registra todos los eventos importantes:
- Estado de Bluetooth
- Conexiones/desconexiones de dispositivos
- Lectura/escritura de características
- Errores y advertencias

### Problemas Comunes

1. **"Bluetooth no disponible"**
   - Verifica que Bluetooth esté habilitado
   - Reinicia la aplicación si es necesario

2. **"No se pueden enviar datos"**
   - Verifica que el archivo JSON sea válido
   - Comprueba que hay dispositivos conectados

3. **"Permisos de Bluetooth denegados"**
   - Ve a Configuración del Sistema > Privacidad y Seguridad > Bluetooth
   - Habilita permisos para la aplicación

## Testing

### Probar con Aplicaciones iOS

Puedes usar aplicaciones como:
- **LightBlue Explorer** (App Store)
- **nRF Connect** (Nordic Semiconductor)
- **BLE Scanner** para verificar que tu simulador funciona

### Código de Ejemplo para Conectarse

```swift
// Código iOS/macOS para conectarse al simulador
let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789012")
centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
```

## Contribuir

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Arquitectura Técnica

### Core Bluetooth Integration

La aplicación utiliza el framework Core Bluetooth de Apple para:
- Crear un peripheral manager (`CBPeripheralManager`)
- Definir servicios y características BLE
- Manejar conexiones entrantes de dispositivos centrales
- Enviar notificaciones con datos JSON

### Gestión de Datos

- **JSON Loading**: Carga archivos JSON usando `JSONSerialization`
- **Data Cycling**: Para arrays JSON, cicla automáticamente entre elementos
- **Real-time Updates**: Envía datos cada 2 segundos con timestamps

### UI Architecture

- **SwiftUI**: Interfaz moderna y declarativa
- **MVVM Pattern**: Separación clara entre UI y lógica de negocio
- **Reactive Updates**: UI se actualiza automáticamente con `@Published` properties

## 📚 Documentación

- **[Índice Completo](Documentation/DOCUMENTATION_INDEX.md)** - Toda la documentación disponible
- **[ESP32 LIDAR](Documentation/ESP32_LIDAR_SIMULATION.md)** - Guía técnica del ESP32
- **[Comparación ESP32](Documentation/ESP32_COMPARISON.md)** - Original vs Simulador
- **[Identificación BLE](Documentation/BLE_NAME_IDENTIFICATION.md)** - Solución nombres macOS

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

## 🚀 Características Avanzadas

- ✅ **Configuración JSON Completa**: UUIDs, servicios, características, datos
- ✅ **Editor en Tiempo Real**: Modificar configuraciones sin reiniciar
- ✅ **Múltiples Características**: Soporte para dispositivos complejos
- ✅ **Datos Dinámicos**: Frecuencia configurable y variación aleatoria
- ✅ **Datos Binarios**: Soporte para protocolos de bytes (como ESP32)
- ✅ **Archivos Ejecutables**: Carga configuraciones por línea de comandos

## 📄 Licencia

Este proyecto está disponible como código abierto para fines educativos y de desarrollo.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Ejecuta `./Scripts/validate_complete.sh` antes de enviar cambios
2. Actualiza la documentación correspondiente
3. Añade tests para nuevas funcionalidades

---

**🎉 ¡Listo para simular cualquier dispositivo BLE!**

Para empezar inmediatamente con el ESP32 LIDAR:
```bash
./Scripts/demo_esp32_lidar.sh
```
