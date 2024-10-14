//
//  ConfigDetailViewController.swift
//  ConfigDetailViewController
//
//  Created by Alok Sahay on 14.10.2024.
//

import UIKit

class ConfigDetailViewController: BaseViewController {
    
    var configJSON: String?
    var compareToPreviousJSON: String?
    @IBOutlet weak var jsonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        jsonLabel.text = configJSON
        jsonLabel.textColor = .systemTeal
        
        guard let currentJson = configJSON, let currentConfigDict = jsonStringToDictionary(currentJson), let previousJSON = compareToPreviousJSON, let prevConfigDict = jsonStringToDictionary(previousJSON) else { return }
        
        let attributedResult = compareJsonsAndHighlight(currentJson: currentConfigDict, newJson: prevConfigDict)
        jsonLabel.attributedText = attributedResult
        
    }

    // Function to convert JSON string to dictionary
    func jsonStringToDictionary(_ jsonString: String) -> [String: Any]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return jsonDict
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        return nil
    }
}

extension ConfigDetailViewController {
   
    func compareJsonsAndHighlight(currentJson: [String: Any], newJson: [String: Any]) -> NSAttributedString {
        let resultString = NSMutableAttributedString()
        
        for key in currentJson.keys {
            if let currentValue = currentJson[key], let newValue = newJson[key] {
                let keyString = "\(key): "
                let keyAttributedString = NSAttributedString(
                    string: keyString,
                    attributes: [.foregroundColor: UIColor.white]
                )
                resultString.append(keyAttributedString)
                
                // Compare values
                if "\(currentValue)" != "\(newValue)" {
                    // Different values: highlight in green for current and red for new
                    let currentAttributedString = NSAttributedString(
                        string: "\(currentValue)\n",
                        attributes: [.foregroundColor: UIColor.white]
                    )
                    let newAttributedString = NSAttributedString(
                        string: "\(newValue)\n\n",
                        attributes: [.foregroundColor: UIColor.systemTeal]
                    )
                    resultString.append(currentAttributedString)
                    resultString.append(newAttributedString)
                } else {
                    let sameValueAttributedString = NSAttributedString(
                        string: "\(currentValue)\n",
                        attributes: [.foregroundColor: UIColor.white]
                    )
                    resultString.append(sameValueAttributedString)
                }
            }
        }
        
        return resultString
    }
   
}

