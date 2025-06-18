import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEPeripheralManager()
    @State private var selectedJSONFile: URL?
    @State private var isFilePickerPresented = false
    @State private var logMessages: [String] = []
    @State private var currentConfiguration: DeviceConfiguration?
    @State private var showingConfigEditor = false
    
    // Optional parameter to load initial configuration
    let initialConfigFile: String?
    
    init(initialConfigFile: String? = nil) {
        self.initialConfigFile = initialConfigFile
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                Text("BLE Simulator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("macOS Bluetooth Low Energy Peripheral Simulator")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // Configuration Panel
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Configuration")
                        .font(.headline)
                    Spacer()
                    if currentConfiguration != nil {
                        Button("Edit") {
                            showingConfigEditor = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if let config = currentConfiguration {
                    // Show current configuration summary
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Device:")
                            Spacer()
                            Text(config.deviceConfig.name)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("BLE Name:")
                            Spacer()
                            Text(config.bleConfig.advertisedName)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Data Interval:")
                            Spacer()
                            Text("\(config.dataConfig.updateIntervalSeconds, specifier: "%.1f")s")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Characteristics:")
                            Spacer()
                            Text("\(config.bleConfig.characteristics.count)")
                                .fontWeight(.medium)
                        }
                    }
                } else {
                    HStack {
                        Text("JSON File:")
                        Spacer()
                        Button(selectedJSONFile?.lastPathComponent ?? "Select JSON File") {
                            isFilePickerPresented = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                HStack {
                    Text("BLE Status:")
                    Spacer()
                    Text(bleManager.isAdvertising ? "Advertising" : "Stopped")
                        .foregroundColor(bleManager.isAdvertising ? .green : .red)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Connected Devices:")
                    Spacer()
                    Text("\(bleManager.connectedDevices)")
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if bleManager.isAdvertising {
                        bleManager.stopAdvertising()
                        addLogMessage("BLE simulation stopped")
                    } else {
                        if let config = currentConfiguration {
                            bleManager.startAdvertising(with: config)
                            addLogMessage("BLE simulation started")
                        } else {
                            addLogMessage("Please select and load a JSON file first")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: bleManager.isAdvertising ? "stop.circle" : "play.circle")
                        Text(bleManager.isAdvertising ? "Stop Simulation" : "Start Simulation")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentConfiguration == nil && !bleManager.isAdvertising)
                
                Button("Clear Log") {
                    logMessages.removeAll()
                }
                .buttonStyle(.bordered)
                
                if currentConfiguration != nil {
                    Button("Save Configuration") {
                        saveCurrentConfiguration()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Log Area
            VStack(alignment: .leading) {
                Text("Activity Log")
                    .font(.headline)
                
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(logMessages.enumerated()), id: \.offset) { index, message in
                                Text(message)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(index)
                            }
                        }
                        .onChange(of: logMessages.count) { _ in
                            if !logMessages.isEmpty {
                                proxy.scrollTo(logMessages.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(height: 150)
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding()
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedJSONFile = url
                    loadConfiguration(from: url)
                }
            case .failure(let error):
                addLogMessage("Error selecting file: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showingConfigEditor) {
            if let config = currentConfiguration {
                DeviceConfigurationView(
                    configuration: Binding(
                        get: { config },
                        set: { currentConfiguration = $0 }
                    ),
                    onSave: { newConfig in
                        currentConfiguration = newConfig
                        addLogMessage("Configuration updated")
                        
                        // If currently advertising, restart with new config
                        if bleManager.isAdvertising {
                            bleManager.stopAdvertising()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                bleManager.startAdvertising(with: newConfig)
                                addLogMessage("Simulation restarted with new configuration")
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            addLogMessage("BLE Simulator started")
            bleManager.onLogMessage = { message in
                addLogMessage(message)
            }
            
            // Load initial configuration if provided
            if let configFile = initialConfigFile {
                loadInitialConfigFile(configFile)
            } else {
                addLogMessage("Select a JSON configuration file")
            }
        }
    }
    
    private func loadConfiguration(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let configuration = try decoder.decode(DeviceConfiguration.self, from: data)
            
            self.currentConfiguration = configuration
            addLogMessage("Configuration loaded: \(configuration.deviceConfig.name)")
            addLogMessage("BLE Device: \(configuration.bleConfig.advertisedName)")
            addLogMessage("Characteristics: \(configuration.bleConfig.characteristics.count)")
            addLogMessage("Data interval: \(configuration.dataConfig.updateIntervalSeconds)s")
            
        } catch {
            addLogMessage("Error loading configuration: \(error.localizedDescription)")
            currentConfiguration = nil
        }
    }
    
    private func saveCurrentConfiguration() {
        guard let config = currentConfiguration else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "\(config.deviceConfig.name.replacingOccurrences(of: " ", with: "_")).json"
        
        if savePanel.runModal() == .OK {
            guard let url = savePanel.url else { return }
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(config)
                try data.write(to: url)
                addLogMessage("Configuration saved to: \(url.lastPathComponent)")
            } catch {
                addLogMessage("Error saving configuration: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadInitialConfigFile(_ filePath: String) {
        let url: URL
        
        // If the path is relative, make it relative to the current directory
        if filePath.hasPrefix("/") {
            url = URL(fileURLWithPath: filePath)
        } else {
            let currentDirectory = FileManager.default.currentDirectoryPath
            url = URL(fileURLWithPath: currentDirectory).appendingPathComponent(filePath)
        }
        
        addLogMessage("🔄 Loading configuration from: \(filePath)")
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            addLogMessage("❌ File not found: \(url.path)")
            addLogMessage("💡 Select a JSON configuration file manually")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let configuration = try decoder.decode(DeviceConfiguration.self, from: data)
            
            self.currentConfiguration = configuration
            self.selectedJSONFile = url
            
            addLogMessage("✅ Configuration loaded: \(configuration.deviceConfig.name)")
            addLogMessage("📱 BLE Device: \(configuration.bleConfig.advertisedName)")
            addLogMessage("🆔 Service UUID: \(configuration.bleConfig.serviceUUID)")
            addLogMessage("💡 Click 'Start Advertising' to begin simulation")
            
        } catch {
            addLogMessage("❌ Error loading configuration: \(error.localizedDescription)")
            addLogMessage("💡 Verify that the JSON file has the correct format")
        }
    }
    
    private func addLogMessage(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logMessages.append("[\(timestamp)] \(message)")
    }
}

import AppKit // Needed for NSSavePanel

#Preview {
    ContentView()
}
