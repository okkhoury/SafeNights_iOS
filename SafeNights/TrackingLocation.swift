//
//  TrackingLocation.swift
//  SafeNights
//
//  Created by Owen Khoury on 8/23/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import MapKit

class TrackingLocation {
    let API = MyAPI()
    let preferences = UserDefaults.standard
    
    let locManager = CLLocationManager()
    var coordinateTimer: Timer!
    
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
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                self.coordinateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.setCoordinates), userInfo: nil, repeats: true)
            }
        }
    }
}
