//
//  LocationSafetyChecker.swift
//  SafeNights
//
//  Created by Owen Khoury on 8/23/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import MessageUI

/**
 * Class to check if the user has successfully made it back to
 * their intended location.
 */
class LocationSafetyChecker {
    
    var messageType = ""
    
    let API = MyAPI()
    
    // Used to strore global values.
    let preferences = UserDefaults.standard
    
    var timer: Timer!
    
    // Background task to continually get latitude and longitude every 5 seconds.
    func performBackgroundTask() {
        DispatchQueue.global(qos: .background).async {
            //Check every 10 minutes if something has gone wrong.
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 600,
                    target: self, selector: #selector(self.sendTextIfInTrouble),
                    userInfo: nil, repeats: true)
            }
        }
    }
    
    // Send a text to a guardian if the user did not end up in the right place or 
    // their phone is about to die.
    @objc func sendTextIfInTrouble() {
        if (!endedUpInRightPlace() || batteryIsLow()) {
            
            //TODO: Add the code to send a text to a user.
            let resource = API.safetyAlert
            
            let contactNumbers = self.preferences.value(forKey: "contactNumbers") as! [String]
            let contactNames = self.preferences.value(forKey: "contactNames") as! [String]
            
            let username = self.preferences.value(forKey: "usernameStr")
            let password = self.preferences.value(forKey: "passwordStr")
            let firstName = self.preferences.value(forKey: "fname")
            let lastName = self.preferences.value(forKey: "lname")
            
            let adventureID = self.preferences.value(forKey: "adventureID")
            
            let finalAddress = self.preferences.value(forKey: "finalAddress")
            
            let currentAddress = self.preferences.value(forKey: "currentAddress")
            
            // THE CODE TO SET THE MESSAGE TYPE HASN'T BEEN ADDED YET. MESSAGE TYPE TELLS THE WEB SIDE WHAT KIND
            // OF MESSAGE TO SEND.
            
            let postData = ["contactNumbers": contactNumbers, "contactNames": contactNames,
                            "username": username, "password": password, "firstName": firstName,
                            "lastName": lastName, "adventureID": adventureID, "finalAddress": finalAddress,
                            "currentAddress": currentAddress, "messageType": messageType]
            
            resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
                // Add check for if post request succeeded.
            }
        }
    }
    
    // Check that the user ended up in their expected ending location.
    func endedUpInRightPlace() -> Bool {
        
        // Get these two values from self.preferences.
        let finalLat = 255.0
        let finalLong = 347.6
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        let latLocations = self.preferences.value(forKey: "latLocations") as! [Double]
        let longLocations = self.preferences.value(forKey:"longLocations") as! [Double]
        
        return hour >= 2 && hour <= 7 &&
            isInSameLocation(latLocations: latLocations, longLocations: longLocations) &&
            !inRangeOfExpectedLocations(myLat: latLocations[0], myLong: longLocations[0],
                                       finalLat: finalLat, finalLong: finalLong)
    }
    
    // Check if the phone battery is below 5 percent.
    func batteryIsLow() -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        return UIDevice.current.batteryLevel < 5
    }
    
    // Check that the user has been in the same area for a while.
    func isInSameLocation(latLocations: [Double], longLocations:[Double]) -> Bool {
        
        let gpsDifference = 0.0006; //.0006 = 61m difference
        
        return abs(latLocations[3] - latLocations[2]) < gpsDifference &&
               abs(latLocations[2] - latLocations[1]) < gpsDifference &&
               abs(latLocations[1] - latLocations[0]) < gpsDifference &&
               abs(longLocations[3] - longLocations[2]) < gpsDifference &&
               abs(longLocations[2] - longLocations[1]) < gpsDifference &&
               abs(longLocations[1] - longLocations[0]) < gpsDifference
    }
    
    // Check if the user is where they planned to end up for the night.
    func inRangeOfExpectedLocations(myLat: Double, myLong: Double,
                                    finalLat: Double, finalLong: Double) -> Bool {
        
        let gpsDistance = 0.0015; //.001 = 111m difference
        
        // Distance formula between current location and intended endpoint.
        return sqrt((myLat - finalLat) * (myLat - finalLat) +
            (myLong - finalLong) * (myLong - finalLong)) < gpsDistance
    }
}
