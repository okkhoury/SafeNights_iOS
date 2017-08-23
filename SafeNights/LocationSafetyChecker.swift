//
//  LocationSafetyChecker.swift
//  SafeNights
//
//  Created by Owen Khoury on 8/23/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class LocationSafetyChecker {
    
    let preferences = UserDefaults.standard
    
    
    
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
    
    // Check if the phone battery is below 1 percent.
    func batteryIsLow() -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        return UIDevice.current.batteryLevel < 1
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
        
        return sqrt((myLat - finalLat) * (myLat - finalLat) +
            (myLong - finalLong) * (myLong - finalLong)) < gpsDistance
    }
}
