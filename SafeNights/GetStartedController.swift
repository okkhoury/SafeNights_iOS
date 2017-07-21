//
//  GetStartedController.swift
//  SafeNights
//
//  Created by Owen Khoury on 5/13/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

class GetStartedController: UIViewController {
    
    /** The location you plan at which user plans to end night. */
    @IBOutlet var locationTextField: UITextField!
    
    /** Name of person to contact in case of emergency. */
    @IBOutlet var contactTextField: UITextField!
    
    /** Email of person to contact in case of emergency. */
    @IBOutlet var emailTextField: UITextField!
    
    /** Submits contact and location info. */
    @IBOutlet var submitButton: UIButton!
    
    let API = MyAPI()
    
    /**
     * Clicking submit sends a post request of username and password
     * and returns an adventureID if they are valid.
     */
    @IBAction func submit(_ sender: Any) {
        let username = mainInstance.username
        let password = mainInstance.password
        
        let resource = API.startNight
        let postData = ["username": username, "pwd": password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            var response = data.jsonDict
            let startNightAnswer = response["passed"]
            
            if let startNightAnswer = startNightAnswer as? String, startNightAnswer != "n" {
                print(startNightAnswer)
                mainInstance.nightID = startNightAnswer
                
                mainInstance.performBackgroundTask()
            }
            else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                print("night has not started")
            }
        }
        
    }
}
