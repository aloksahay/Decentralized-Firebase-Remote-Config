//
//  DashboardViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var dbStateTitleLabel: UILabel!
    @IBOutlet weak var projectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        fetchDatabaseState()
    }
    
    func refreshLayout() {
        DispatchQueue.main.async {
            self.setupViews()
        }
    }
    
    func setupViews() {
        
        if let projectName = NetworkManager.sharedManager.remoteDatabaseState?.name {
            // Project found
            
            var projectDescription = ""
            var configDescription = ""
            
            projectButton.backgroundColor = themeGrayColor
            projectButton.setTitle("", for: .normal)
            projectButton.layer.borderColor = themeYellowColor.cgColor
            
            projectDescription = "\(projectName)"
            
            if let configs = NetworkManager.sharedManager.dataSource?.configurations, let latestConfig = configs.last {
                print("Founds configurations: \(configs.count)")
                
                let createdAt = Utils.formatTimeStringFromTimestamp(latestConfig.configCreatedAt)
                projectDescription.append("\nLast update: \(createdAt)")
                configDescription = "Show (\(configs.count)) configurations >"
                
            } else { // no saved configs
                configDescription = "No saved configs"
            }
            projectButton.setTitle(configDescription, for: .normal)
            dbStateTitleLabel.text = projectDescription
            projectButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        } else {
            // Project doesnt exist
            dbStateTitleLabel.text = "Project not found. Click to create"
            projectButton.backgroundColor = themeYellowColor
            projectButton.setTitle("+", for: .normal)
            projectButton.titleLabel?.font = UIFont.systemFont(ofSize: 48)
        }
    }
    
    @IBAction func projectButtonPressed(_ sender: Any) {
        
        if let _ = NetworkManager.sharedManager.remoteDatabaseState?.name {
            // Project found, go detail page
            performSegue(withIdentifier: "showDetail", sender: nil)
            
        } else {
            // project doesnt exist
            let alertController = UIAlertController(title: "Create new project", message: "Please enter the project name", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Project Name"
            }
            
            let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                
                if let projectName = alertController.textFields?.first?.text, !projectName.isEmpty {
                    self?.createProject(projectName)
                } else {
                    print("Project name is empty.")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func createProject(_ name: String) {
        
        print("Create new project: \(name)")
        
        NetworkManager.sharedManager.uploadDatabase(projectName: name) { [weak self] (success, error) in
            if success {
                self?.refreshLayout()
            } else {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func fetchDatabaseState() {
        
        NetworkManager.sharedManager.fetchDatabaseState { [weak self] (success, error) in
            if success == false {
                self?.showAlert(message: error?.localizedDescription ?? "Unknown error")
                return
            } else {
                self?.refreshLayout()
            }
        }
    }
    
    
}
