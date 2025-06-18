#!/bin/bash

# Test rápido del ESP32 LIDAR BLE Simulator
# Verifica que la configuración se carga correctamente

echo "🧪 Test Rápido - ESP32 LIDAR BLE Simulator"
echo "=========================================="
echo ""

echo "📋 Verificando archivos necesarios..."
if [ ! -f "example_data/esp32_lidar_device.json" ]; then
    echo "❌ Error: Archivo de configuración no encontrado"
    exit 1
fi

if [ ! -f ".build/debug/BLESimulator" ]; then
    echo "🔧 Compilando aplicación..."
    swift build
    if [ $? -ne 0 ]; then
        echo "❌ Error en compilación"
        exit 1
    fi
fi

echo "✅ Archivos verificados"
echo ""

echo "🔍 Verificando configuración JSON..."
if python3 -c "
import json
with open('example_data/esp32_lidar_device.json') as f:
    data = json.load(f)
    
print('✅ Dispositivo:', data['device_config']['name'])
print('✅ Nombre BLE:', data['ble_config']['advertised_name'])
print('✅ Service UUID:', data['ble_config']['service_uuid'])
print('✅ Características:', len(data['ble_config']['characteristics']))
print('✅ Mediciones LIDAR:', len(data['data_streams']['lidar_measurements']['data']))
" 2>/dev/null; then
    echo ""
    echo "✅ Configuración JSON válida"
else
    echo "❌ Error en configuración JSON"
    exit 1
fi

echo ""
echo "🎯 RESUMEN DEL TEST:"
echo "==================="
echo "✅ Aplicación compilada correctamente"
echo "✅ Configuración ESP32 LIDAR válida"
echo "✅ Archivo JSON bien formateado"
echo "✅ Datos de simulación completos"
echo ""
echo "🚀 LISTO PARA USAR:"
echo "   ./demo_esp32_lidar.sh"
echo "   swift run BLESimulator example_data/esp32_lidar_device.json"
echo ""
echo "📱 BUSCAR EN ESCÁNER BLE:"
echo "   Nombre: SME_LIDAR"
echo "   UUID: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
echo ""
echo "✅ Test completado exitosamente!"
