//
//  ViewController.swift
//  truetime
//
//  Created by Holger Engelke on 2018-03-25.
//  Copyright © 2018 Holger Engelke. All rights reserved.
//

import UIKit
import CoreLocation

private func stringFromLongitude(from longitude: CLLocationDegrees) -> String {
    var sec = Int(longitude * 3600)
    let deg = sec / 3600
    sec = abs(sec % 3600)
    let min = sec / 60
    sec %= 60
    return String(format:"%d° %d' %d\" %@", abs(deg), min, sec, deg >= 0 ? "E" : "W" )
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var labelUniversalTime: UILabel!
    @IBOutlet weak var labelZoneTime: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelMeridianTime: UILabel!
    @IBOutlet weak var labelLocalMeanTime: UILabel!
    
    @IBOutlet weak var valueUniversalTime: UILabel!
    @IBOutlet weak var valueZoneTime: UILabel!
    @IBOutlet weak var valueLocation: UILabel!
    @IBOutlet weak var valueMeridianTime: UILabel!
    @IBOutlet weak var valueLocalMeanTime: UILabel!
    
    @IBAction func updateLocationButton() {
        updateLocation()
    }
    
    let locationManager = CLLocationManager()
    var longitude : CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
        updateLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        longitude = locations.last!.coordinate.longitude
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locations.last!, completionHandler: { (placemarks, error) in
            if error == nil {
                self.labelLocation.text = placemarks?[0].locality
            }
            else {
                self.labelLocation.text = "Your Location"
            }
            self.valueLocation.text = stringFromLongitude(from: self.longitude)
        })
    }
    
    @objc func tick() {
        updateTime()
    }
    
    func updateLocation() {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        labelZoneTime.text = TimeZone.current.localizedName(for: TimeZone.current.isDaylightSavingTime() ? .daylightSaving : .standard, locale: .current) ?? TimeZone.current.abbreviation()
        updateTime()
    }
    
    func updateTime() {
        let meridian = round(longitude / 15) * 15
        let timeZone = Date()
        let timeUTC = timeZone - TimeInterval(TimeZone.current.secondsFromGMT())
        let timeMeridian = timeUTC + TimeInterval(meridian / 360 * 60 * 60 * 24)
        let timeLocation = timeUTC + TimeInterval(longitude / 360 * 60 * 60 * 24)
        valueUniversalTime.text = DateFormatter.localizedString(from: timeUTC, dateStyle: .none, timeStyle: .medium)
        valueZoneTime.text = DateFormatter.localizedString(from: timeZone, dateStyle: .none, timeStyle: .medium)
        valueMeridianTime.text = DateFormatter.localizedString(from: timeMeridian, dateStyle: .none, timeStyle: .medium)
        valueLocalMeanTime.text = DateFormatter.localizedString(from: timeLocation, dateStyle: .none, timeStyle: .medium)
    }

}

