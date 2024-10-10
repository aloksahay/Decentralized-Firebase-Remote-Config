//
//  AppConfig.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 09.10.2024.
//

import Foundation

struct AppConfig: Codable {
    var appVersion: String?
    var apiRootURL: String?
    var apiVersion: String?
    var customButton: Bool?
    var customFields: [[String: AnyCodable]]? // maybe the user needs some custom fields in the config
    
    mutating func addCustomField(key: String, value: Any) {
        let newField = [key: AnyCodable(value)]
        if customFields == nil {
            customFields = [newField]
        } else {
            customFields?.append(newField)
        }
    }
    
    mutating func removeCustomField(key: String) {
        customFields?.removeAll { $0.keys.contains(key) }
    }
    
    func toJSON() -> String? {
        var dict: [String: Any] = [:]
        
        dict["appVersion"] = appVersion
        dict["apiRootURL"] = apiRootURL
        dict["apiVersion"] = apiVersion
        dict["customButton"] = customButton
        
        if let customFields = customFields {
            let sortedCustomFields = customFields.map { field in
                field.sorted { $0.key < $1.key }
            }
            dict["customFields"] = sortedCustomFields
        }
        
        // Convert the dictionary to JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
            return String(data: jsonData, encoding: .utf8)
        }
        
        return nil
    }
    
    
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
