//
//  DashboardViewController.swift
//  DashboardViewController
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var configsLabel: UILabel!
    @IBOutlet weak var configLocation: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        tableview.delegate = self
        tableview.dataSource = self
        setupRefreshControl()
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        // Simulate fetching new data (you would replace this with your actual data fetching logic)
        
        NetworkManager.sharedManager.refreshDatabase { [weak self] (success, error) in
            print("Table view refreshed!")
            self?.refreshTable()
            self?.refreshUI()
        }
        
    }
    
    func refreshUI() {
        DispatchQueue.main.async {
            self.setupViews()
        }
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.tableview.reloadData()
        }
    }
    
    
    func setupViews() {
        
        projectLabel.text = ""
        configsLabel.text = "0 Configs found"
        configLocation.text = ""
        
        if let projectName = NetworkManager.sharedManager.remoteDatabaseState?.name {
            projectLabel.text = projectName
        }
        
        if let configs = NetworkManager.sharedManager.dataSource?.configurations, let _ = configs.last {
            print("Found configurations: \(configs.count)")
            configsLabel.text = "\(configs.count) Configs found"
        }
        
        self.configLocation.text = "NetworkManager.pinataGatewayEndpoint"
        
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        if let configLocation = NetworkManager.sharedManager.databaseURLEndpoint {
            UIPasteboard.general.string = configLocation
        }
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var cellCount = 1
        
        if let remoteDB = NetworkManager.sharedManager.dataSource {
            cellCount += remoteDB.configurations.count
        }
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .black
        
        if indexPath.row == 0 {
            // first cell, add new config
            cell.textLabel?.text = "Add new configuration?"
            cell.backgroundColor = themeYellowColor
        } else {
            // tap into existing configs
            if let remoteDB = NetworkManager.sharedManager.dataSource {
                let configs = remoteDB.configurations
                let index = indexPath.row - 1 // adjust for top cell
                let config = configs[index]
                
                var configString = config.appVersion
                
                if index == 0 {
                    configString?.append(" ✅")
                }
                cell.textLabel?.text = configString
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // first cell, add new config
            self.performSegue(withIdentifier: "createNewConfig", sender: nil)
        } else {
            // existing config
            if let remoteDB = NetworkManager.sharedManager.dataSource {
                self.performSegue(withIdentifier: "showConfig", sender: tableView.cellForRow(at: indexPath))
            }
        }
    }
    
}

extension DashboardViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "showConfig" {
                if let destinationVC = segue.destination as? ConfigDetailViewController, let selectedCell = sender as? UITableViewCell,
                   let indexPath = tableview.indexPath(for: selectedCell) {
                    
                    if let remoteDB = NetworkManager.sharedManager.dataSource {
                        
                        let configs = remoteDB.configurations
                        let index = indexPath.row - 1
                        let config = configs[index]
                        let currentJson = config.encodeToJSON()
                        destinationVC.configJSON = currentJson
                        
                        let nextIndex = index + 1 //compare with one previous version
                        
                        if nextIndex >= 0 && nextIndex < configs.count, let newConfig = configs[nextIndex].encodeToJSON() {
                            destinationVC.compareToPreviousJSON = newConfig
                        }
                    }
                }
            }
        }
}
