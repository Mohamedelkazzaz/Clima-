//
//  WeatherManager.swift
//  Clima
//
//  Created by Mohamed Elkazzaz on 16/06/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ seweatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=72102b30fa29a5b3552d9aad0ef0244f&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perform(urlString: urlString)
        
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        perform(urlString: urlString)
    }
    
    func perform(urlString: String) {
        
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                    
                }
                
                if let safeData = data {
                    if let weather = self.parseJson(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
        
        func parseJson(weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            do {
                 let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
               let id = decodeData.weather[0].id
                let temp = decodeData.main.temp
                let name = decodeData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
            }catch{
                self.delegate?.didFailWithError(error: error)
                return nil
            }
            
        }
    
    
    }
    
    

