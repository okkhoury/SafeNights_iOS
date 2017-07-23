//
//  Global.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/9/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//


// This class holds any global variables that will be needed across views. Currently just holds username
import MapKit

class Main {
    var username:String
    var password:String
    var nightID:String
    var latitude:CLLocationDegrees
    var longitude:CLLocationDegrees
    
    
    let API = MyAPI()
    
    let locManager = CLLocationManager()
    var coordinateTimer: Timer!
    
    init(username:String, password:String, nightID:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        self.username = username
        self.password = password
        self.nightID = nightID
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Function get user's current latitude and longitude
    @objc func setCoordinates() {
        locManager.requestWhenInUseAuthorization()
        var currentLocation = CLLocation()
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location!
            
            // Set the global values for lat and lon
            mainInstance.latitude = currentLocation.coordinate.latitude
            mainInstance.longitude = currentLocation.coordinate.longitude
            
            // update the local variables for lat and lon
            self.latitude = mainInstance.latitude
            self.longitude = mainInstance.longitude
            
            // Send these coordinates to the database
            let resource = API.addLoc
            
//            print(Double(mainInstance.latitude))
//            print(Double(mainInstance.longitude))
            
            var postData = Dictionary<String, String>()
            
            postData = ["username": mainInstance.username, "pwd": mainInstance.password,
                        "id": mainInstance.nightID, "xcord": String(mainInstance.latitude),
                        "ycord": String(mainInstance.longitude)]
            
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

//Not sure if nightID should be given an initial value 
var mainInstance = Main(username:"user", password:"pwd", nightID:"", latitude:0, longitude:0)


