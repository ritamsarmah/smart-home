//
//  UserLocationViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/5/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit

class UserLocationViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    let locations = ["London", "Los Angeles", "New York City", "San Diego", "San Francisco", "Seattle"]
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Location"

        let location = defaults.string(forKey: PreferencesKeys.city)!
        selectedIndexPath = IndexPath(row: locations.index(of: location)!, section: 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        cell.textLabel!.text = locations[indexPath.row]
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath == selectedIndexPath {
            return
        }
        
        // Check new cell
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        // Uncheck old cell
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        
        selectedIndexPath = indexPath
        defaults.set(locations[indexPath.row], forKey: PreferencesKeys.city)
    }
}
