//
//  ViewController.swift
//  RemoteConfigUsageExample
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var jsonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        refreshLabel()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        refreshLabel()
    }

    func refreshLabel() {
        
        jsonLabel.text = ""
        
        guard let config = RemoteAppConfig.shared.configuration else {
            jsonLabel.text = "Invalid config"
            return
        }
        
        if config.customButton {
            // if custom button is on.
            let json = config.encodeToJSON()
            jsonLabel.text = json
        } else {
            var json = ""
            if let appVersion = config.appVersion {
                json.append("App Version: " + appVersion)
            }
            if let apiURL = config.apiRootURL,  let apiVersion = config.apiVersion {
                json.append("\nEndpoint: " + apiURL + "/" + apiVersion)
            }
            jsonLabel.text = json
        }
    }
}

