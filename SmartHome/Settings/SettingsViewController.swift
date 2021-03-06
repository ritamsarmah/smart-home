//
//  SettingsViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/4/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var unitsDetailLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var automationSwitch: UISwitch!

    let activityIndicatorView = BoxActivityIndicatorView()
    
    // Properties
    let defaults = UserDefaults.standard
    let server = ArduinoServer()
    
    let maxRetries = 1
    
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
        
        let userAddress = defaults.url(forKey: PreferencesKeys.ipAddress)
        if addressTextField.text != userAddress?.absoluteString {
            addressTextField.text = userAddress?.absoluteString
        }
        
        let userAutomation = defaults.bool(forKey: PreferencesKeys.automateDevice)
        if automationSwitch.isOn != userAutomation {
            automationSwitch.setOn(userAutomation, animated: true)
        }
    }
    
    func configureUI() {
        self.title = "Settings"
        
        activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 80)
        activityIndicatorView.disablesInteraction = true
        self.view.addSubview(activityIndicatorView)
    }
    
    func switchAutomation(state: Bool, retryCount: Int) {
        server.switchAutomation(state: state) { (data, error) in
            if let error = error {
                print(error)
                
                // Retry if network request fails
                if retryCount < self.maxRetries {
                    self.switchAutomation(state: state, retryCount: retryCount + 1)
                } else {
                    // Failure
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        
                        // Display error alert
                        let alert = UIAlertController(title: "Server Unavailable",
                                                      message: "Failed to update automation mode.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: {

                        })
                        self.automationSwitch.setOn(!state, animated: true)
                    }
                }
            } else {
                // Successful update on server
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                }
                self.defaults.set(state, forKey: PreferencesKeys.automateDevice)
            }
        }
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
    
    @IBAction func automationSwitchChanged(_ sender: UISwitch) {
        self.activityIndicatorView.startAnimating()
        switchAutomation(state: sender.isOn, retryCount: 0)
    }
}
