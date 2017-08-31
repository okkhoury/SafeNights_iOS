//
//  AppDelegate.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let preferences = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        GMSServices.provideAPIKey("AIzaSyAvgr7MEpW6tAr_FpWPrdGwJL1_jSxbYbk")
        GMSPlacesClient.provideAPIKey("AIzaSyAvgr7MEpW6tAr_FpWPrdGwJL1_jSxbYbk")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.preferences.set("4", forKey: "messageType")
        
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
                        "username": username, "password": password, "firstName": firstName,
                        "lastName": lastName, "adventureID": adventureID, "finalAddress": finalAddress,
                        "currentAddress": currentAddress, "messageType": self.preferences.value(forKey: "messageType")]
        
        let API = MyAPI()
        let resource = API.safetyAlert
        
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

