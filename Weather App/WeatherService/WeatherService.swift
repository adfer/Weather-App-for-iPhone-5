//
//  WeatherService.swift
//  Weather App
//
//  Created by Adrian Ferenc on 30.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

protocol WeatherServiceDelegate{
    
    func setCity(city: City!);
    
    func setWeather(weather: Weather!);
    
}

protocol WeatherService{

    var delegate: WeatherServiceDelegate? { get set };

    func getWeather(latitude: Double, longitude: Double);
    
    func getWeather(cityName: String);
    
}