//
//  CreateNewConfigViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

class CreateNewConfigViewController: BaseViewController {
    
    @IBOutlet weak var appVersionTextField: UITextField!
    @IBOutlet weak var apiRootURLTextField: UITextField!
    @IBOutlet weak var apiVersionTextField: UITextField!
    
    @IBOutlet weak var customSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveNewConfig(_ sender: Any) {
        
        var config = AppConfig()
        
        config.appVersion = appVersionTextField.text
        config.apiRootURL = apiRootURLTextField.text
        config.apiVersion = apiVersionTextField.text
        config.customButton = customSwitch.isOn
        
        NetworkManager.sharedManager.uploadNewConfig(config: config) { [weak self] (success, error) in
            if success {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
        
    }
}
