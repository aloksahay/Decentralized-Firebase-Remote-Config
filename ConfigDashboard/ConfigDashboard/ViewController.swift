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
        //        fetchAllConfigs()
        //        fetchConfigDetail()
        fetchConfigDatabase()
    }
    
    func fetchConfigDetail() { //} (config: ConfigFileData) {
        
        //        NetworkManager.sharedManager.fetchConfigById(fileId: "019277e0-74f5-7537-abf7-1963ffd96660") { result in
        //            switch result {
        //            case .success(let config):
        //                print("Fetched config: \(config)")
        //            case .failure(let error):
        //                print("Failed to fetch config: \(error)")
        //            }
        //        }
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
    
    func fetchConfigDatabase() {
        NetworkManager.sharedManager.fetchDatabaseState { (success, error) in
            if success == false {
                self.showAlert(message: error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if NetworkManager.sharedManager.databaseLocation?.cid == nil {
                self.showNoDBAlert()
            } else {
                // DB found, fetch DB
            }
        }
    }
    
    func createNewDB() {
        
    }
}

extension ViewController {
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func showNoDBAlert() {
        let alert = UIAlertController(title: "Config DB not found", message: "Do you want to create one??", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let confirmAction = UIAlertAction(title: "Yes, Go Ahead", style: .default) { _ in
            
            // create and upload an empty DB file
            self.createNewDB()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
}
