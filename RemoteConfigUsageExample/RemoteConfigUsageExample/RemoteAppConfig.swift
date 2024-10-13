//
//  RemoteConfig.swift
//  RemoteConfigUsageExample
//
//  Created by Alok Sahay on 13.10.2024.
//

import Foundation

struct ConfigDatabase: Codable {
    var configurations: [AppConfig]
    
    mutating func addConfig(_ config: AppConfig) {
        configurations.append(config)
    }
}

struct AppConfig: Codable {
    var appVersion: String?
    var apiRootURL: String?
    var apiVersion: String?
    var configCreatedAt: Int?
    var customButton: Bool = false
    var customFields: [[String: AnyCodable]]?
    
    func encodeToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error encoding AppConfig to JSON: \(error)")
            return nil
        }
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

class RemoteAppConfig {
    
    static private(set) var shared: RemoteAppConfig!
    
    private var configURL: String
    var configuration: AppConfig?
    private var fetchTimer: Timer?
    
    // MARK: Initilize config instance
    
    private init(configURL: String) {
        self.configURL = configURL
        self.fetchConfigTimerTriggered()
        self.startPeriodicFetch()
    }
    
    static func setupSharedInstance(withURL url: String) {
        guard shared == nil else {
            print("RemoteConfig shared instance already initialized")
            return
        }
        shared = RemoteAppConfig(configURL: url)
    }
    
    @objc private func fetchConfigTimerTriggered() {
        downloadConfiguration { (success, error) in
            if success {
                // all good
            } else {
                print("Configuration failed")
                // error handling
            }
        }
    }

    private func startPeriodicFetch() {
        fetchTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(fetchConfigTimerTriggered), userInfo: nil, repeats: true)
        fetchTimer?.tolerance = 2.0
    }
    
     func endSession() {
        fetchTimer?.invalidate()
        fetchTimer = nil
    }

    
    private func downloadConfiguration(completion: @escaping (Bool, Error?) -> Void) {
        
        guard let endpoint = URL(string: configURL) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: endpoint)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                if let data = data {
                    do {
//                        let responseString = String(data: data, encoding: .utf8)
//                        print("Response: \(responseString ?? "No response data")")
                        
                        let database = try JSONDecoder().decode(ConfigDatabase.self, from: data)
                        if let latestConfiguration = database.configurations.last {
                            self.configuration = latestConfiguration
                            completion(true, nil)
                        } else {
                            let remoteError = NSError(
                                domain: "api.pinata.cloud",
                                code: 999,
                                userInfo: [NSLocalizedDescriptionKey: "Remote Configuration not found"]
                            )
                            completion(false, remoteError)
                        }
                    } catch {
                        completion(false, error)
                    }
                } else {
                    completion(false, error)
                }
            } else {
                completion(false, error)
            }
        }
        
        task.resume()
    }
    
}

