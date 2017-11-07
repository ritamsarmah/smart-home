//
//  SettingsViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/4/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    // Outlets
    @IBOutlet weak var locationDetailLabel: UILabel!
    
    // Properties
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        let userLocation = defaults.string(forKey: Constants.locationKey)
        if locationDetailLabel.text != userLocation {
            locationDetailLabel.text = userLocation
        }
    }
    
    func configureUI() {
        self.title = "Settings"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
