//
//  NetworkManager.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 10.10.2024.
//

import Foundation

class NetworkManager {
        
    static let sharedManager = NetworkManager()
    
    static let pinataUploadEndpoint: String = "https://uploads.pinata.cloud/v3/files"
    static let pinataFilesEndpoint: String = "https://api.pinata.cloud/v3/files"
    static let pinataGatewayEndpoint: String = "https://cyan-genetic-barracuda-339.mypinata.cloud/files"
    static let urlDuration = (60 * 60 * 24 * 90)  //duration of signed URL in days
    
    var remoteDatabaseState: ConfigFileData?
    var dataSource: ConfigDatabase?
    var databaseURLEndpoint: String?
    
    static var bearerToken: String {
        return ProcessInfo.processInfo.environment["PinataToken"] ?? "PINATA_JWT_TOKEN" // add you JWT here (not safe to save it in the client though).
    }
    
    static var configGroupId: String {
        return ProcessInfo.processInfo.environment["ConfigGroupID"] ?? "PINATA_GROUP_ID" // The group where you want to save your config files
    }
    
    /*
     MARK: Future work:
     
     1. Better error handling across chained calls. If one fails then retry should only call the failed call, not the whole thing.
     
     2. Clean up the shared dataTask blocks, functions are getting too long and hard to read. Move all code inside blocks into block arguements somewhere else.
     
     */   
    
    // MARK: Check DB state
    
    
    func fetchDatabaseState(completion: @escaping (Bool, Error?) -> Void) {
        
        let fetchFilesByGroupId = NetworkManager.pinataFilesEndpoint + "?group=\(NetworkManager.configGroupId)"
        
        guard let url = URL(string: fetchFilesByGroupId) else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(false, error)
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
                        
                        if let dbLocation = files.first {
                            self.remoteDatabaseState = dbLocation
                            self.refreshDatabase(completion: completion)
                        } else {
                            completion(true, nil)
                        }                        
                    }
                    
                } catch {
                    completion(false, error)
                    return
                }
            }
        }
        task.resume()
    }
    
    // MARK: Upload DB
    
    func uploadDatabase(projectName: String, completion: @escaping (Bool, Error?) -> Void) {
        
        if (dataSource == nil) {
            dataSource = ConfigDatabase(configurations: [])
        }
        
        guard let url = URL(string: NetworkManager.pinataUploadEndpoint) else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(false,error)
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(dataSource)
            let boundary = "Boundary-\(UUID().uuidString)"
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(NetworkManager.bearerToken)", forHTTPHeaderField: "Authorization")
            
            let body = Utils.createMultipartFileBody(fileData: jsonData, fileName: projectName, groupId: NetworkManager.configGroupId, boundary: boundary)
            request.httpBody = body
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(false, error)
                    return
                }
                
                if let data = data {
                    do {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "No response data")")
                        
                        let receivedConfig = try JSONDecoder().decode([String: ConfigFileData].self, from: data)
                        if let fileData = receivedConfig["data"] {
                            
                            if self.remoteDatabaseState == nil {
                                
                                // DB is saved for the first time
                                self.remoteDatabaseState = fileData
                                completion(true, nil)
                                
                            } else if let oldCID = self.remoteDatabaseState?.cid, oldCID != fileData.cid {
                                
                                //DB is saved to new location, perform hot swap
                                self.swapDatabase(oldCID: oldCID, newCID: fileData.cid, completion: completion)
                            }
                        } else {
                            let error = NSError(
                                domain: "api.pinata.cloud",
                                code: 909,
                                userInfo: [NSLocalizedDescriptionKey: "Parse error"]
                            )
                            completion(false, error)
                            return
                        }
                        
                    } catch {
                        completion(false, error)
                    }
                }
            }
            task.resume()
            
        } catch {
            completion(false, error)
        }
    }
    
    // MARK: Download DB
    
    func downloadDatabase(completion: @escaping (Bool, Error?) -> Void) {
        
        guard let endpoint = self.databaseURLEndpoint, let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                if let data = data {
                    do {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "No response data")")
                        
                        let database = try JSONDecoder().decode(ConfigDatabase.self, from: data)
                        self.dataSource = database //save DB for the rest of the session
                        completion(true, nil)
                        
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
    
    // MARK: Refresh DB
    
    func refreshDatabase(completion: @escaping (Bool, Error?) -> Void) {
        
        if self.databaseURLEndpoint == nil || Utils.linkIsValid(urlString: self.databaseURLEndpoint) == false { // also check if location link is expired then generate a new signed link
            
            // get location for the db signed url first
            getDatabaseSignedURL { (success, error) in
                if success {
                    self.downloadDatabase(completion: completion)
                } else {
                    completion (false, error)
                }
            }
        } else {
            // link is valid, download db
            self.downloadDatabase(completion: completion)
        }
    }
    
    // MARK: Get DB location URL
    
    func getDatabaseSignedURL(completion: @escaping (Bool, Error?) -> Void) {
        
        guard let requestUrl = URL(string: NetworkManager.pinataFilesEndpoint + "/sign"), let cid = self.remoteDatabaseState?.cid else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(false,error)
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(NetworkManager.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyParams: [String: Any] = [
            "url": NetworkManager.pinataGatewayEndpoint + "/\(cid)",
            "date": Int(Date().timeIntervalSince1970 * 1000), // time is in milliseconds
            "expires": NetworkManager.urlDuration,
            "method": "GET"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            let responseString = String(data: jsonData, encoding: .utf8)
            
            print("Body Parameters: \(responseString ?? "No response data")")
            
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false,error)
                return
            }
            
            if let data = data {
                do {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "No response data")")
                    
                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let urlString = jsonDict["data"] as? String {
                        self.databaseURLEndpoint = urlString
                        completion(true, nil)
                    } else {
                        print("Failed to extract URL from the response.")
                        completion(false, error)
                    }
                } catch {
                    completion(false, error)
                }
                
            }
        }
        task.resume()
    }
    
    // MARK: Append config
    
    func uploadNewConfig(config: AppConfig, completion: @escaping (Bool, Error?) -> Void) {
        
        guard let _ = dataSource, let projectName = remoteDatabaseState?.name  else {
            return completion(false, nil)
        }
        
        self.dataSource?.addConfig(config)
        uploadDatabase(projectName: projectName, completion: completion)
    }
    
    // MARK: Hot Swap DBs
    
    func swapDatabase(oldCID: String, newCID: String, completion: @escaping (Bool, Error?) -> Void) {
        
        guard let requestUrl = URL(string: NetworkManager.pinataFilesEndpoint + "/swap/\(oldCID)") else {
            print("Invalid URL.")
            
            let error = NSError(
                domain: "api.pinata.cloud",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
            
            completion(false,error)
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        request.setValue("Bearer \(NetworkManager.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyParams: [String: Any] = [
            "swap_cid": newCID
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "No response data")")
                    
                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let updateDB = jsonDict["data"] as? [String: Any], let mappedCID = updateDB["mapped_cid"] {          print("DB update successful: \(mappedCID)")
                        self.refreshDatabase(completion: completion)
                    } else {
                        print("Failed to extract new CID from the response.")
                        completion(false, error)
                    }
                } catch {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
}
