//
//  TrackingLocation.swift
//  SafeNights
//
//  Created by Owen Khoury on 8/23/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import MapKit
import GoogleMaps

class TrackingLocation {
    let API = MyAPI()
    let preferences = UserDefaults.standard
    
    //For Testing - Zach
    let locationChecker = LocationSafetyChecker()
    
    let locManager = CLLocationManager()
    var coordinateTimer: Timer!
    
    var latLocations = Array(repeating: 0.0, count: 4)
    var longLocations = Array(repeating: 0.0, count: 4)
    
    // Function get user's current latitude and longitude
    @objc func setCoordinates() {
        locManager.requestWhenInUseAuthorization()
        var currentLocation = CLLocation()
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location!
            
            // Set the global values for lat and lon
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            
            getAddress(lat: latitude, lon: longitude) { (returnAddress) in
                _ = self.preferences.set("\(returnAddress)", forKey: "currentAddress")
            }
            
            // Store the
            latLocations[3] = latLocations[2]
            latLocations[2] = latLocations[1]
            latLocations[1] = latLocations[0]
            latLocations[0] = latitude
            
            // Store the 4 most recent longitudes
            longLocations[3] = longLocations[2]
            longLocations[2] = longLocations[1]
            longLocations[1] = longLocations[0]
            longLocations[0] = longitude
            
            print("Latitudes:")
            print(latLocations)
            
            print("Longitudes")
            print(longLocations)
            
            _ = self.preferences.set(latLocations, forKey: "latLocations")
            _ = self.preferences.set(longLocations, forKey: "longLocations")
            
            // Send these coordinates to the database
            let resource = API.addLoc
            
            var postData = Dictionary<String, String>()
            
            let username = self.preferences.string(forKey: "username")!
            let password = self.preferences.string(forKey: "password")!
            let adventureID = self.preferences.string(forKey: "adventureID")!
            
            postData = ["username": username, "pwd": password,
                        "id": adventureID, "xcord": String(latitude),
                        "ycord": String(longitude)]
            
            print(postData)
            
            resource.request(.post, urlEncoded: postData ).onSuccess() { data in
                
                // This code gets the response from the user in the form ["passed": 'y'/'n']
                var response = data.jsonDict
                let loginAnswer = response["passed"]
                
                // If the response is a yes, allow access to the next page, otherwise deny access and give message to user
                if let loginAnswer = loginAnswer as? String, loginAnswer == "y" {
                    print("succesfully added location")
                }
                else if let loginAnswer = loginAnswer as? String, loginAnswer == "n" {
                    print("Did not add location")
                }
                else {
                    print(data.jsonDict)
                }
                
                }.onFailure{_ in
                    print("failed")
            }
        }
    }
    
    // Background task to continually get latitude and longitude every 5 seconds
    func performBackgroundTask() {
        self.locationChecker.performBackgroundTask()
        print("I tried")
        
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                self.coordinateTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                    selector: #selector(self.setCoordinates), userInfo: nil, repeats: true)
            }
        }
    }
    
    // Stop collecting locations and checking for safety
    func stopBackgroundTask() {
        self.coordinateTimer.invalidate()
        self.coordinateTimer = nil
        self.locationChecker.stopBackgroundTask();
        
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    }
    
    func getAddress(lat: Double, lon: Double, currentAdd : @escaping ( _ returnAddress :String)->Void){
        let geocoder = GMSGeocoder()
        let coordinate = CLLocationCoordinate2DMake(lat, lon)

        var currentAddress = String()

        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]

                currentAddress = lines[0]
                currentAdd(currentAddress)
            }
        }
    }
}
