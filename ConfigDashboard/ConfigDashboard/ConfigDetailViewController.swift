//
//  ConfigDetailViewController.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

class ConfigDetailViewController: BaseViewController {
    
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

extension ConfigDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
                cell.textLabel?.text = config.appVersion
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // first cell, add new config
            self.performSegue(withIdentifier: "createNewConfig", sender: nil)
        }
    }
    
}
