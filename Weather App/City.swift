//
//  City.swift
//  Weather App
//
//  Created by Adrian Ferenc on 28.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

struct City{
    
    let cityName: String!;
    var weather: Weather?;
    let latitude : Double;
    let longitude: Double;
    
    init(cityName: String, latitude: Double, longitude: Double){
        self.cityName = cityName;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
}