//
//  WeatherService.swift
//  Weather App
//
//  Created by Adrian Ferenc on 28.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

class WeatherServiceOpenWeatherMap: WeatherService{
    
    var delegate: WeatherServiceDelegate?;
    
    func getWeather(latitude: Double, longitude: Double){
        
        Utility.debug("Pobieranie pogody dla miasta o współrzędnych\(latitude) \(longitude)");
        
        if Utility.isConnectedToNetwork() {
            
            var apiKey: String! = "";
            var myDict: NSDictionary?;
            if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
                myDict = NSDictionary(contentsOfFile: path);
            }
            if let dict = myDict {
                apiKey = dict.valueForKey("openweathermap.org")?.valueForKey("apiKey") as! String;
            }
            let apiPath = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&APPID=\(apiKey)";
            let url = NSURL(string: apiPath);
            let session = NSURLSession.sharedSession();
            let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if data != nil{
                    let json = JSON(data: data!);
                    let cityNameFromService = json["name"].string;
                    let temperature = Utility.convertKelvinToCelsius(json["main"]["temp"].double!);
                    let latitude = json["coord"]["lat"].double;
                    let longitude = json["coord"]["lon"].double;
                    let weatherDescription = json["weather"][0]["description"].string;
                    let weatherConditionIcon = "http://openweathermap.org/img/w/\(json["weather"][0]["icon"].string ).png";
                    if cityNameFromService != nil  && weatherDescription != nil {
                        let weather = Weather(temperature: temperature, weatherDescription: weatherDescription!, weatherConditionIcon: weatherConditionIcon);
                        var city = City(cityName: cityNameFromService!, latitude: latitude!, longitude: longitude!);
                        city.weather = weather;
                        
                        if self.delegate != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.delegate?.setCity(city);
                                self.delegate?.setWeather(city.weather);
                            })
                        }
                    }
                }
            }
            
            task.resume();
            
        }
    }
    
    func getWeather(cityName: String){
        
        Utility.debug("Pobieranie pogody dla miasta \(cityName)");
        
        let escapedCityName = cityName.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet());
        var apiKey: String! = "";
        var myDict: NSDictionary?;
        if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path);
        }
        if let dict = myDict {
            apiKey = dict.valueForKey("openweathermap.org")?.valueForKey("apiKey") as! String;
        }
        let apiPath = "http://api.openweathermap.org/data/2.5/weather?q=\(escapedCityName!)&APPID=\(apiKey)";
        let url = NSURL(string: apiPath);
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            let json = JSON(data: data!);
            let cityNameFromService = json["name"].string;
            let temperature = Utility.convertKelvinToCelsius(json["main"]["temp"].double!);
            let latitude = json["coord"]["lat"].double;
            let longitude = json["coord"]["lon"].double;
            let weatherDescription = json["weather"][0]["description"].string;
            let weatherConditionIcon = json["weather"][0]["icon"].string;
            if cityNameFromService != nil  && weatherDescription != nil {
                let weather = Weather(temperature: temperature, weatherDescription: weatherDescription!, weatherConditionIcon: weatherConditionIcon!);
                var city = City(cityName: cityNameFromService!, latitude: latitude!, longitude: longitude!);
                city.weather = weather;
                
                if self.delegate != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.setCity(city);
                        self.delegate?.setWeather(city.weather);
                    })
                }
            }
            
        }
        
        task.resume();
        
    }
    
}