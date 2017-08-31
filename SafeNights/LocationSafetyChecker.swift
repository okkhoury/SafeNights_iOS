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
    
    //UIDevice.current.isBatteryMonitoringEnabled = true
    
    let API = MyAPI()
    
    let MESSAGE_TYPE = "messageType";
    
    // Used to strore global values.
    let preferences = UserDefaults.standard
    
    var timer: Timer!
    
    // Background task to continually get latitude and longitude every 5 seconds.
    func performBackgroundTask() {
        print("Did I work")
        DispatchQueue.global(qos: .background).async {
            
            UIDevice.current.isBatteryMonitoringEnabled = true
            
//            OperationQueue.main.addOperation {
//                self.timer = Timer.scheduledTimer(timeInterval: 10,
//                                                  target: self, selector: #selector(self.sendTextIfInTrouble),
//                                                  userInfo: nil, repeats: true)
//            }
            
            //Check every 10 minutes if something has gone wrong.
            DispatchQueue.main.async {
                UIDevice.current.isBatteryMonitoringEnabled = true
                self.timer = Timer.scheduledTimer(timeInterval: 10,
                    target: self, selector: #selector(self.sendTextIfInTrouble),
                    userInfo: nil, repeats: true)
            }
        }
    }
    
    func stopBackgroundTask() {
        //DispatchQueue.cancelPreviousPerformRequests(withTarget: <#T##Any#>, selector: <#T##Selector#>, object: <#T##Any?#>)
        timer.invalidate()
        timer = nil
        
        print("INSIDE THIS FUNCTION")
    }
    
    // Send a text to a guardian if the user did not end up in the right place or 
    // their phone is about to die.
    @objc func sendTextIfInTrouble() {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        print("hour:")
        print(hour)
        
        print("batteryLife:")
        print(batteryIsLow())
        
        if ((!endedUpInRightPlace() && hour > 2 && hour < 7) || batteryIsLow()) {
            
            print("inside here")
            
            if (batteryIsLow()) {
                self.preferences.set("3", forKey: MESSAGE_TYPE)
            }
            
            // Takes priority over low battery message.
            if (!endedUpInRightPlace()) {
                self.preferences.set("2", forKey: MESSAGE_TYPE)
            }
            
            //TODO: Add the code to send a text to a user.
            let resource = API.safetyAlert
            
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
            
            print(postData)
            
            resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
                var response = data.jsonDict
                let loginAnswer = response["passed"]
                
                if let loginAnswer = loginAnswer as? String, loginAnswer == "y" {
                    print("successfully sent text.")
                }
                else {
                    print("failed to send text.")
                    
                    // TODO: give user notification that text did not go through
                }
            }
        }
    }
    
    // Check that the user ended up in their expected ending location.
    func endedUpInRightPlace() -> Bool {
        
        // Get these two values from self.preferences.
        let finalLat = self.preferences.value(forKey: "finalLatitude") as! Double
        let finalLong = self.preferences.value(forKey: "finalLongitude") as! Double
        
        let latLocations = self.preferences.value(forKey: "latLocations") as! [Double]
        let longLocations = self.preferences.value(forKey:"longLocations") as! [Double]
        
        return isInSameLocation(latLocations: latLocations, longLocations: longLocations) &&
            inRangeOfExpectedLocations(myLat: latLocations[0], myLong: longLocations[0],
                                       finalLat: finalLat, finalLong: finalLong)
    }
    
    // Check if the phone battery is below 5 percent.
    func batteryIsLow() -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        print("battery level:")
        print(UIDevice.current.batteryLevel)
        
        return UIDevice.current.batteryLevel < 0.05
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
}
