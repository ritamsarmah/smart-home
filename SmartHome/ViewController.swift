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
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var insideTempLabel: UILabel!
    
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var lightsView: UIView!
    @IBOutlet weak var lightsImageView: UIImageView!
    @IBOutlet weak var lightsEnabledLabel: UILabel!
    @IBOutlet weak var lightPowerSlider: UISlider!
    
    @IBOutlet weak var fanButton: UIButton!
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var fanImageView: UIImageView!
    @IBOutlet weak var fanEnabledLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
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
                locationLabel.text = "Welcome Home"
            } else {
                locationLabel.text = "Away from Home"
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
        lightPowerSlider.addTarget(self, action: #selector(lightSliderReleased), for: .touchUpInside)
        lightPowerSlider.addTarget(self, action: #selector(lightSliderReleased), for: .touchUpOutside)
        
        // Adds rounded corners
        greetingView.layer.cornerRadius = 8
        greetingView.layer.masksToBounds = true
        
        lightsView.layer.cornerRadius = 8
        lightsView.layer.masksToBounds = true
        
        fanView.layer.cornerRadius = 8
        fanView.layer.masksToBounds = true
        
        lightsImageView.image = UIImage(named: "light")
        fanImageView.image = UIImage(named: "fan")
    }
    
    func getWeatherData() {
        // Check user settings for location and units
        let city = defaults.string(forKey: PreferencesKeys.city)!
        let userUnits = defaults.string(forKey: PreferencesKeys.units)!
        
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
                    self.fanEnabledLabel.text = "Offline"
                    self.lightsEnabledLabel.text = "Offline"
                    self.insideTempLabel.text = "Unable to reach server."
                    self.lightPowerSlider.isEnabled = false
                    self.lightButton.isEnabled = false
                    self.fanButton.isEnabled = false
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
                    
                    // Set temperature label
                    let userUnits = self.defaults.string(forKey: PreferencesKeys.units)!
                    if userUnits == "Fahrenheit (°F)" {
                         self.insideTempLabel.text = "Home temperature is \(self.celsiusToFahrenheit(data.temperature))°F"
                    } else if userUnits == "Celsius (°C)" {
                        self.insideTempLabel.text = "Home temperature is \(data.temperature)°C"
                    }
                   
                    // Set light power
                    self.lightPowerSlider.value = Float(data.lightLevel)
                    if self.lightPowerSlider.value == 0 {
                        self.lightEnabled = false
                    } else {
                        self.lightEnabled = true
                    }
                    
                    // Set fan card
                    self.setImage(for: self.fanButton, with: self.fanEnabled)
                    self.fanEnabledLabel.text = self.fanEnabled ? "On" : "Off"
                    
                    // Set light card
                    self.setImage(for: self.lightButton, with: self.lightEnabled)
                    self.lightsEnabledLabel.text = self.lightEnabled ? "On" : "Off"
                    
                    // Enable UI
                    self.fanButton.isEnabled = true
                    self.lightButton.isEnabled = true
                    self.lightPowerSlider.isEnabled = true
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
    
    @objc func lightSliderReleased() {
        lightPowerSlider.isEnabled = false
        server.switchLight(state: Int(lightPowerSlider.value)) { (data, error) in
            if let error = error {
                print(error)
            }
            DispatchQueue.main.async {
                if self.lightPowerSlider.value == 0 {
                    self.lightEnabled = false
                } else {
                    self.lightEnabled = true
                }
                self.lightButton.isEnabled = true
                self.lightPowerSlider.isEnabled = true
                self.setImage(for: self.lightButton, with: self.lightEnabled)
            }
        }
    }
    
    @objc func applicationDidBecomeActive() {
        getWeatherData()
        refreshServerData()
    }
    
    @IBAction func lightButtonPressed(_ sender: UIButton) {
        lightEnabled = !lightEnabled
        sender.isEnabled = false
        lightPowerSlider.isEnabled = false
        server.switchLight(state: Int(lightPowerSlider.value)) { (data, error) in
            if let error = error {
                print(error)
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.lightPowerSlider.isEnabled = true
                self.setImage(for: sender, with: self.lightEnabled)
            }
        }
        
    }
    
    @IBAction func fanButtonPressed(_ sender: UIButton) {
        fanEnabled = !fanEnabled
        sender.isEnabled = false
        lightPowerSlider.isEnabled = false
        server.switchAC(state: fanEnabled) { (data, error) in
            if let error = error {
                print(error)
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.setImage(for: sender, with: self.fanEnabled)
            }
        }
    }
    
    @IBAction func lightSliderChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        lightButton.isEnabled = false
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
            insideTempLabel.text = "Connecting to server..."
        }
        
        // Disable buttons on data is retrieved in viewWillAppear
        fanButton.isEnabled = false
        lightButton.isEnabled = false
        lightPowerSlider.isEnabled = false
    }
    
    func setNotLoadingState() {
        self.navigationItem.leftBarButtonItem = refreshButton
        activityIndicator.stopAnimating()
    }
    
    func celsiusToFahrenheit(_ celsius: Float) -> Float {
        return (celsius * 1.8) + 32;
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationLabel.text = "Welcome Home"
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationLabel.text = "Away from Home"
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == Constants.regionID {
            locationLabel.text = "Welcome Home"
        }
    }
}
