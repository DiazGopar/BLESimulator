# ESP32 LIDAR BLE Device Simulation

Este documento describe la simulación exacta del dispositivo ESP32 LIDAR basado en el código Arduino proporcionado.

## 📋 Resumen del Dispositivo

**Dispositivo Original**: ESP32 con sensor LIDAR ToF
**Nombre BLE**: `SME_LIDAR`
**Protocolo**: UART-style BLE service + Battery service
**Frecuencia de medición**: 10Hz (100ms por medición)

## 🔧 Configuración BLE

### Servicios Principales

#### 1. UART Service
- **UUID**: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- **Propósito**: Comunicación bidireccional con el LIDAR
- **Características**:
  - **TX (Transmit)**: `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`
    - Propiedades: `NOTIFY`
    - Función: Envía datos de medición LIDAR
  - **RX (Receive)**: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
    - Propiedades: `WRITE`
    - Función: Recibe comandos de control

#### 2. Battery Service
- **UUID**: `0000180F-0000-1000-8000-00805F9B34FB`
- **Característica**: Battery Level `00002A19-0000-1000-8000-00805F9B34FB`
- **Propiedades**: `READ`, `NOTIFY`

## 📊 Protocolo de Datos LIDAR

### Formato de Frame Original (ESP32)
```
Header: 0x59 0x59
Data:   [distance_low] [distance_high] [signal_low] [signal_high] [reserved] [checksum]
Total:  8 bytes por medición
```

### Formato JSON Simulado
```json
{
  "timestamp": "2025-06-18T08:00:00.000Z",
  "distance_mm": 1250,
  "signal_strength": 95,
  "measurement_id": 1,
  "frame_header": [89, 89],
  "raw_data": "595900E204",
  "status": "valid"
}
```

## 🎮 Comandos de Control

### Comandos Disponibles
| Comando | Función | Respuesta |
|---------|---------|-----------|
| `TRANSMIT_ON` | Inicia transmisión de datos | Activa el envío de mediciones |
| `TRANSMIT_OFF` | Detiene transmisión | Pausa el envío de datos |

### Estado de Control
```json
{
  "last_command": "TRANSMIT_ON",
  "command_timestamp": "2025-06-18T08:00:00Z",
  "transmission_enabled": true,
  "available_commands": ["TRANSMIT_ON", "TRANSMIT_OFF"]
}
```

## 📈 Datos de Simulación

### Rangos de Medición
- **Distancia mínima**: 750mm
- **Distancia máxima**: 2100mm
- **Resolución**: 1mm
- **Precisión simulada**: ±5% con variación aleatoria

### Patrón de Batería
- **Nivel inicial**: 95%
- **Descarga**: ~1% cada 5 minutos
- **Voltaje**: 4150mv - 4110mv
- **Estado**: Simulación realista de descarga

## 🧪 Guía de Pruebas

### Paso 1: Ejecutar la Simulación
```bash
cd /Volumes/nvme-ext/BLESimulator
./demo_esp32_lidar.sh
```

### Paso 2: Conectar con Escáner BLE
1. **Aplicaciones recomendadas**:
   - iOS: LightBlue Explorer
   - Android: BLE Scanner, nRF Connect
   - macOS: Bluetooth Explorer

2. **Buscar dispositivo**:
   - Nombre: `SME_LIDAR`
   - Service UUID: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`

### Paso 3: Probar Funcionalidades

#### 3.1 Leer Información del Dispositivo
```
1. Conectar al dispositivo
2. Explorar servicios disponibles
3. Leer Battery Level characteristic
4. Verificar información del dispositivo
```

#### 3.2 Controlar Transmisión
```
1. Localizar RX characteristic (6E400002-...)
2. Escribir "TRANSMIT_ON" (string)
3. Suscribirse a TX characteristic (6E400003-...)
4. Observar datos de medición cada 100ms
5. Escribir "TRANSMIT_OFF" para detener
```

#### 3.3 Monitorear Datos
```
1. Verificar formato JSON de las mediciones
2. Comprobar variación realista en distancias
3. Observar headers de frame [89, 89]
4. Monitorear signal_strength (85-98)
```

## 📱 Datos Esperados

### Frecuencia de Actualización
- **Mediciones LIDAR**: 10Hz (cada 100ms)
- **Batería**: Cada 5 minutos
- **Comandos**: Inmediato

### Ejemplo de Secuencia
```
[08:00:00.000] distance_mm: 1250, signal: 95
[08:00:00.100] distance_mm: 1180, signal: 92
[08:00:00.200] distance_mm: 1320, signal: 88
[08:00:00.300] distance_mm: 980, signal: 94
```

## 🔍 Troubleshooting

### Problema: No se encuentra el dispositivo
**Solución**: 
- Verificar que Bluetooth está activado
- Buscar por Service UUID si el nombre no aparece
- En macOS, el nombre puede aparecer como el nombre del ordenador

### Problema: No se reciben datos
**Solución**:
- Verificar que se envió comando "TRANSMIT_ON"
- Confirmar suscripción a TX characteristic
- Comprobar que el dispositivo está conectado

### Problema: Datos incorrectos
**Solución**:
- Verificar formato JSON
- Comprobar que los valores están en rango esperado
- Revisar logs de la aplicación para errores

## 🎯 Casos de Uso

### Desarrollo de Apps BLE
- Probar conectividad BLE
- Validar parsing de datos JSON
- Simular comandos de control
- Probar reconexión automática

### Testing de Hardware
- Emular comportamiento de sensor real
- Probar protocolos de comunicación
- Validar manejo de errores
- Simular diferentes escenarios de datos

### Educación y Demos
- Demostrar conceptos BLE
- Mostrar protocolos UART over BLE
- Explicar estructuras de datos
- Enseñar debugging BLE

## 📄 Archivos Relacionados

- `esp32_lidar_device.json` - Configuración completa
- `demo_esp32_lidar.sh` - Script de demostración
- `ble_lidar_esp32.ino` - Código fuente original
- `BLE_NAME_IDENTIFICATION.md` - Guía de identificación

## 🔗 Referencias

- [ESP32 BLE Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/esp_ble_gatt.html)
- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [BLE UART Service](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
