import SwiftUI

struct DeviceConfigurationView: View {
    @Binding var configuration: DeviceConfiguration
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (DeviceConfiguration) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                // Device Information Section
                Section("Device Information") {
                    TextField("Name", text: $configuration.deviceConfig.name)
                    TextField("Manufacturer", text: $configuration.deviceConfig.manufacturer)
                    TextField("Model", text: $configuration.deviceConfig.model)
                    TextField("Serial Number", text: $configuration.deviceConfig.serialNumber)
                }
                
                // BLE Configuration Section
                Section("BLE Configuration") {
                    TextField("Advertised Name", text: $configuration.bleConfig.advertisedName)
                    TextField("Service UUID", text: $configuration.bleConfig.serviceUUID)
                        .font(.system(.body, design: .monospaced))
                }
                
                // Data Configuration Section
                Section("Data Configuration") {
                    HStack {
                        Text("Update Interval (sec)")
                        Spacer()
                        TextField("Seconds", value: $configuration.dataConfig.updateIntervalSeconds, format: .number)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Auto Cycle", isOn: $configuration.dataConfig.autoCycle)
                    Toggle("Random Values", isOn: $configuration.dataConfig.randomizeValues)
                    
                    if configuration.dataConfig.randomizeValues {
                        HStack {
                            Text("Variation Range")
                            Spacer()
                            TextField("0.0-1.0", value: $configuration.dataConfig.randomizeRange, format: .number)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                // Characteristics Section (Read-only for now)
                Section("BLE Characteristics") {
                    ForEach(configuration.bleConfig.characteristics, id: \.id) { characteristic in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(characteristic.name)
                                .font(.headline)
                            Text("UUID: \(characteristic.uuid)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text("Data: \(characteristic.dataKey)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Properties: \(characteristic.properties.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Data Streams Section (Summary only for now)
                Section("Data Streams") {
                    ForEach(Array(configuration.dataStreams.keys.sorted()), id: \.self) { key in
                        if let stream = configuration.dataStreams[key] {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(key)
                                    .font(.headline)
                                Text("Type: \(stream.type)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                switch stream.data {
                                case .array(let array):
                                    Text("\(array.count) elements in sequence")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                case .object(let object):
                                    Text("\(object.keys.count) properties")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Device Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(configuration)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
