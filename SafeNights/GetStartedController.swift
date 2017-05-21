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
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        let username = mainInstance.username
        let password = mainInstance.password
        
        let API = MyAPI()
        let resource = API.startNight
        
        
        
        
        
        
    }
}
