//
//  Weather.swift
//
//  Created by Ritam Sarmah on 10/24/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

import Foundation

enum Units: String {
    case fahrenheit = "imperial"
    case celsius = "metric"
}

struct WeatherData: Codable {
    struct Weather : Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    struct Main : Codable {
        let temp: Float
        let pressure: Float
        let humidity: Int
        let temp_min: Float
        let temp_max: Float
    }
    
    let weather: [Weather]
    let main: Main
    
    func getTemperature() -> Float {
        return main.temp
    }
    
    func getCondition() -> String {
        return weather[0].main
    }
    
    func getIconName() -> String {
        switch weather[0].icon {
        case "01d":
            return "sun"
        case "01n":
            return "moon"
        case "02d":
            return "suncloud"
        case "02n":
            return "mooncloud"
        case "03d", "03n":
            return "cloud"
        case "04d", "04n":
            return "twoclouds"
        case "09d", "09n":
            return "rain"
        case "10d":
            return "sunrain"
        case "10n":
            return "moonrain"
        case "11d", "11n":
            return "storm"
        case "13d", "13n":
            return "snow"
        case "50d", "50n":
            return "fog"
        default:
            return "sun"
        }
    }
}

class Weather {
    func getWeather(for city: String, units: Units, completion: @escaping (WeatherData?, Error?) -> Void) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        let query = URLQueryItem(name: "q", value: city.replacingOccurrences(of: " ", with: "+"))
        let appid = URLQueryItem(name: "appid", value: Constants.key)
        let units = URLQueryItem(name: "units", value: units.rawValue)
        components.queryItems = [query, appid, units]
        
        guard let url = components.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            
            guard let responseData = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy =
                .convertFromString(
                    positiveInfinity: "+Infinity",
                    negativeInfinity: "-Infinity",
                    nan: "NaN")
            
            do {
                let weatherData = try decoder.decode(WeatherData.self, from: responseData)
                completion(weatherData, nil)
            } catch {
                print("Error trying to convert data to JSON")
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
}
