//
//  LocationService
//  Texpenses
//
//  Created by Khaled Dowaid on 26/9/17.
//  Copyright © 2017 Khaled Dowaid. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol LocationServiceDelegate {
    func didUpdateLocation(currentLocation: CLLocation)
    func didUpdateLocationFailWithError(error: NSError)
    @objc optional func didChangeAuthorization(status: CLAuthorizationStatus)
    @objc optional func didReverseGeocode(place:CLPlacemark)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationService()
    private var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    let locationGeocoder: CLGeocoder = CLGeocoder()
    
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.distanceFilter = 150
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.didChangeAuthorization!(status: status)
    }
    
    func requestAuthorization(){
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func isLocationServiceAuthorised() -> Bool{
        return CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    func startUpdatingLocation() {
        print("called")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("---- updated")
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        self.currentLocation = location

        guard let delegate = self.delegate else {
            print("no delegate")
            return
        }
        
        delegate.didUpdateLocation(currentLocation: location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error as NSError)
        
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.didUpdateLocationFailWithError(error: error)
    }
    
    func getReversedGeocodeWith(locaiton:CLLocation){
        
        locationGeocoder.reverseGeocodeLocation(locaiton, completionHandler:
            {(placemarks, error) in
                
                guard let delegate = self.delegate else {
                    return
                }
                
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print("reversed")
                    delegate.didReverseGeocode!(place: pm)
                }}
        )
    }
    
}
