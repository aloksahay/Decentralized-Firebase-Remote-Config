//
//  PinataAPI.swift
//  AppConfig
//
//  Created by Alok Sahay on 03.10.2024.
//

import Foundation

class NetworkManager {
    
    func loadAppConfig() -> Config? {
        
        
        return nil
    }
    
    
    func saveAppConfig(_ appConfig: Config)  {
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(appConfig)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
}
