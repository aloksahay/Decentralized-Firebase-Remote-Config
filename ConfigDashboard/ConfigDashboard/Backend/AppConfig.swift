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

class ConfigManager {
    
    static var pinataUploadEndpoint: String = "https://uploads.pinata.cloud/v3/files"
    static var pinataGetFilesEndpoint: String = "https://api.pinata.cloud/v3/files"
    static let sharedManager = ConfigManager()
    
    static var bearerToken: String {
        return ProcessInfo.processInfo.environment["PinataToken"] ?? "PINATA_JWT_TOKEN" // add you JWT here (not safe to save it in the client though).
    }
    
    static var configGroupId: String {
        return ProcessInfo.processInfo.environment["ConfigGroupID"] ?? "PINATA_GROUP_ID" // The group where you want to save your config files
    }
    
    func uploadConfig(config: AppConfig, completion: @escaping (Result<SavedFileData, Error>) -> Void) {
        
        guard let url = URL(string: ConfigManager.pinataUploadEndpoint) else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(.failure(error))
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(config)
            let boundary = "Boundary-\(UUID().uuidString)"
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(ConfigManager.bearerToken)", forHTTPHeaderField: "Authorization")
            
            let body = Utils.createMultipartFileBody(fileData: jsonData, fileName: "config.json", groupId: ConfigManager.configGroupId, boundary: boundary)
            
            request.httpBody = body
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    do {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "No response data")")
                        
                        let receivedConfig = try JSONDecoder().decode(SavedFileData.self, from: data)
                        completion(.success(receivedConfig))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
    
}
