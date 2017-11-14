//
//  ViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 10/25/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit
import CoreLocation

// Globals
let step: Float = 1

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var lightsView: UIView!
    @IBOutlet weak var lightsImageView: UIImageView!
    @IBOutlet weak var lightsEnabledLabel: UILabel!
    @IBOutlet weak var lightPowerSlider: UISlider!
    
    @IBOutlet weak var fanButton: UIButton!
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var fanImageView: UIImageView!
    @IBOutlet weak var fanEnabledLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel! // TODO: REMOVE AFTER DONE DEBUGGING
    
    let activityIndicator = UIActivityIndicatorView()
    var refreshButton = UIBarButtonItem()
    
    // MARK: - Properties
    let weather = Weather()
    let server = ArduinoServer()
    let locationManager = CLLocationManager()
    
    let defaults = UserDefaults.standard // For persisting user preferences
    
    var fanEnabled = false {
        didSet {
            fanEnabledLabel.text = fanEnabled ? "On" : "Off"
        }
    }
    var lightEnabled = false {
        didSet {
            if lightEnabled {
                lightsEnabledLabel.text = "On"
                if lightPowerSlider.value == 0 {
                    lightPowerSlider.setValue(1, animated: true)
                }
            } else {
                lightsEnabledLabel.text = "Off"
                lightPowerSlider.setValue(0, animated: true)
            }
        }
    }
    var lightPower: Float = 0.0 {
        didSet {
            if lightPower == 0 {
                lightEnabled = false
                setImage(for: lightButton, with: lightEnabled)
            } else {
                lightEnabled = true
                setImage(for: lightButton, with: lightEnabled)
            }
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Set up observer for when application becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        // Refresh data
        getWeatherData()
        refreshServerData()
        
        // Check if home location set
        let atHome = defaults.value(forKey: PreferencesKeys.atHome) as! Bool?
        if atHome == nil {
            locationLabel.text = "Home location not set"
        } else {
            if atHome! {
                locationLabel.text = "At Home"
            } else {
                locationLabel.text = "Away"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    func configureUI() {
        self.title = "Your Devices"
        
        // Add settings button
        let barButton = UIBarButtonItem()
        barButton.image = #imageLiteral(resourceName: "settings")
        barButton.target = self
        barButton.action = #selector(settingsTapped)
        barButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = barButton
        
        // Add loading indicator to navigation bar
        activityIndicator.activityIndicatorViewStyle = .gray
        setLoadingState(withLabels: true)
        
        // Set refresh button
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshTapped))
        refreshButton.tintColor = .black
        
        // Setup light power slider
        lightPowerSlider.minimumValue = 0
        lightPowerSlider.maximumValue = 3
        
        // Adds rounded corners
        greetingView.layer.cornerRadius = 8
        greetingView.layer.masksToBounds = true
        
        lightsView.layer.cornerRadius = 8
        lightsView.layer.masksToBounds = true
        
        fanView.layer.cornerRadius = 8
        fanView.layer.masksToBounds = true
        
        lightsImageView.image = UIImage(named: "light")
        fanImageView.image = UIImage(named: "fan")
        
        // Set greeting label based on time of day
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 0..<12:
            greetingLabel.text = "Good Morning"
        case 12..<18:
            greetingLabel.text = "Good Afternoon"
        default:
            greetingLabel.text = "Good Evening"
        }
    }
    
    func getWeatherData() {
        // Check user settings for location and units
        let city = defaults.string(forKey: PreferencesKeys.city)!
        let userUnits = self.defaults.string(forKey: PreferencesKeys.units)!
        
        var units: Units = .fahrenheit
        if userUnits == "Fahrenheit (°F)" {
            units = .fahrenheit
        } else if userUnits == "Celsius (°C)" {
            units = .celsius
        }
        
        // Get weather data
        weather.getWeather(for: city, in: units) { (data, error) in
            if let weatherData = data {
                
                let image = UIImage(named: "\(weatherData.getIconName()).pdf")
                
                DispatchQueue.main.async {
                    self.weatherImageView.image = image
                    
                    // Set temp label
                    let unitsText = (units == .fahrenheit) ? "F" : "C"
                    self.tempLabel.text = "It's \(Int(round(weatherData.getTemperature())))°\(unitsText) in \(city). \(weatherData.getCondition())."
                }
            }
        }
    }
    
    func refreshServerData() {
        print("Connecting to server...")
        setLoadingState(withLabels: false)
        server.getData { (data, error) in
            if let error = error {
                print("Error connecting to server.")
                print(error)
                DispatchQueue.main.async {
                    self.fanEnabledLabel.text = "Failed to connect."
                    self.lightsEnabledLabel.text = "Failed to connect."
                }
            }
            if let data = data {
                print("Success. Data response: \(data)")
                DispatchQueue.main.async {
                    // Set fan state
                    if data.ac == 0 {
                        self.fanEnabled = false
                    } else {
                        self.fanEnabled = true
                    }
                    
                    // Set light power
                    self.lightPower = Float(data.lightLevel)
                    print("CURRENT LIGHTPOWER: \(self.lightPower)")
                    self.lightPowerSlider.value = self.lightPower
                    
                    // Set fan card
                    self.setImage(for: self.fanButton, with: self.fanEnabled)
                    self.fanEnabledLabel.text = self.fanEnabled ? "On" : "Off"
                    self.fanButton.isEnabled = true
                    
                    // Set light card
                    self.lightsEnabledLabel.text = self.lightEnabled ? "On" : "Off"
                    self.lightButton.isEnabled = true
                }
            }
            DispatchQueue.main.async {
                self.setNotLoadingState()
            }
        }
    }
    
    @objc func settingsTapped() {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @objc func refreshTapped() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        setLoadingState(withLabels: true)
        refreshServerData()
    }
    
    @objc func applicationDidBecomeActive() {
        getWeatherData()
        refreshServerData()
    }
    
    @IBAction func lightButtonPressed(_ sender: UIButton) {
        lightEnabled = !lightEnabled
        setImage(for: sender, with: lightEnabled)
    }
    
    @IBAction func fanButtonPressed(_ sender: UIButton) {
        fanEnabled = !fanEnabled
        sender.isEnabled = false
        server.switchAC(state: fanEnabled) { (data, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                print("AC state from server: \(data.ac)")
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.setImage(for: sender, with: self.fanEnabled)
            }
        }
    }
    
    func setImage(for button: UIButton, with state: Bool) {
        if state == true {
            button.setImage(#imageLiteral(resourceName: "buttonOn"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "buttonOff"), for: .normal)
        }
    }
    
    func setLoadingState(withLabels: Bool) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        
        if withLabels == true {
            fanEnabledLabel.text = "Loading..."
            lightsEnabledLabel.text = "Loading..."
        }
        
        // Disable buttons on data is retrieved in viewWillAppear
        fanButton.isEnabled = false
        lightButton.isEnabled = false
    }
    
    func setNotLoadingState() {
        self.navigationItem.leftBarButtonItem = refreshButton
        activityIndicator.stopAnimating()
    }
    
    @IBAction func lightSliderChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        lightPower = roundedValue
        sender.value = roundedValue
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationLabel.text = "At home"
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == Constants.regionID {
            locationLabel.text = "At home"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationLabel.text = "Away"
    }
}
