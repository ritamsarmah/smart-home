//
//  UnitsViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/7/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit

class UnitsViewController: UITableViewController {

    let defaults = UserDefaults.standard
    
    let units = ["Celsius (°C)", "Fahrenheit (°F)"]
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Temperature Unit"
        
        let userUnits = defaults.string(forKey: PreferencesKeys.units)!
        selectedIndexPath = IndexPath(row: units.index(of: userUnits)!, section: 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return units.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "unitsCell", for: indexPath)
        cell.textLabel!.text = units[indexPath.row]
        
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
        defaults.set(units[indexPath.row], forKey: PreferencesKeys.units)
    }
}
