//
//  RegisterController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

/**
 * Controller for the sign up page. Used to create a new user.
 */
class RegisterController: UIViewController {
    
    /** Text field where user enters their first name. */
    @IBOutlet var firstName: UITextField!
    
    /** Text field where user enters their last name. */
    @IBOutlet var lastName: UITextField!
    
    /** Text field where user enters their email. */
    @IBOutlet var emailAddress: UITextField!
    
    /** Text field where user enters their username. */
    @IBOutlet var username: UITextField!
    
    /** Text field where user enters their password.  */
    @IBOutlet var password: UITextField!
    
    /** Attempts to create new user account when pressed.  */
    @IBOutlet var createAccountButton: UIButton!
    
    let API = MyAPI()
    
    /**
     * When user clicks submit send post request to try and
     * create a new user.
     */
    @IBAction func clickCreateAccount(_ sender: Any) {
        let resource = API.signup
        let postData = ["username": username.text,
                        "email": emailAddress.text,
                        "pwd": password.text,
                        "fname": firstName.text,
                        "lname": lastName.text]
        
        resource.request(.post, urlEncoded: postData as! [String : String]).onSuccess() { data in
            
            var response = data.jsonDict
            let signupAnswer = response["passed"]
            
            if let signupAnswer = signupAnswer as? String, signupAnswer == "y" {
                print("User added to database")
                
            } else if let signupAnswer = signupAnswer as? String, signupAnswer == "n" {
                print("User not added")
            }
        }
        // Go back to the login page regardless what happens (should change this later)
        performSegue(withIdentifier: "signupToLogin", sender: nil)
    }
}
