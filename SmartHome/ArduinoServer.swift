//
//  ArduinoServer.swift
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

class ArduinoServer {
    let defaults = UserDefaults.standard
    let timeoutInterval = 5.0
    
    func getData(completion: @escaping (ArduinoData?, Error?) -> Void) {
        let url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
//        request.timeoutInterval = timeoutInterval
        
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
                print(arduinoData)
                completion(arduinoData, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
        
    }
    
    func switchAC(state: Bool, completion: @escaping (ArduinoData?, Error?) -> Void) {
        var url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        let numState = state ? 1 : 0
        url.appendPathComponent("a\(numState)")
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
//        request.timeoutInterval = timeoutInterval
        
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
                print(arduinoData)
                completion(arduinoData, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func switchLight(state: Int, completion: @escaping (ArduinoData?, Error?) -> Void) {
        var url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        url.appendPathComponent("l\(state)")
        var request = URLRequest(url:url)
        
        request.httpMethod = "GET"
//        request.timeoutInterval = timeoutInterval
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard let responseData = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
                completion(nil,error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let strData = try decoder.decode(ArduinoStringData.self, from: responseData)
                let arduinoData = ArduinoData(temperature: Float(strData.Temperature)!, humidity: Float(strData.Humidity)!, lightLevel: Int(strData.Light_Level)!, ac: Int(strData.AC)!)
                print(arduinoData)
                completion(arduinoData,nil)
            } catch {
                print("Error")
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    
    func switchUserLocation(state: Bool, completion: @escaping (ArduinoData?, Error?) -> Void) {
        var url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        let numState = state ? 1 : 0
        url.appendPathComponent("p\(numState)")
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
//        request.timeoutInterval = timeoutInterval
        
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
                print(arduinoData)
                completion(arduinoData, nil)
            } catch {
                completion(nil,error)
                
            }
        }
        
        task.resume()
    }
    
    func switchAutomation(state: Bool, completion: @escaping (ArduinoData?, Error?) -> Void) {
        var url = defaults.url(forKey: PreferencesKeys.ipAddress)!
        
        let numState = state ? 1 : 0
        url.appendPathComponent("m\(numState)")
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.timeoutInterval = timeoutInterval
        
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
                print(arduinoData)
                completion(arduinoData, nil)
            } catch {
                print("Error")
                completion(nil,error)
                
            }
        }
        
        task.resume()
    }
    
}
