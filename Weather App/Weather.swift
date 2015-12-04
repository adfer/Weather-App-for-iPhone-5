//
//  Weather.swift
//  Weather App
//
//  Created by Adrian Ferenc on 28.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

struct Weather {
    
    let temperature: Double;
    let weatherDescription: String;
    let weatherConditionIcon: String;
    
    init(temperature: Double, weatherDescription: String, weatherConditionIcon: String){
        self.temperature = temperature;
        self.weatherDescription = weatherDescription;
        self.weatherConditionIcon = weatherConditionIcon + ".png";
    }
    
}