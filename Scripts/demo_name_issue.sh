#!/bin/bash

# Demo script for BLE Simulator - Device Name Identification
# This script explains the macOS BLE name display issue and provides solutions

echo "🔷 BLE Simulator - Device Name Identification Demo"
echo "=================================================="
echo ""
echo "📝 PROBLEMA COMÚN EN macOS:"
echo "   Cuando macOS actúa como periférico BLE, el sistema operativo"
echo "   a menudo sobrescribe el nombre anunciado con el nombre del ordenador."
echo ""
echo "🔍 CÓMO IDENTIFICAR TU DISPOSITIVO SIMULADO:"
echo "   1. Busca el Service UUID en tu escáner BLE"
echo "   2. Filtra por UUID: 12345678-1234-1234-1234-123456789012"
echo "   3. Conecta y lee la característica 'Device Info'"
echo "   4. Los manufacturer data pueden mostrar 'IoT Solutions'"
echo ""
echo "📱 ESCÁNERES BLE RECOMENDADOS:"
echo "   • LightBlue Explorer (iOS/macOS)"
echo "   • BLE Scanner (Android)"
echo "   • nRF Connect (iOS/Android)"
echo "   • Bluetooth Explorer (macOS)"
echo ""

# Verificar si la app está compilada
if [ ! -f ".build/debug/BLESimulator" ]; then
    echo "⚠️  La app no está compilada. Ejecutando compilación..."
    ./build.sh
    echo ""
fi

echo "🚀 Iniciando BLE Simulator..."
echo "   La configuración se cargará automáticamente"
echo "   Observa los logs para ver el Service UUID"
echo ""
echo "💡 PASOS PARA PROBAR:"
echo "   1. Abre un escáner BLE en tu móvil"
echo "   2. Busca dispositivos cerca"
echo "   3. Localiza el Service UUID: 12345678-1234-1234-1234-123456789012"
echo "   4. Conecta al dispositivo"
echo "   5. Lee la característica 'Device Info' para confirmar"
echo ""

# Ejecutar la aplicación
./.build/debug/BLESimulator

echo ""
echo "📊 DESPUÉS DE LA PRUEBA:"
echo "   • ¿Encontraste el dispositivo por Service UUID?"
echo "   • ¿Qué nombre mostró tu escáner BLE?"
echo "   • ¿Pudiste leer la información del dispositivo?"
echo ""
echo "🔧 Si necesitas cambiar la configuración:"
echo "   • Edita example_data/complete_device_config.json"
echo "   • Cambia el 'advertised_name' y 'service_uuid'"
echo "   • Reinicia la aplicación"
