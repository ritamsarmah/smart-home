//
//  Arduinoserver.swift
//  SmartHome
//
//  Created by Manav Maroli on 11/10/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import Foundation

struct ArduinoStringData: Codable {
    let Temperature: String
    let Humidity: String
    let Light_Level: String
    let AC: String
}

struct ArduinoData {
    let temperature: Float
    let humidity: Float
    let lightLevel: Int
    let ac: Int
}

class Arduino {
    let defaults = UserDefaults.standard
    
    func getData(completion: @escaping (ArduinoData?, Error?) -> Void) {
        let url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard let responseData = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let strData = try decoder.decode(ArduinoStringData.self, from: responseData)
                let arduinoData = ArduinoData(temperature: Float(strData.Temperature)!, humidity: Float(strData.Humidity)!, lightLevel: Int(strData.Light_Level)!, ac: Int(strData.AC)!)
                completion(arduinoData, nil)
            } catch {
                print("Error")
                completion(nil,error)
                
            }
        }
        
        task.resume()
        
    }
    
}