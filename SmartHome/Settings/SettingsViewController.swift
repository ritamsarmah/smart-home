//
//  SettingsViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/4/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var unitsDetailLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    
    // Properties
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        let userLocation = defaults.string(forKey: PreferencesKeys.city)
        if locationDetailLabel.text != userLocation {
            locationDetailLabel.text = userLocation
        }
        
        let userUnits = defaults.string(forKey: PreferencesKeys.units)
        if unitsDetailLabel.text != userUnits {
            unitsDetailLabel.text = userUnits
        }
        
        let useraddress = defaults.url(forKey: PreferencesKeys.ipAddress)
        if addressTextField.text != useraddress?.absoluteString {
            addressTextField.text = useraddress?.absoluteString
        }
    }
    
    func configureUI() {
        self.title = "Settings"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addressTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let ip = textField.text {
            let url = URL(string: ip)
            defaults.set(url, forKey: PreferencesKeys.ipAddress)}
        return true
    }
}
