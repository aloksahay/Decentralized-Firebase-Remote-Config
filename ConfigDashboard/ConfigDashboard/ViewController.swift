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
        fetchDatabaseState()
    }
    
    @IBAction func postConfig(_ sender: Any) {
        createNewConfig()
    }
    
    func fetchDatabaseState() {
        
        NetworkManager.sharedManager.fetchDatabaseState { [weak self] (success, error) in
            if success == false {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if NetworkManager.sharedManager.remoteDatabaseState?.cid == nil {
                    self?.showNoDBAlert()
            } else {
                // DB found, fetch DB
                self?.refreshData()
            }
        }
    }
    
    
    func createNewConfig() {
        
        var newConfig = AppConfig()
        newConfig.appVersion = "1.0.5"
        newConfig.apiRootURL = "https://api.example.com/v2"
        newConfig.apiVersion = "2.0.55"
        newConfig.customButton = true

        NetworkManager.sharedManager.uploadNewConfig(config: newConfig) { [weak self] (success, error) in
            
            if success {
                print("config added")
            } else {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func refreshData() {
        
        NetworkManager.sharedManager.refreshDatabase { [weak self] (success, error) in
            
            if success {
                print("DB updated")
            } else {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func createNewDatabase() {
        NetworkManager.sharedManager.uploadDatabase { [weak self] (success, error) in
            //            switch result {
            //            case .success(let receivedFileData):
            //                print("Uploaded successfully, received response:")
            //                print("File Location: \(receivedFileData.cid)")
            //            case .failure(let error):
            //                print("Failed to upload config: \(error)")
            //            }
        }
    }
}

extension ViewController {
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showNoDBAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Config DB not found", message: "Do you want to create one??", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let confirmAction = UIAlertAction(title: "Yes, Go Ahead", style: .default) { _ in
                // create and upload an empty DB file
                self.createNewDatabase()
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
