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
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var contactTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    
    @IBOutlet var submitButton: UIButton!
    
    let API = MyAPI()
    
    
    @IBAction func submit(_ sender: Any) {
        let username = mainInstance.username
        let password = mainInstance.password
        
        let resource = API.startNight
        let postData = ["username": username, "pwd": password]
        
        // Make request to database to get a new adventureID (I called it a nightID)
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
