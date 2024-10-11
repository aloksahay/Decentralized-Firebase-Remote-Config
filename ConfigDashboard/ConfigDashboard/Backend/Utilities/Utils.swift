//
//  Utils.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 10.10.2024.
//

import Foundation

class Utils {
    
    static func createMultipartFileBody(fileData: Data, fileName: String, groupId: String, boundary: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fileName)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"group_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(groupId)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    static func formatTimeString(_ createdAt: String) -> String? {
        
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        if let date = isoFormatter.date(from: createdAt) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .short
            timeFormatter.timeStyle = .medium
            
            return timeFormatter.string(from: date)
        } else {
            print("Invalid date format")
            return nil
        }
    }
    
    static func linkIsValid(urlString: String?) -> Bool {
        
        guard let urlString = urlString, let urlComponents = URLComponents(string: urlString) else {
            print("Invalid URL")
            return false
        }
        
        if let queryItems = urlComponents.queryItems {
            
            guard let dateString = queryItems.first(where: { $0.name == "X-Date" })?.value,
                  let expiresString = queryItems.first(where: { $0.name == "X-Expires" })?.value,
                  let dateInterval = TimeInterval(dateString),
                  let expiresInterval = TimeInterval(expiresString) else {
                
                print("Missing or invalid X-Date or X-Expires")
                return false
            }
            
            let linkCreationDate = Date(timeIntervalSince1970: dateInterval)
            let expirationDate = linkCreationDate.addingTimeInterval(expiresInterval)
            
            let currentDate = Date()
            
            if currentDate < expirationDate && currentDate >= linkCreationDate {
                print("Link is still valid")
                return true
            } else {
                print("Link has expired")
                return false
            }
        }
        return false
    }
}
