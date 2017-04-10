//
//  HomepageController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import MapKit

class HomepageController: UIViewController {
    
    @IBOutlet var startNightButton: UIButton!
    
    let username = mainInstance.username
    let password = mainInstance.password
    
    let API = MyAPI()
    
    let locManager = CLLocationManager()
    var latitude = mainInstance.latitude
    var longitude = mainInstance.longitude
    var coordinateTimer: Timer!
    
    
    // Background task to continually get latitude and longitude every 5 seconds
    func performBackgroundTask() {
        DispatchQueue.global(qos: .background).async {

            DispatchQueue.main.async {
                self.coordinateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.setCoordinates), userInfo: nil, repeats: true)
            }
        }
    }
    
    // Function get user's current latitude and longitude
    func setCoordinates() {
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
            
            print(self.latitude)
            print(self.longitude)
            print()
        }
    }
    
    // This currently links to the map when clicked
    @IBAction func clickStartNight(_ sender: Any) {
        
        // Set the initial coordinates
        setCoordinates()
        
        // Begin the async task to collect latitude and longitude
        performBackgroundTask()
        
        let resource = API.startNight
        let postData = ["username": self.username, "pwd": self.password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            // This code gets the response from the user in the form ["passed": 'y'/'n']
            var response = data.jsonDict
            let startNightAnswer = response["passed"]
            
            //startNightAnswer either returns a unique night ID or 'n'(failed)
            if let startNightAnswer = startNightAnswer as? String, startNightAnswer != "n" {
                print(startNightAnswer)
                mainInstance.nightID = startNightAnswer
            } else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                print("night has not started")
            }
        }
        
    }
}
