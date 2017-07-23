//
//  LoginController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

/**
 * Controller for the user login page.
 */
class LoginController: UIViewController {
    
    /** Text field where user enters username. */
    @IBOutlet var username: UITextField!
    
    /** Text field where user enters password. */
    @IBOutlet var password: UITextField!
    
    /** button used clicked to attempt to login. */
    @IBOutlet var submitButton: UIButton!
    
    /** button used to go to the signup page. */
    @IBOutlet var registerButton: UIButton!
    
    let API = MyAPI()
    
    /**
     * When user clicks submit send post request of username and
     * password. Allow access if response does not equal 'n'.
     */
    @IBAction func Login(_ sender: Any) {
        let resource = API.signin
        
        let postData = ["username": username.text, "pwd": password.text]
        resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
            
            var response = data.jsonDict
            let loginAnswer = response["passed"]
            
            if let loginAnswer = loginAnswer as? String, loginAnswer != "n"{
                
                mainInstance.username = self.username.text!
                mainInstance.password = self.password.text!
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Permission Denied")
            }
        }
    }
}
    
   
    
    

