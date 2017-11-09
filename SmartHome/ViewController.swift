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
    
    // MARK: - Properties
    let weather = Weather()
    
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
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Set up observer for when application becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        // Refresh weather data
        self.getWeatherData()
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
        
        // TODO: Set UI based on state on server
        
        // Set labels for on or off
        lightsEnabledLabel.text = lightEnabled ? "On" : "Off"
        fanEnabledLabel.text = fanEnabled ? "On" : "Off"
        
        lightPowerSlider.value = lightPower
        
        // Set greeting label based on time of day
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        print(hour)
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
    
    @objc func settingsTapped() {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @objc func applicationDidBecomeActive() {
        getWeatherData()
    }
    
    @IBAction func lightButtonPressed(_ sender: UIButton) {
        lightEnabled = !lightEnabled
        setImage(for: sender, with: lightEnabled)
    }
    
    @IBAction func fanButtonPressed(_ sender: UIButton) {
        fanEnabled = !fanEnabled
        setImage(for: sender, with: fanEnabled)
    }
    
    func setImage(for button: UIButton, with state: Bool) {
        if state == true {
            button.setImage(#imageLiteral(resourceName: "buttonOn"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "buttonOff"), for: .normal)
        }
    }
    
    @IBAction func lightSliderChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        lightPower = roundedValue
        sender.value = roundedValue
    }

}

// https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
extension ViewController: CLLocationManagerDelegate {
    
    
}

