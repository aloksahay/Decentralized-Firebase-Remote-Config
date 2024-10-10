//
//  ViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 09.10.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        uploadtestConfig()
        fetchAllConfigs()
    }
    
    func uploadtestConfig() {
        
        var config = AppConfig()
        config.appVersion = "2.1"
        config.apiRootURL = "https://api.example.com"
        config.apiVersion = "1.0.0"
        
        NetworkManager.sharedManager.uploadConfig(config: config) { result in
            switch result {
            case .success(let receivedFileData):
                print("Uploaded successfully, received response:")
                print("File Location: \(receivedFileData.cid)")
            case .failure(let error):
                print("Failed to upload config: \(error)")
            }
        }
    }
    
    func fetchAllConfigs() {
        NetworkManager.sharedManager.fetchAllConfigs { result in
        
            switch result {
            case .success(let configs):
                print("Fetched successfully, received response:")
                print("Configs: \(configs)")
            case .failure(let error):
                print("Failed to fetch configs: \(error)")
            }}
    }
}

