#!/bin/bash

# Quick validation of the reorganized BLE Simulator
echo "🔍 QUICK VALIDATION - BLE Simulator Structure"
echo "============================================="
echo ""

PASS=0
TOTAL=0

test_file() {
    TOTAL=$((TOTAL + 1))
    if [ -f "$1" ]; then
        echo "✅ $1 exists"
        PASS=$((PASS + 1))
    else
        echo "❌ $1 missing"
    fi
}

test_executable() {
    TOTAL=$((TOTAL + 1))
    if [ -x "$1" ]; then
        echo "✅ $1 is executable"
        PASS=$((PASS + 1))
    else
        echo "❌ $1 not executable"
    fi
}

echo "📋 TESTING CORE FILES..."
test_file "ConfigurationExamples/esp32_lidar_device.json"
test_file "Sources/BLESimulator/BLEPeripheralManager.swift"
test_file "Sources/BLESimulator/BLESimulatorApp.swift"
test_file "Sources/Views/ContentView.swift"
test_file "Documentation/ESP32_LIDAR_SIMULATION.md"
test_file "Reference/ble_lidar_esp32.ino"

echo ""
echo "🔧 TESTING SCRIPTS..."
test_executable "Scripts/demo_esp32_lidar.sh"
test_executable "ble-simulator"

echo ""
echo "⚙️  TESTING COMPILATION..."
TOTAL=$((TOTAL + 1))
if swift build > /dev/null 2>&1; then
    echo "✅ Swift compilation successful"
    PASS=$((PASS + 1))
else
    echo "❌ Swift compilation failed"
fi

echo ""
echo "📊 TESTING JSON CONFIGURATION..."
TOTAL=$((TOTAL + 1))
if python3 -m json.tool ConfigurationExamples/esp32_lidar_device.json > /dev/null 2>&1; then
    echo "✅ ESP32 JSON configuration is valid"
    PASS=$((PASS + 1))
else
    echo "❌ ESP32 JSON configuration is invalid"
fi

echo ""
echo "📋 SUMMARY"
echo "=========="
echo "✅ Tests passed: $PASS/$TOTAL"

if [ $PASS -eq $TOTAL ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED! The reorganized BLE Simulator is ready to use."
    echo ""
    echo "🚀 To run the ESP32 LIDAR simulator:"
    echo "   ./ble-simulator run ConfigurationExamples/esp32_lidar_device.json"
    echo ""
    echo "📱 To run the demo:"
    echo "   ./Scripts/demo_esp32_lidar.sh"
else
    echo ""
    echo "⚠️  Some tests failed. Please check the missing files."
fi
