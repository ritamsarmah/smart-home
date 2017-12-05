//
//  HomeLocationViewController.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 11/9/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeLocationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        configureUI()
    }
    
    func configureUI() {
        confirmButton.backgroundColor = UIView().tintColor
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 8
        confirmButton.layer.masksToBounds = true
        confirmButton.setBackgroundColor(color: .black, forState: .highlighted)
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    // MARK: - IBActions
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        // Stop monitoring previous location
        locationManager.monitoredRegions.forEach {
            if $0.identifier == Constants.regionID {
                locationManager.stopMonitoring(for: $0)
            }
        }
        let region = CLCircularRegion(center: mapView.userLocation.coordinate, radius: 1, identifier: Constants.regionID)
        locationManager.startMonitoring(for: region)
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: PreferencesKeys.atHome)
    }
}

extension HomeLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
        mapView.userTrackingMode = .follow;
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}
