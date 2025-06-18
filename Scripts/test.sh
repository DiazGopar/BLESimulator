#!/bin/bash

# Test script to validate JSON files and basic app functionality
echo "🧪 Testing BLE Simulator..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed or not in PATH"
    exit 1
fi

echo "✅ Swift is available"

# Validate JSON files
echo "📄 Validating JSON files..."

JSON_FILES=(
    "example_data/sensor_data.json"
    "example_data/sensor_sequence.json"
    "example_data/heart_rate_monitor.json"
)

for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            echo "✅ $file is valid JSON"
        else
            echo "❌ $file has invalid JSON format"
            exit 1
        fi
    else
        echo "❌ $file not found"
        exit 1
    fi
done

# Build the project
echo "🔨 Building project..."
if swift build; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Check if the executable exists
if [ -f ".build/debug/BLESimulator" ]; then
    echo "✅ Executable created successfully"
else
    echo "❌ Executable not found"
    exit 1
fi

echo "🎉 All tests passed! The BLE Simulator is ready to use."
echo ""
echo "To run the app:"
echo "  swift run BLESimulator"
echo ""
echo "Or use VS Code:"
echo "  - Press F5 to debug"
echo "  - Use Command Palette: 'Tasks: Run Task' → 'Run BLE Simulator'"
