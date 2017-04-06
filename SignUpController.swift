//
//  SignUpController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    
    @IBAction func clickSubmit(_ sender: Any) {
        print(username.text!)
    }
    

    
}
