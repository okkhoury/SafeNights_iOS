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
    
    // 0 -> Started night.
    // 1 -> Successfully got home.
    // 2 -> Did not successfully get home.
    // 3 -> Battery low.
    // 4 -> app shutdown/crash
    // 5 -> I'm feeling lucky
    
    let API = MyAPI()
    
    let MESSAGE_TYPE = "messageType";
    
    // Used to strore global values.
    let preferences = UserDefaults.standard
    
    var timer: Timer!
    var sentLowBatWarning : Bool = false
    var sentWrongLocWarning : Bool = false
    
    // Send a text to a guardian if the user did not end up in the right place or 
    // their phone is about to die.
    @objc func sendTextIfInTrouble() {
        
        let hour = Calendar.current.component(.hour, from: Date())
        
//        print("hour:")
//        print(hour)
//        
//        print("batteryLife:")
//        print(batteryIsLow())
//        
//        print(endedUpInRightPlace())
//        print(!sentWrongLocWarning)
//        print(!sentLowBatWarning)
        
        
        if (self.preferences.value(forKey: "finalAddress") as! String == "I'm Feeling Lucky ;)" && hour > 2 && hour < 7) {
            // Let guardians know that user made it back home
            self.preferences.set("5", forKey: "messageType")
            self.sendTextToGuardians()
        }
        else if ((hour > 2 && hour < 7 && !endedUpInRightPlace() && !sentWrongLocWarning) || (batteryIsLow() && !sentLowBatWarning)) {
            
            //print("inside here")
            
            if (batteryIsLow()) {
                self.preferences.set("3", forKey: MESSAGE_TYPE)
                self.sentLowBatWarning = true
            }
            
            // Takes priority over low battery message.
            if (!endedUpInRightPlace() && !sentWrongLocWarning) {
                self.preferences.set("2", forKey: MESSAGE_TYPE)
                self.sentWrongLocWarning = true
            }
            
            // Call send text based on preferences above
            sendTextToGuardians()
        }
    }
    
    // Check that the user ended up in their expected ending location.
    func endedUpInRightPlace() -> Bool {
        
        // Get these two values from self.preferences.
        let finalLat = self.preferences.value(forKey: "finalLatitude") as! Double
        let finalLong = self.preferences.value(forKey: "finalLongitude") as! Double
        
        let latLocations = self.preferences.value(forKey: "latLocations") as! [Double]
        let longLocations = self.preferences.value(forKey:"longLocations") as! [Double]
        
        return (isInSameLocation(latLocations: latLocations, longLocations: longLocations) &&
            inRangeOfExpectedLocations(myLat: latLocations[0], myLong: longLocations[0], finalLat: finalLat, finalLong: finalLong))
    }
    
    // Check if the phone battery is below 5 percent.
    func batteryIsLow() -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        return UIDevice.current.batteryLevel < 0.1
    }
    
    // ADD ANOTHER CHECK TO SEE IF THE APP IS DESTROYED.
    
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
    
    func sendTextToGuardians() -> Void {
        
        let messageType = self.preferences.value(forKey: "messageType")
        
        let contactNumbersArray = self.preferences.value(forKey: "contactNumbers") as! [String]
        let contactNumbers = contactNumbersArray.joined(separator: ",")
        let contactNamesArray = self.preferences.value(forKey: "contactNames") as! [String]
        let contactNames = contactNamesArray.joined(separator: ",")
        
        let username = self.preferences.value(forKey: "username")
        let password = self.preferences.value(forKey: "password")
        let firstName = self.preferences.value(forKey: "fname")
        let lastName = self.preferences.value(forKey: "lname")
        
        let adventureID = self.preferences.value(forKey: "adventureID")
        let finalAddress = self.preferences.value(forKey: "finalAddress")
        let currentAddress = self.preferences.value(forKey: "currentAddress")
        
        let postData = ["contactNumbers": contactNumbers, "contactNames": contactNames,
                        "username": username, "pwd": password, "fname": firstName,
                        "lname": lastName, "id": adventureID, "finalAddress": finalAddress,
                        "currentAddress": currentAddress, "messageType": messageType]
        
        //print(postData)
        
        let resource = API.safetyAlert
        
        resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
            
            var response = data.jsonDict
            let loginAnswer = response["passed"]
            
//            print("Response")
//            print(response)
            
            if let loginAnswer = loginAnswer as? String, loginAnswer == "y" {
                //print("successfully sent text.")
            }
            else {
                //print("failed to send text.")
            }
        }.onFailure { _ in
            
        }
    }
}
