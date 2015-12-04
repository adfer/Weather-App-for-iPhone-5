//
//  ViewController.swift
//  Weather App
//
//  Created by Adrian Ferenc on 28.11.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import UIKit;
import CoreLocation;
import MapKit;
import QuartzCore;

extension UIView {
    /**
     Usage: insert view.fadeTransition right before changing content
     - parameter duration: duration of fade animation
     */
    func fadeTransition(duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: kCATransitionFade)
    }
}

extension UIImageView {
    
    /**
     Load image from URL and set it to UIImageView on which this method was invoked.
     - parameter urlString: absolute url path to image
     */
    public func imageFromUrl(urlString: String) {
        if(Utility.isConnectedToNetwork()){
            if let url = NSURL(string: urlString) {
                if let data = NSData(contentsOfURL: url) {
                    self.fadeTransition(0.4);
                    self.image = UIImage(data: data)
                }
            }
        }
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, WeatherServiceDelegate {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let fadeTransitionDuration = 0.4;
    
    let locationManager = CLLocationManager();
    
    var userLocation = CLLocation();
    
    var city: City!;
    
    let weatherService = WeatherServiceOpenWeatherMap();
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.weatherService.delegate = self;
        
        //check authorization for getting location of device
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.requestWhenInUseAuthorization();
            self.locationManager.startUpdatingLocation();
        }
        
        //change sub-view which is displayed on map
        self.subView.layer.cornerRadius = 10;
        self.subView.layer.masksToBounds = true;
        
        self.getWeatherForDefaultLocation();
        
    }
    
    func getWeatherForDefaultLocation(){
        self.weatherService.getWeather(self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude);
    }
    
    @IBAction func myLocalizationAction(sender: UIButton) {
        if Utility.isConnectedToNetwork() {
            self.weatherService.getWeather(self.userLocation.coordinate.latitude,longitude: self.userLocation.coordinate.longitude);
        }
        else {
            self.noInternetConnectionAlert();
        }
    }
    
    @IBAction func changeCityAction(sender: UIButton) {
        Utility.debug("Change city button pressed");
        
        let changeCityPopup = UIAlertController(title: NSLocalizedString("PICK_CITY_ALERT_CITY_TITLE", comment:""), message: NSLocalizedString("PICK_CITY_NAME", comment:""), preferredStyle: UIAlertControllerStyle.Alert);
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment:""), style: UIAlertActionStyle.Cancel, handler: nil);
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: UIAlertActionStyle.Default) { (okAction: UIAlertAction) -> Void in
            self.processChangedCity(changeCityPopup, okAction: UIAlertAction());
        }
        
        changeCityPopup.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = NSLocalizedString("CITY_NAME_PLACEHOLDER", comment:"");
        }
        
        changeCityPopup.addAction(cancelAction);
        changeCityPopup.addAction(okAction);
        
        
        self.presentViewController(changeCityPopup, animated: true, completion: nil);
        
    }
    
    func processChangedCity(popupAlertController: UIAlertController, okAction: UIAlertAction){
        
        Utility.debug("OK button pressed in popup dialog");
        
        let cityName = popupAlertController.textFields?[0].text!;
        
        Utility.debug("Wprowadzono nazwę miasta: \(cityName)");
        cityLabel.fadeTransition(fadeTransitionDuration);
        self.cityLabel.text = cityName;
        if Utility.isConnectedToNetwork() {
            self.weatherService.getWeather(cityName!);
        }
        else {
            self.noInternetConnectionAlert();
        }
        
    }
    
    func setWeather(weather: Weather!) {
        Utility.debug("Setting weather informations");
        Utility.debug("\(self.city.cityName) \(weather.temperature) \(weather.weatherDescription)");
        temperatureLabel.fadeTransition(fadeTransitionDuration);
        temperatureLabel.text = Utility.getCelsiusTemperatureAsString(weather.temperature);
        descriptionLabel.fadeTransition(fadeTransitionDuration);
        descriptionLabel.text = weather.weatherDescription;
        self.weatherImage.imageFromUrl(weather.weatherConditionIcon);
    }
    
    func setCity(city: City!) {
        Utility.debug("Setting city informations: \(city.cityName)");
        self.city = city;
        cityLabel.fadeTransition(fadeTransitionDuration);
        cityLabel.text = self.city.cityName;
        
        if Utility.isConnectedToNetwork() {
            let center = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude);
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1));
            
            self.mapView.setRegion(region, animated: true);
        }
        else {
            self.noInternetConnectionAlert();
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
            if error != nil {
                Utility.debug("Błąd podczas pobieranie domyślnej lokalizacji: \(error)");
                return;
            }
            if placemarks!.count > 0{
                let pm = placemarks![0] as CLPlacemark;
                self.locationManager.stopUpdatingLocation();
                self.userLocation = pm.location!;
                self.getWeatherForDefaultLocation();
            }
        }
    }
    
    func noInternetConnectionAlert(){
        
        let noInternetConnectionAlert = UIAlertController(title: "Brak połączenia z Internetem", message: "Aplikacja nie może pobrać danych bez dostępu do Internetu.", preferredStyle: UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: UIAlertActionStyle.Default, handler: nil);
        
        noInternetConnectionAlert.addAction(okAction);
        
        
        self.presentViewController(noInternetConnectionAlert, animated: true, completion: nil);
        
    }
    
}

