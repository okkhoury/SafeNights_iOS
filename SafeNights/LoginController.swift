//
//  LoginController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

class LoginController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    let API = MyAPI()
    
    @IBAction func clickSubmit(_ sender: Any) {
        let resource = API.signin
        //let postData = ["username": "zrs", "pwd": "1234"]
        let postData = ["username": username.text, "pwd": password.text]
        resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
            
            // This code gets the response from the user in the form ["passed": 'y'/'n']
            var response = data.jsonDict
            let loginAnswer = response["passed"]
            
            // If the response is a yes, allow access to the next page, otherwise deny access and give message to user
            if let loginAnswer = loginAnswer as? String, loginAnswer == "y" {
                print("Access allowed")
                
                // If user signed in correctly, set the global username
                mainInstance.username = self.username.text!
                
                // Go to the home page if the user is in the database
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
                
            } else if let loginAnswer = loginAnswer as? String, loginAnswer == "n" {
                print("Access denied")
            }
        }
    }
    
}
    
   
    
    

