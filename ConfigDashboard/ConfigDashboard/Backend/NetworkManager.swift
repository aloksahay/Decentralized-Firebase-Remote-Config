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
    
    // part of dashboard client
    
    func fetchAllConfigs(completion: @escaping (Result<[ConfigFileData], Error>) -> Void) {
        
        let fetchFilesByGroupId = NetworkManager.pinataGetFilesEndpoint + "?group=\(NetworkManager.configGroupId)"
        
        guard let url = URL(string: fetchFilesByGroupId) else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(NetworkManager.bearerToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                
                do {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "No response data")")
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let dataObject = json?["data"] as? [String: Any],
                       let filesArray = dataObject["files"] as? [[String: Any]] {
                        let filesData = try JSONSerialization.data(withJSONObject: filesArray, options: [])
                        let files = try JSONDecoder().decode([ConfigFileData].self, from: filesData)
                        completion(.success(files))
                    }
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }            
        task.resume()
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
            guard let jsonString = config.toJSON(), let jsonData = jsonString.data(using: .utf8) else {
                print("Failed to convert config to JSON.")
                return
            }
            
            print("JSON string: " + jsonString)
            print("JSON config: " + (String(data: jsonData, encoding: .utf8) ?? ""))
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
        }
    }
    
}
