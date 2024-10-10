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
        testConfigDashboard()
    }

    func testConfigDashboard() {
        
        var config = AppConfig()
        config.appVersion = "2.1"
        config.apiRootURL = "https://api.example.com"
        config.apiVersion = "1.0.0"
        
        ConfigManager.sharedManager.uploadConfig(config: config) { result in
            switch result {
            case .success(let receivedFileData):
                print("Uploaded successfully, received response:")
                print("File Location: \(receivedFileData.cid)")
            case .failure(let error):
                print("Failed to upload config: \(error)")
            }
        }
    }
}

