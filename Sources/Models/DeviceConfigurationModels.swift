import Foundation

// MARK: - Device Configuration Models
struct DeviceConfiguration: Codable {
    var deviceConfig: DeviceInfo
    var bleConfig: BLEConfiguration
    var dataConfig: DataConfiguration
    var dataStreams: [String: DataStream]
    
    enum CodingKeys: String, CodingKey {
        case deviceConfig = "device_config"
        case bleConfig = "ble_config"
        case dataConfig = "data_config"
        case dataStreams = "data_streams"
    }
}

struct DeviceInfo: Codable {
    var name: String
    var manufacturer: String
    var model: String
    var serialNumber: String
    
    enum CodingKeys: String, CodingKey {
        case name, manufacturer, model
        case serialNumber = "serial_number"
    }
}

struct BLEConfiguration: Codable {
    var advertisedName: String
    var serviceUUID: String
    var characteristics: [CharacteristicConfig]
    
    enum CodingKeys: String, CodingKey {
        case advertisedName = "advertised_name"
        case serviceUUID = "service_uuid"
        case characteristics
    }
}

struct CharacteristicConfig: Codable, Identifiable {
    let id = UUID()
    var uuid: String
    var name: String
    var properties: [String]
    var permissions: [String]
    var dataKey: String
    
    enum CodingKeys: String, CodingKey {
        case uuid, name, properties, permissions
        case dataKey = "data_key"
    }
}

struct DataConfiguration: Codable {
    var updateIntervalSeconds: Double
    var dataFormat: String
    var autoCycle: Bool
    var randomizeValues: Bool
    var randomizeRange: Double
    
    enum CodingKeys: String, CodingKey {
        case updateIntervalSeconds = "update_interval_seconds"
        case dataFormat = "data_format"
        case autoCycle = "auto_cycle"
        case randomizeValues = "randomize_values"
        case randomizeRange = "randomize_range"
    }
}

struct DataStream: Codable {
    let type: String
    let data: DataValue
}

enum DataValue: Codable {
    case array([[String: Any]])
    case object([String: Any])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let arrayValue = try? container.decode([[String: AnyDecodable]].self) {
            self = .array(arrayValue.map { dict in
                dict.mapValues { $0.value }
            })
        } else if let objectValue = try? container.decode([String: AnyDecodable].self) {
            self = .object(objectValue.mapValues { $0.value })
        } else {
            throw DecodingError.typeMismatch(DataValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected array or object"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array.map { dict in
                dict.mapValues(AnyEncodable.init)
            })
        case .object(let object):
            try container.encode(object.mapValues(AnyEncodable.init))
        }
    }
}

// MARK: - Helper Types for Any Codable
struct AnyDecodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map { $0.value }
        } else if let objectValue = try? container.decode([String: AnyDecodable].self) {
            value = objectValue.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyDecodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

struct AnyEncodable: Encodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map(AnyEncodable.init))
        case let objectValue as [String: Any]:
            try container.encode(objectValue.mapValues(AnyEncodable.init))
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
