//
//  AddDrinksController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class AddDrinksController: UIViewController {
    
    @IBOutlet var MoneyTextEdit: UITextField!
    @IBOutlet var ShotsTextEdit: UITextField!
    @IBOutlet var LiquerTextEdit: UITextField!
    @IBOutlet var WineTextEdit: UITextField!
    @IBOutlet var BeerTextEdit: UITextField!
    
    
    @IBOutlet var submitButton: UIButton!
    
    let API = MyAPI()

    let username = mainInstance.username
    let password = mainInstance.password
   
    // Get the current day, month, year
    let date = NSDate()
    let calendar = NSCalendar.current
    
    //Not sure what to do about the date. what form should it be in
    
    
   
    @IBAction func clickSubmit(_ sender: Any) {
        let resource = API.addDrinks
        
        // Need to add the rest of the fields
        let postData = ["username":username, "pwd":password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            // This code gets the response from the user in the form ["passed": 'y'/'n']
            var response = data.jsonDict
            let responseAnswer = response["passed"]
            
            //startNightAnswer either returns a unique night ID or 'n'(failed)
            if let responseAnswer = responseAnswer as? String, responseAnswer == "y" {
                print("Drinks added")
            } else if let responseAnswer = responseAnswer as? String, responseAnswer == "n" {
                print("Drinks not added")
            }
        }
    }
}
