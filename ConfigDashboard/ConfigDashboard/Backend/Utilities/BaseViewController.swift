//
//  BaseViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 14.10.2024.
//

import UIKit

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
