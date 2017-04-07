//
//  RegisterController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

class RegisterController: UIViewController {
    
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var createAccountButton: UIButton!
    
    
    let API = MyAPI()
    
    @IBAction func clickCreateAccount(_ sender: Any) {
        let resource = API.signup
        let postData = ["username": username.text, "email": emailAddress.text, "pwd": password.text,
                        "fname": firstName.text, "lname": lastName.text]
        
        // Send the request to the database
        resource.request(.post, urlEncoded: postData as! [String : String]).onSuccess() { data in
            
            // See if the user was succesfully added
            var response = data.jsonDict
            let signupAnswer = response["passed"]
            
            // If the response is a yes, create the user and link back to the login page
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
