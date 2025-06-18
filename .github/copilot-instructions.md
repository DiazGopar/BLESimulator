<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# BLE Simulator macOS App

This is a macOS application that simulates a Bluetooth Low Energy (BLE) peripheral device for testing purposes. The app:

- Acts as a virtual BLE peripheral using Core Bluetooth framework
- Reads data from JSON files to simulate a device, this JSONfiles provide all information about the device.
- The JSON files provide with name, services, characteristics, and data to be sent.
- the JSON files can be modified to simulate different devices or data streams.
- The JSON files configure the data send speed, and all the parameters, and the UI must reflect the changes made in the JSON files, and allow to modify them at runtime.
- Provides a simple interface to start/stop the BLE simulation
- Allows configuration of BLE services and characteristics
- Sends periodic data updates to connected central devices

## Development Guidelines

- Use Swift 6.0+ and SwiftUI for the UI
- Follow iOS/macOS development best practices
- Use Core Bluetooth framework for BLE functionality
- Implement proper error handling for Bluetooth operations
- Use Codable for JSON data parsing
- Follow MVC or MVVM architecture patterns
- Include proper logging for debugging BLE operations
- All UI elements should be accessible and user-friendly
- All UI elements should be responsive and adapt to different screen sizes
- All UI elements should be tested on different macOS versions
- All UI must be in english, but the JSON files can be in any language
- All comments should be in english
