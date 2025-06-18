#!/bin/bash

# Build script for BLE Simulator macOS app
echo "Building BLE Simulator..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "Error: Swift is not installed or not in PATH"
    echo "Please install Xcode or Swift toolchain"
    exit 1
fi

# Build the application
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Run the app with: swift run BLESimulator"
else
    echo "Build failed!"
    exit 1
fi
