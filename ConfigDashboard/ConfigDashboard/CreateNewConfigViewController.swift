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
    
    var customFields: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addCustomFieldsToConfig(_ sender: Any) {
        addCustomFields()
    }
    
    @IBAction func submitConfig(_ sender: Any) {
        
        var config = AppConfig()
        
        config.appVersion = appVersionTextField.text
        config.apiRootURL = apiRootURLTextField.text
        config.apiVersion = apiVersionTextField.text
        config.customButton = customSwitch.isOn
        
        for customField in customFields {
            for (key, value) in customField {
                config.addCustomField(key: key, value: value)
            }
        }
        
        NetworkManager.sharedManager.uploadNewConfig(config: config) { [weak self] (success, error) in
            if success {                
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    
    @objc func addCustomFields() {
           let alert = UIAlertController(title: "Add Custom Field", message: nil, preferredStyle: .alert)
           
           alert.addTextField { (keyTextField) in
               keyTextField.placeholder = "Enter field name"
           }
           
           alert.addTextField { (valueTextField) in
               valueTextField.placeholder = "Enter field value"
           }
           
           let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
               guard let key = alert.textFields?[0].text, !key.isEmpty,
                     let value = alert.textFields?[1].text, !value.isEmpty else { return }
               
               self?.customFields.append([key: value])
               print("Custom Field Added: \(key) = \(value)")
           }
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           alert.addAction(addAction)
           alert.addAction(cancelAction)
           
           present(alert, animated: true, completion: nil)
       }
    
}
