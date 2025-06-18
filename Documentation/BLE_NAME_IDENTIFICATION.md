# BLE Device Name Identification Guide

## El Problema del Nombre en macOS

Cuando macOS actúa como un periférico BLE, existe una limitación conocida donde el sistema operativo puede sobrescribir el nombre anunciado (`CBAdvertisementDataLocalNameKey`) y mostrar el nombre del ordenador en los escáneres BLE en lugar del nombre configurado.

### ¿Por qué sucede esto?

- **Seguridad y Privacidad**: macOS tiene políticas de privacidad que pueden afectar cómo se anuncia el dispositivo
- **Comportamiento del Sistema**: El framework Core Bluetooth puede usar el nombre del sistema como fallback
- **Limitaciones del Advertising**: Algunos datos de advertising pueden ser filtrados o modificados

## Soluciones Implementadas

### 1. Service UUID como Identificador Principal
```json
{
  "ble_config": {
    "service_uuid": "12345678-1234-1234-1234-123456789012"
  }
}
```
**Uso**: Busca este UUID específico en tu escáner BLE para identificar el dispositivo simulado.

### 2. Manufacturer Data Mejorados
El simulator ahora incluye datos del fabricante más robustos:
- Company ID ficticio (0xFF, 0xFE)
- Información del dispositivo compacta
- Nombre del fabricante y modelo

### 3. Característica de Device Info Enriquecida
La característica "Device Info" ahora contiene:
```json
{
  "device_name": "TempSensor Pro",
  "system_name": "Sensor de Temperatura Avanzado",
  "manufacturer": "IoT Solutions",
  "model": "TS-2025-Pro",
  "serial_number": "TS001234567",
  "service_uuid": "12345678-1234-1234-1234-123456789012",
  "ble_identifier": "IoT Solutions-TS-2025-Pro",
  "identification_tip": "Look for Service UUID 12345678-1234-1234-1234-123456789012 in BLE scanners"
}
```

### 4. Logging Mejorado
El simulator ahora proporciona instrucciones claras en los logs:
```
📡 Advertising is active
🏷️  Device configured as: 'TempSensor Pro'
🔍 Service UUID: 12345678-1234-1234-1234-123456789012
🏭 Manufacturer: IoT Solutions
📟 Model: TS-2025-Pro

💡 BÚSQUEDA EN ESCÁNER BLE:
   • Busca dispositivos con Service UUID: 12345678-1234-1234-1234-123456789012
   • El nombre puede aparecer como 'TempSensor Pro' o el nombre del Mac
   • Algunos escáneres muestran 'IoT Solutions' en manufacturer data
```

## Cómo Identificar tu Dispositivo

### Paso 1: Usar el Service UUID
1. Abre tu escáner BLE favorito
2. Busca dispositivos cercanos
3. Filtra o busca por el Service UUID: `12345678-1234-1234-1234-123456789012`
4. Este es el método más confiable

### Paso 2: Buscar por Manufacturer Data
Algunos escáneres muestran:
- Company: "IoT Solutions"
- Device identifier: "IoT Solutions-TS-2025-Pro"

### Paso 3: Conectar y Leer Device Info
1. Conecta al dispositivo encontrado
2. Busca la característica "Device Info" (`11111111-2222-3333-4444-555555555555`)
3. Lee el contenido para confirmar que es tu dispositivo simulado

## Escáneres BLE Recomendados

### iOS/macOS
- **LightBlue Explorer**: Excelente para desarrollo, muestra todos los detalles
- **Bluetooth Explorer**: Herramienta oficial de Apple para desarrolladores

### Android
- **BLE Scanner**: Simple y efectivo
- **nRF Connect**: Muy completo, ideal para desarrollo

### Multiplataforma
- **Web Bluetooth Scanner**: Funciona en navegadores compatibles

## Configuración Personalizada

Para cambiar la identificación de tu dispositivo:

1. **Edita el archivo JSON**:
```bash
nano example_data/complete_device_config.json
```

2. **Cambia los campos clave**:
```json
{
  "ble_config": {
    "advertised_name": "MiDispositivo",
    "service_uuid": "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
  },
  "device_config": {
    "name": "Mi Sensor Personalizado",
    "manufacturer": "Mi Empresa"
  }
}
```

3. **Reinicia el simulator**

## Troubleshooting

### El dispositivo no aparece
- ✅ Verifica que Bluetooth esté activado
- ✅ Comprueba que el simulator muestre "Advertising is active"
- ✅ Intenta reiniciar el Bluetooth del escáner

### Aparece con nombre incorrecto
- ✅ Esto es normal en macOS
- ✅ Usa el Service UUID para identificar
- ✅ Conecta y lee Device Info para confirmar

### No puedo conectar
- ✅ Verifica los permisos de Bluetooth en macOS
- ✅ Intenta desde otro dispositivo
- ✅ Reinicia el simulator

## Scripts de Demostración

Ejecuta estos scripts para probar:

```bash
# Demo específico del problema del nombre
./demo_name_issue.sh

# Demo general
./demo.sh
```

## Personalización Avanzada

Para casos de uso específicos, puedes:

1. **Crear múltiples configuraciones** con diferentes UUIDs
2. **Modificar los manufacturer data** para incluir información específica
3. **Agregar más características** con datos identificables
4. **Usar UUIDs estándar** de Bluetooth SIG si simulas un dispositivo real

---

**Nota**: Esta documentación refleja las mejoras implementadas para resolver el problema común del nombre del dispositivo BLE en macOS. El enfoque principal es usar el Service UUID como identificador confiable.
