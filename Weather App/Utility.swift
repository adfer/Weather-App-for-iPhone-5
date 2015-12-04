//
//  Utility.swift
//  Weather App
//
//  Created by Adrian Ferenc on 28.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum TemperatureScale{

    case Kelvin;
    case Fahrenheit;

}

class Utility{
    
    static let DEBUG = true;
    
    static func debug(textToPrint: String) -> Void{
        if DEBUG {
            print(textToPrint);
        }
    }
    
    static func getCelsiusTemperatureAsString(celsiusTemperature: Double) -> String{
        return "\(celsiusTemperature)\u{00B0}C";
    }
    
    static func convertKelvinToCelsius(kelvinTemperature: Double) -> Double{
        let kelvinConstant = 273.15;
        return roundToPlaces(Double(kelvinTemperature - kelvinConstant), places: 1);
    }

    static func convertFahrenheitToCelsius(fahrenheitTemperature: Double) -> Double{
        let fahrenheitConstant1 = 32.0;
        let fahrenheitConstant2 = 1.8;
        return roundToPlaces(Double((fahrenheitTemperature - fahrenheitConstant1) / fahrenheitConstant2), places: 1);
    }
    
    static func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places));
        return round(value * divisor) / divisor;
    }

    
    static func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
                SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
    }
    
    static func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
}