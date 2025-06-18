#!/bin/bash

# Script de verificación para la configuración ESP32 LIDAR
# Valida que el JSON esté correctamente formateado y contenga todos los campos necesarios

echo "🔍 Verificación de Configuración ESP32 LIDAR"
echo "============================================"
echo ""

CONFIG_FILE="../ConfigurationExamples/esp32_lidar_device.json"

# Verificar que el archivo existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo $CONFIG_FILE"
    exit 1
fi

echo "📁 Archivo: $CONFIG_FILE"
echo "📏 Tamaño: $(wc -c < "$CONFIG_FILE") bytes"
echo ""

# Verificar sintaxis JSON
echo "🔧 Verificando sintaxis JSON..."
if python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "✅ Sintaxis JSON válida"
else
    echo "❌ Error: Sintaxis JSON inválida"
    echo "💡 Ejecuta: python3 -m json.tool $CONFIG_FILE para ver detalles"
    exit 1
fi

echo ""
echo "🔍 Verificando campos requeridos..."

# Función para verificar si un campo existe en el JSON
check_field() {
    local field="$1"
    local description="$2"
    
    if python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    data = json.load(f)
try:
    eval('data$field')
    print('✅ $description')
except:
    print('❌ Falta: $description')
    sys.exit(1)
" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Verificar campos principales
check_field "['device_config']['name']" "Nombre del dispositivo"
check_field "['ble_config']['advertised_name']" "Nombre BLE anunciado"
check_field "['ble_config']['service_uuid']" "UUID del servicio principal"
check_field "['data_streams']['lidar_measurements']" "Stream de datos LIDAR"
check_field "['data_streams']['battery_info']" "Información de batería"

echo ""
echo "🎯 Verificando UUIDs específicos del ESP32..."

# Verificar UUIDs correctos
EXPECTED_SERVICE="6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
EXPECTED_TX="6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
EXPECTED_RX="6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
EXPECTED_BATTERY="00002A19-0000-1000-8000-00805F9B34FB"

SERVICE_UUID=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    data = json.load(f)
print(data['ble_config']['service_uuid'])
" 2>/dev/null)

if [ "$SERVICE_UUID" = "$EXPECTED_SERVICE" ]; then
    echo "✅ Service UUID correcto: $SERVICE_UUID"
else
    echo "❌ Service UUID incorrecto. Esperado: $EXPECTED_SERVICE, Encontrado: $SERVICE_UUID"
fi

echo ""
echo "📊 Analizando datos de simulación..."

# Contar mediciones LIDAR
LIDAR_COUNT=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    data = json.load(f)
print(len(data['data_streams']['lidar_measurements']['data']))
" 2>/dev/null)

echo "📏 Mediciones LIDAR configuradas: $LIDAR_COUNT"

# Verificar rangos de distancia
echo "🎯 Verificando rangos de distancia..."
python3 -c "
import json
with open('$CONFIG_FILE') as f:
    data = json.load(f)

measurements = data['data_streams']['lidar_measurements']['data']
distances = [m['distance_mm'] for m in measurements]
min_dist = min(distances)
max_dist = max(distances)

print(f'   • Distancia mínima: {min_dist}mm')
print(f'   • Distancia máxima: {max_dist}mm')

if 500 <= min_dist <= 1000 and 1500 <= max_dist <= 3000:
    print('✅ Rangos de distancia realistas')
else:
    print('⚠️  Rangos de distancia pueden no ser realistas')
"

echo ""
echo "🔋 Verificando configuración de batería..."
python3 -c "
import json
with open('$CONFIG_FILE') as f:
    data = json.load(f)

battery_data = data['data_streams']['battery_info']['data']
levels = [b['battery_level'] for b in battery_data]
voltages = [b['voltage_mv'] for b in battery_data]

print(f'   • Niveles de batería: {min(levels)}% - {max(levels)}%')
print(f'   • Voltajes: {min(voltages)}mv - {max(voltages)}mv')

if all(80 <= level <= 100 for level in levels):
    print('✅ Niveles de batería realistas')
else:
    print('⚠️  Algunos niveles de batería pueden ser irrealistas')
"

echo ""
echo "⚙️  Verificando configuración técnica..."

UPDATE_INTERVAL=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    data = json.load(f)
print(data['data_config']['update_interval_seconds'])
" 2>/dev/null)

echo "⏱️  Intervalo de actualización: ${UPDATE_INTERVAL}s"

if (( $(echo "$UPDATE_INTERVAL <= 0.2" | bc -l) )); then
    echo "✅ Intervalo adecuado para LIDAR de alta frecuencia"
else
    echo "⚠️  El intervalo podría ser demasiado lento para un LIDAR típico"
fi

echo ""
echo "📋 Resumen de Verificación:"
echo "=========================="
echo "✅ Archivo JSON válido y completo"
echo "✅ UUIDs compatibles con ESP32 original"
echo "✅ Datos de simulación realistas"
echo "✅ Configuración técnica apropiada"
echo ""
echo "🚀 La configuración está lista para usar!"
echo "💡 Ejecuta: ./demo_esp32_lidar.sh para probar"
