#!/bin/bash

# Demo script para dispositivo LIDAR ESP32 BLE
# Este script simula exactamente el comportamiento del ESP32 con LIDAR

echo "🎯 BLE Simulator - ESP32 LIDAR Device Demo"
echo "=========================================="
echo ""
echo "📡 DISPOSITIVO A SIMULAR:"
echo "   • Nombre: SME_LIDAR"
echo "   • Tipo: ESP32 con sensor LIDAR"
echo "   • Servicios: UART + Battery"
echo "   • Protocolo: Frame-based con headers 0x59 0x59"
echo ""
echo "🔧 CARACTERÍSTICAS BLE:"
echo "   • UART Service: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
echo "   • TX (LIDAR Data): 6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
echo "   • RX (Commands): 6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
echo "   • Battery Level: 00002A19-0000-1000-8000-00805F9B34FB"
echo ""
echo "📊 DATOS QUE RECIBIRÁS:"
echo "   • EXACTAMENTE 40 bytes por transmisión LIDAR"
echo "   • 20 mediciones de distancia (2 bytes c/u, little-endian)"
echo "   • Frecuencia: Cada 200ms (5 Hz, como el ESP32 real)"
echo "   • Datos binarios (no JSON) para mediciones LIDAR"
echo "   • Batería: Solo cuando cambia o cada hora"
echo "   • Comandos: TRANSMIT_ON/TRANSMIT_OFF"
echo ""

# Verificar si la app está compilada
if [ ! -f "../.build/debug/BLESimulator" ]; then
    echo "⚠️  Compilando la aplicación..."
    cd .. && swift build
    if [ $? -ne 0 ]; then
        echo "❌ Error en la compilación"
        exit 1
    fi
    echo "✅ Compilación exitosa"
    echo ""
    cd Scripts
fi

echo "🚀 INICIANDO SIMULACIÓN ESP32 LIDAR..."
echo ""
echo "💡 CÓMO PROBAR:"
echo "   1. Abre un escáner BLE (LightBlue, nRF Connect, etc.)"
echo "   2. Busca 'SME_LIDAR' o el Service UUID"
echo "   3. Conecta al dispositivo"
echo "   4. Suscríbete a la característica TX para recibir datos LIDAR"
echo "   5. Escribe 'TRANSMIT_ON' en la característica RX para activar"
echo "   6. Escribe 'TRANSMIT_OFF' para detener la transmisión"
echo "   7. Lee la característica Battery Level para ver el estado"
echo ""
echo "📱 DATOS ESPERADOS:"
echo "   • Frecuencia: 5Hz (cada 200ms) - CORREGIDO"
echo "   • Formato: 40 bytes binarios (no JSON)"
echo "   • Contenido: 20 distancias × 2 bytes little-endian"
echo "   • Ejemplo: E2 04 AC 04 28 05... (40 bytes total)"
echo "   • Batería: Solo actualiza cuando cambia o cada hora"
echo ""

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

# Ejecutar la aplicación con la configuración del ESP32
echo "🎯 Cargando configuración ESP32 LIDAR..."
./.build/debug/BLESimulator ConfigurationExamples/esp32_lidar_device.json

echo ""
echo "📋 DESPUÉS DE LA PRUEBA:"
echo "   • ¿Pudiste conectarte al dispositivo SME_LIDAR?"
echo "   • ¿Recibiste datos de distancia realistas?"
echo "   • ¿Funcionaron los comandos TRANSMIT_ON/OFF?"
echo "   • ¿Se actualizó correctamente el nivel de batería?"
echo ""
echo "🔧 PERSONALIZACIÓN:"
echo "   • Edita ConfigurationExamples/esp32_lidar_device.json"
echo "   • Cambia las distancias, intervalos o UUIDs"
echo "   • Modifica los comandos disponibles"
echo "   • Ajusta la simulación de batería"
