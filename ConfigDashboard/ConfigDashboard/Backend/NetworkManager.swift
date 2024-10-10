//
//  NetworkManager.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 10.10.2024.
//

import Foundation

class NetworkManager {
    
    static var pinataUploadEndpoint: String = "https://uploads.pinata.cloud/v3/files"
    static var pinataGetFilesEndpoint: String = "https://api.pinata.cloud/v3/files"
    static let sharedManager = NetworkManager()
    
    static var bearerToken: String {
        return ProcessInfo.processInfo.environment["PinataToken"] ?? "PINATA_JWT_TOKEN" // add you JWT here (not safe to save it in the client though).
    }
    
    static var configGroupId: String {
        return ProcessInfo.processInfo.environment["ConfigGroupID"] ?? "PINATA_GROUP_ID" // The group where you want to save your config files
    }
    
    func fetchAllConfigs(completion: @escaping (Result<[AppConfig], Error>) -> Void) {
        
        
    }
    
    
    func uploadConfig(config: AppConfig, completion: @escaping (Result<ConfigFileData, Error>) -> Void) {
        
        guard let url = URL(string: NetworkManager.pinataUploadEndpoint) else {
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
            request.setValue("Bearer \(NetworkManager.bearerToken)", forHTTPHeaderField: "Authorization")
            
            let body = Utils.createMultipartFileBody(fileData: jsonData, fileName: "config.json", groupId: NetworkManager.configGroupId, boundary: boundary)
            
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
                        
                        let receivedConfig = try JSONDecoder().decode([String: ConfigFileData].self, from: data)
                                
                        if let fileData = receivedConfig["data"] {
                            completion(.success(fileData))
                        } else {
                            let error = NSError(
                                domain: "api.pinata.cloud",
                                code: 909,
                                userInfo: [NSLocalizedDescriptionKey: "Parse error"]
                            )
                            completion(.failure(error))
                        }
                        
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
