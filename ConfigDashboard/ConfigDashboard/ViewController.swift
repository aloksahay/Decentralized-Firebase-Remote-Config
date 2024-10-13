//
//  ViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 09.10.2024.
//

import UIKit

extension UIColor {
    
    // Initialize UIColor from a hex string
    convenience init(hex: String) {
        var hexString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // If the string has a '#' prefix, remove it
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // Ensure that the string is exactly 6 or 8 characters
        if hexString.count == 6 {
            hexString.append("FF") // Append 'FF' for full alpha if no alpha provided
        }
        
        assert(hexString.count == 8, "Invalid hex code used.")
        
        // Convert the hex string into a UInt32
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        // Extract the color components
        let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        
        // Initialize the color
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}



class BaseViewController: UIViewController {
    
    let themeGrayColor: UIColor = UIColor(hex: "#1D1E19")
    let themeYellowColor: UIColor = UIColor(hex: "#BEA03B")
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}


class ViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        fetchDatabaseState()
    }
    
     func postConfig() {
        createNewConfig()
    }
    
    func fetchDatabaseState() {
        
        NetworkManager.sharedManager.fetchDatabaseState { [weak self] (success, error) in
            if success == false {
//                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
                return
            }
            self?.refreshData()
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
//                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func refreshData() {
        
        NetworkManager.sharedManager.refreshDatabase { [weak self] (success, error) in
            
            if success {
                self?.updateUI()
            } else {
//                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}

extension ViewController {
    
//    func showAlert(message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "OK", style: .default)
//            alert.addAction(cancelAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
//    public func showNoDBAlert() {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Config DB not found", message: "Do you want to create one??", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//            let confirmAction = UIAlertAction(title: "Yes, Go Ahead", style: .default) { _ in
//                // create and upload an empty DB file
//                self.createNewDatabase()
//            }
//            alert.addAction(cancelAction)
//            alert.addAction(confirmAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
             
        if let remoteDB = NetworkManager.sharedManager.dataSource {
            
            var congifurationsString: String = "Found \(remoteDB.configurations.count) configurations."
            if let lastKnownConfig = remoteDB.configurations.last {
                let lastKnownConfigTime = Utils.formatTimeStringFromTimestamp(lastKnownConfig.configCreatedAt)
                congifurationsString.append("\nUpdate: \(lastKnownConfigTime)")
            }
            
            cell.textLabel?.text = congifurationsString
            
        } else { // db doesnt exist
            cell.textLabel?.text = "Remote database not configured, configure now?"
        }
        
        return cell
    }
    
}
