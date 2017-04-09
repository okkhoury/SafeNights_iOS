//
//  HomepageController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class HomepageController: UIViewController {
    
    @IBOutlet var startNightButton: UIButton!
    
    let username = mainInstance.username
    let password = mainInstance.password
    
    let API = MyAPI()
    
    @IBAction func clickStartNight(_ sender: Any) {
        print(mainInstance.username)
        print(mainInstance.password)
        
        let resource = API.startNight
        let postData = ["username": self.username, "pwd": self.password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            print("Here")
            
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
