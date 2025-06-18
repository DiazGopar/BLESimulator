import Foundation
import CoreBluetooth

class BLEPeripheralManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isAdvertising = false
    @Published var connectedDevices = 0
    @Published var currentConfiguration: DeviceConfiguration?
    
    // MARK: - Private Properties
    private var peripheralManager: CBPeripheralManager?
    private var dataService: CBMutableService?
    private var characteristics: [String: CBMutableCharacteristic] = [:]
    private var dataUpdateTimer: Timer?
    private var currentDataIndices: [String: Int] = [:]
    private var lastBatteryUpdate: Date = Date.distantPast
    
    // MARK: - Public Properties
    var onLogMessage: ((String) -> Void)?
    
    // Dynamic BLE configuration - loaded from JSON
    private var serviceUUID: CBUUID?
    private var characteristicConfigs: [CharacteristicConfig] = []
    
    override init() {
        super.init()
        setupPeripheralManager()
    }
    
    deinit {
        stopAdvertising()
    }
    
    // MARK: - Public Methods
    func startAdvertising(with configuration: DeviceConfiguration) {
        guard peripheralManager?.state == .poweredOn else {
            onLogMessage?("Bluetooth is not available or powered on")
            return
        }
        
        // Store configuration
        self.currentConfiguration = configuration
        
        // Stop any previous advertising to clean the state
        if peripheralManager?.isAdvertising == true {
            peripheralManager?.stopAdvertising()
            onLogMessage?("Stopped previous advertising")
            
            // Small pause to ensure it stops completely
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.continueStartAdvertising(with: configuration)
            }
        } else {
            continueStartAdvertising(with: configuration)
        }
    }
    
    private func continueStartAdvertising(with configuration: DeviceConfiguration) {
        // Setup BLE service with new configuration
        if setupServiceFromConfiguration(configuration) {
            startAdvertisingService(with: configuration)
            startDataUpdateTimer(with: configuration)
            
            DispatchQueue.main.async {
                self.isAdvertising = true
            }
            
            onLogMessage?("Started advertising '\(configuration.bleConfig.advertisedName)'")
        }
    }
    
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
        dataUpdateTimer?.invalidate()
        dataUpdateTimer = nil
        characteristics.removeAll()
        currentDataIndices.removeAll()
        
        DispatchQueue.main.async {
            self.isAdvertising = false
            self.connectedDevices = 0
        }
        
        onLogMessage?("Stopped advertising and data updates")
    }
    
    // MARK: - Private Methods
    private func setupPeripheralManager() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    private func setupServiceFromConfiguration(_ configuration: DeviceConfiguration) -> Bool {
        let serviceUUID = CBUUID(string: configuration.bleConfig.serviceUUID)
        
        self.serviceUUID = serviceUUID
        self.characteristicConfigs = configuration.bleConfig.characteristics
        
        // Create characteristics
        var createdCharacteristics: [CBMutableCharacteristic] = []
        
        for config in configuration.bleConfig.characteristics {
            let uuid = CBUUID(string: config.uuid)
            
            let properties = CBCharacteristicProperties(config.properties)
            let permissions = CBAttributePermissions(config.permissions)
            
            let characteristic = CBMutableCharacteristic(
                type: uuid,
                properties: properties,
                value: nil,
                permissions: permissions
            )
            
            // If it's a device information characteristic, pre-load with data
            if config.dataKey == "device_info" {
                let deviceInfo: [String: Any] = [
                    "device_name": configuration.bleConfig.advertisedName,
                    "system_name": configuration.deviceConfig.name,
                    "manufacturer": configuration.deviceConfig.manufacturer,
                    "model": configuration.deviceConfig.model,
                    "serial_number": configuration.deviceConfig.serialNumber,
                    "service_uuid": configuration.bleConfig.serviceUUID,
                    "ble_identifier": "\(configuration.deviceConfig.manufacturer)-\(configuration.deviceConfig.model)",
                    "last_updated": Date().timeIntervalSince1970,
                    "identification_tip": "Look for Service UUID \(configuration.bleConfig.serviceUUID) in BLE scanners"
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: deviceInfo, options: .prettyPrinted) {
                    characteristic.value = jsonData
                }
            }
            
            characteristics[config.dataKey] = characteristic
            createdCharacteristics.append(characteristic)
            currentDataIndices[config.dataKey] = 0
            
            onLogMessage?("Created characteristic '\(config.name)' for \(config.dataKey)")
        }
        
        // Create service
        dataService = CBMutableService(type: serviceUUID, primary: true)
        dataService?.characteristics = createdCharacteristics
        
        // Add service to peripheral manager
        peripheralManager?.add(dataService!)
        
        onLogMessage?("BLE service configured with UUID: \(serviceUUID.uuidString)")
        return true
    }
    
    private func startAdvertisingService(with configuration: DeviceConfiguration) {
        guard let serviceUUID = self.serviceUUID else { return }
        
        // Make sure to stop any previous advertising
        peripheralManager?.stopAdvertising()
        
        // In macOS, the local name is often overridden by the system
        // However, we include all possible information for identification
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: configuration.bleConfig.advertisedName,
            CBAdvertisementDataManufacturerDataKey: createManufacturerData(for: configuration),
            // Add connection available flag
            CBAdvertisementDataIsConnectable: true
        ]
        
        onLogMessage?("🔧 Configuring BLE advertising...")
        onLogMessage?("📱 Configured name: '\(configuration.bleConfig.advertisedName)'")
        onLogMessage?("🆔 Service UUID: \(serviceUUID.uuidString)")
        onLogMessage?("⚠️  NOTE: In macOS, some BLE scanners may show the computer name")
        onLogMessage?("    instead of the configured name. Look for the Service UUID to identify the device.")
        
        peripheralManager?.startAdvertising(advertisementData)
        onLogMessage?("📡 Starting BLE advertising...")
    }
    
    private func createManufacturerData(for configuration: DeviceConfiguration) -> Data {
        // Create more robust manufacturer data for identification
        var data = Data()
        
        // Add unique manufacturer identifier (2 bytes)
        // We use a fictional but consistent ID
        data.append(contentsOf: [0xFF, 0xFE]) // Fictional Company ID
        
        // Add device information in compact format
        let deviceInfo = "\(configuration.deviceConfig.manufacturer):\(configuration.deviceConfig.name)"
        let deviceBytes = Array(deviceInfo.utf8.prefix(20)) // Maximum 20 bytes for name
        data.append(contentsOf: deviceBytes)
        
        // Add separator and model
        data.append(0x00)
        let modelBytes = Array(configuration.deviceConfig.model.utf8.prefix(10))
        data.append(contentsOf: modelBytes)
        
        return data
    }
    
    private func startDataUpdateTimer(with configuration: DeviceConfiguration) {
        let interval = configuration.dataConfig.updateIntervalSeconds
        
        dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.sendDataUpdates()
        }
        onLogMessage?("Started data update timer (\(interval) second intervals)")
    }
    
    private func sendDataUpdates() {
        guard let configuration = currentConfiguration else { return }
        
        for (dataKey, characteristic) in characteristics {
            guard let dataStream = configuration.dataStreams[dataKey] else { continue }
            
            // Special handling for LIDAR data (40 bytes binary)
            if dataKey == "lidar_measurements" {
                sendLidarBinaryData(to: characteristic, from: dataStream, configuration: configuration)
            } else if dataKey == "battery_info" {
                // Battery: only send if changed or it's time
                sendBatteryDataIfNeeded(to: characteristic, from: dataStream, configuration: configuration)
            } else {
                // Other data: normal JSON format
                sendJSONData(to: characteristic, from: dataStream, dataKey: dataKey, configuration: configuration)
            }
        }
    }
    
    private func sendLidarBinaryData(to characteristic: CBMutableCharacteristic, from dataStream: DataStream, configuration: DeviceConfiguration) {
        let dataToSend = getDataForStream(dataStream, dataKey: "lidar_measurements", configuration: configuration)
        
        // Generate 40 binary bytes simulating the ESP32
        var binaryData = Data()
        
        if let distancesArray = dataToSend["distances_mm"] as? [Int] {
            // Take up to 20 distances (40 bytes = 20 distances × 2 bytes each)
            let distances = Array(distancesArray.prefix(20))
            
            for distance in distances {
                let clampedDistance = max(0, min(65535, distance)) // 16-bit limit
                let lowByte = UInt8(clampedDistance & 0xFF)
                let highByte = UInt8((clampedDistance >> 8) & 0xFF)
                
                // Little-endian: low byte first
                binaryData.append(lowByte)
                binaryData.append(highByte)
            }
            
            // Ensure exactly 40 bytes
            while binaryData.count < 40 {
                binaryData.append(0x00)
            }
            if binaryData.count > 40 {
                binaryData = binaryData.prefix(40)
            }
            
            // Update characteristic with binary data
            characteristic.value = binaryData
            
            // Notify connected centrals
            let success = peripheralManager?.updateValue(
                binaryData,
                for: characteristic,
                onSubscribedCentrals: nil
            ) ?? false
            
            if success {
                onLogMessage?("📡 Sent LIDAR binary data: 40 bytes (\(distances.count) distances)")
                onLogMessage?("   Distances: \(distances.prefix(5).map{"\($0)mm"}.joined(separator: ", "))...")
            } else {
                onLogMessage?("⚠️ Failed to send LIDAR data - BLE queue may be full")
            }
            
        } else {
            onLogMessage?("❌ Invalid LIDAR data format - missing distances_mm array")
        }
    }
    
    private func sendBatteryDataIfNeeded(to characteristic: CBMutableCharacteristic, from dataStream: DataStream, configuration: DeviceConfiguration) {
        // TODO: Implement battery logic only when it changes or every hour
        // For now, send as normal JSON but less frequently
        let now = Date()
        
        // Only update battery every 60 seconds (simulating less frequent changes)
        if now.timeIntervalSince(lastBatteryUpdate) >= 60 {
            sendJSONData(to: characteristic, from: dataStream, dataKey: "battery_info", configuration: configuration)
            lastBatteryUpdate = now
            onLogMessage?("🔋 Battery data updated (hourly/on-change simulation)")
        }
    }
    
    private func sendJSONData(to characteristic: CBMutableCharacteristic, from dataStream: DataStream, dataKey: String, configuration: DeviceConfiguration) {
        let dataToSend = getDataForStream(dataStream, dataKey: dataKey, configuration: configuration)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataToSend, options: [])
            
            // Update characteristic value
            characteristic.value = jsonData
            
            // Notify connected centrals
            let success = peripheralManager?.updateValue(
                jsonData,
                for: characteristic,
                onSubscribedCentrals: nil
            ) ?? false
            
            if success {
                onLogMessage?("📤 Sent \(dataKey) update (\(jsonData.count) bytes)")
            } else {
                onLogMessage?("⚠️ Failed to send \(dataKey) update - queue may be full")
            }
            
        } catch {
            onLogMessage?("❌ Failed to serialize JSON for \(dataKey): \(error.localizedDescription)")
        }
    }
    
    private func getDataForStream(_ stream: DataStream, dataKey: String, configuration: DeviceConfiguration) -> [String: Any] {
        var result: [String: Any] = [:]
        
        switch stream.data {
        case .array(let arrayData):
            if !arrayData.isEmpty {
                let currentIndex = currentDataIndices[dataKey] ?? 0
                result = arrayData[currentIndex]
                
                // Advance index for next update
                if configuration.dataConfig.autoCycle {
                    currentDataIndices[dataKey] = (currentIndex + 1) % arrayData.count
                }
            }
            
        case .object(let objectData):
            result = objectData
            // Add timestamp for static data
            result["timestamp"] = Date().timeIntervalSince1970
            result["updateIndex"] = (currentDataIndices[dataKey] ?? 0) + 1
            currentDataIndices[dataKey] = (currentDataIndices[dataKey] ?? 0) + 1
        }
        
        // Apply randomization if enabled
        if configuration.dataConfig.randomizeValues {
            result = applyRandomization(to: result, range: configuration.dataConfig.randomizeRange)
        }
        
        return result
    }
    
    private func applyRandomization(to data: [String: Any], range: Double) -> [String: Any] {
        var result = data
        
        for (key, value) in data {
            if let doubleValue = value as? Double {
                let variation = Double.random(in: -range...range)
                result[key] = doubleValue + (doubleValue * variation)
            } else if let intValue = value as? Int {
                let variation = Double.random(in: -range...range)
                result[key] = Int(Double(intValue) + (Double(intValue) * variation))
            }
        }
        
        return result
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BLEPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            onLogMessage?("Bluetooth powered on and ready")
        case .poweredOff:
            onLogMessage?("Bluetooth powered off")
        case .unsupported:
            onLogMessage?("Bluetooth not supported on this device")
        case .unauthorized:
            onLogMessage?("Bluetooth access unauthorized")
        case .resetting:
            onLogMessage?("Bluetooth resetting")
        case .unknown:
            onLogMessage?("Bluetooth state unknown")
        @unknown default:
            onLogMessage?("Unknown Bluetooth state")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            onLogMessage?("Failed to add service: \(error.localizedDescription)")
        } else {
            onLogMessage?("Successfully added BLE service")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            onLogMessage?("❌ Failed to start advertising: \(error.localizedDescription)")
        } else {
            onLogMessage?("✅ Successfully started advertising")
            
            // Verify if advertising is actually active
            if peripheral.isAdvertising {
                onLogMessage?("📡 Advertising is active")
                if let config = currentConfiguration {
                    onLogMessage?("🏷️  Device configured as: '\(config.bleConfig.advertisedName)'")
                    onLogMessage?("🔍 Service UUID: \(config.bleConfig.serviceUUID)")
                    onLogMessage?("🏭 Manufacturer: \(config.deviceConfig.manufacturer)")
                    onLogMessage?("📟 Model: \(config.deviceConfig.model)")
                    onLogMessage?("")
                    onLogMessage?("💡 BLE SCANNER SEARCH:")
                    onLogMessage?("   • Look for devices with Service UUID: \(config.bleConfig.serviceUUID)")
                    onLogMessage?("   • Name may appear as '\(config.bleConfig.advertisedName)' or the Mac name")
                    onLogMessage?("   • Some scanners show 'IoT Solutions' in manufacturer data")
                    onLogMessage?("")
                }
            } else {
                onLogMessage?("⚠️ Advertising may not be active")
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        let characteristicName = getCharacteristicName(for: characteristic.uuid) ?? "Unknown"
        onLogMessage?("Central device subscribed to '\(characteristicName)': \(central.identifier)")
        DispatchQueue.main.async {
            self.connectedDevices += 1
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        let characteristicName = getCharacteristicName(for: characteristic.uuid) ?? "Unknown"
        onLogMessage?("Central device unsubscribed from '\(characteristicName)': \(central.identifier)")
        DispatchQueue.main.async {
            self.connectedDevices = max(0, self.connectedDevices - 1)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let characteristicName = getCharacteristicName(for: request.characteristic.uuid) ?? "Unknown"
        onLogMessage?("Received read request for '\(characteristicName)'")
        
        if let characteristic = findCharacteristic(by: request.characteristic.uuid),
           let value = characteristic.value {
            
            if request.offset > value.count {
                peripheral.respond(to: request, withResult: .invalidOffset)
                return
            }
            
            let maxLength = min(512, value.count - request.offset) // BLE has a max transfer size
            let range = request.offset..<(request.offset + maxLength)
            request.value = value.subdata(in: range)
            peripheral.respond(to: request, withResult: .success)
            onLogMessage?("Responded to read request with \(request.value?.count ?? 0) bytes")
        } else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            let characteristicName = getCharacteristicName(for: request.characteristic.uuid) ?? "Unknown"
            onLogMessage?("Received write request for '\(characteristicName)' with \(request.value?.count ?? 0) bytes")
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    private func findCharacteristic(by uuid: CBUUID) -> CBMutableCharacteristic? {
        return characteristics.values.first { $0.uuid == uuid }
    }
    
    private func getCharacteristicName(for uuid: CBUUID) -> String? {
        return characteristicConfigs.first { CBUUID(string: $0.uuid) == uuid }?.name
    }
}

// MARK: - Helper Extensions
extension CBCharacteristicProperties {
    init(_ properties: [String]) {
        var result: CBCharacteristicProperties = []
        
        for property in properties {
            switch property.lowercased() {
            case "read":
                result.insert(.read)
            case "write":
                result.insert(.write)
            case "notify":
                result.insert(.notify)
            case "indicate":
                result.insert(.indicate)
            case "broadcast":
                result.insert(.broadcast)
            case "writeWithoutResponse":
                result.insert(.writeWithoutResponse)
            default:
                break
            }
        }
        
        self = result
    }
}

extension CBAttributePermissions {
    init(_ permissions: [String]) {
        var result: CBAttributePermissions = []
        
        for permission in permissions {
            switch permission.lowercased() {
            case "readable":
                result.insert(.readable)
            case "writeable":
                result.insert(.writeable)
            case "readEncryptionRequired":
                result.insert(.readEncryptionRequired)
            case "writeEncryptionRequired":
                result.insert(.writeEncryptionRequired)
            default:
                break
            }
        }
        
        self = result
    }
}