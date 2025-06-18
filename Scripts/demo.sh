#!/bin/bash

# Demo script para BLE Simulator con configuraciones JSON completas
echo "🎯 BLE Simulator - Demo de Configuraciones Avanzadas"
echo "================================================="

# Verificar que el proyecto esté compilado
if [ ! -f ".build/debug/BLESimulator" ]; then
    echo "⚠️  Compilando proyecto..."
    swift build
    if [ $? -ne 0 ]; then
        echo "❌ Error en la compilación"
        exit 1
    fi
fi

echo ""
echo "📋 Archivos de configuración disponibles:"
echo ""

# Mostrar archivos de configuración disponibles
for file in example_data/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📄 $filename"
        
        # Mostrar información básica del archivo
        if command -v jq &> /dev/null; then
            # Si jq está disponible, mostrar información estructurada
            device_name=$(jq -r '.device_config.name // .deviceName // "N/A"' "$file" 2>/dev/null)
            ble_name=$(jq -r '.ble_config.advertised_name // "N/A"' "$file" 2>/dev/null)
            interval=$(jq -r '.data_config.update_interval_seconds // "N/A"' "$file" 2>/dev/null)
            
            echo "   📱 Dispositivo: $device_name"
            echo "   📡 Nombre BLE: $ble_name"
            echo "   ⏱️  Intervalo: ${interval}s"
        else
            # Si no hay jq, mostrar información básica
            echo "   📝 Tamaño: $(wc -c < "$file") bytes"
        fi
        echo ""
    fi
done

echo "🚀 Instrucciones de uso:"
echo ""
echo "1. Para usar configuración avanzada:"
echo "   📂 Selecciona 'complete_device_config.json'"
echo "   ⚙️  Usa el botón 'Editar' para modificar configuraciones"
echo "   💾 Guarda tus cambios con 'Guardar Configuración'"
echo ""
echo "2. Para usar configuración simple (compatibilidad):"
echo "   📂 Selecciona cualquier otro archivo JSON"
echo ""
echo "3. Funcionalidades avanzadas:"
echo "   🔧 Editor de configuración en tiempo real"
echo "   📊 Múltiples características BLE por dispositivo"
echo "   🎲 Variación aleatoria de datos configurable"
echo "   ⏰ Frecuencia de muestreo ajustable"
echo "   🔄 Ciclo automático de datos"
echo ""
echo "4. Para probar la conexión:"
echo "   📱 Usa apps como 'LightBlue Explorer' o 'nRF Connect'"
echo "   🔍 Busca el dispositivo con el nombre configurado"
echo "   📡 Conecta y suscríbete a las características"
echo ""

# Verificar si hay apps de testing comunes instaladas
echo "🔍 Verificando herramientas de testing disponibles:"
echo ""

# Buscar apps comunes en /Applications
apps_found=0
if [ -d "/Applications/LightBlue Explorer.app" ]; then
    echo "✅ LightBlue Explorer encontrado"
    apps_found=$((apps_found + 1))
fi

if [ -d "/Applications/nRF Connect.app" ]; then
    echo "✅ nRF Connect encontrado"
    apps_found=$((apps_found + 1))
fi

if [ -d "/Applications/Bluetooth Screen.app" ]; then
    echo "✅ Bluetooth Screen encontrado"
    apps_found=$((apps_found + 1))
fi

if [ $apps_found -eq 0 ]; then
    echo "ℹ️  No se encontraron apps de testing BLE comunes"
    echo "   📥 Recomendamos instalar 'LightBlue Explorer' desde App Store"
fi

echo ""
echo "▶️  Para ejecutar la aplicación:"
echo "   swift run BLESimulator"
echo "   o presiona F5 en VS Code"
echo ""
echo "📚 Consulta README.md para más información detallada"
echo ""
echo "🎉 ¡Tu BLE Simulator está listo para simular dispositivos avanzados!"
