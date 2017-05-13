//
//  AddDrinksController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class AddDrinksController: UIViewController {
    
//    @IBOutlet var MoneyTextEdit: UITextField!
//    @IBOutlet var ShotsTextEdit: UITextField!
//    @IBOutlet var LiquerTextEdit: UITextField!
//    @IBOutlet var WineTextEdit: UITextField!
//    @IBOutlet var BeerTextEdit: UITextField!
//    
//    @IBOutlet var DateDP: UIDatePicker!
//    
//    @IBOutlet var submitButton: UIButton!
//    
//    let API = MyAPI()
//
//    let username = mainInstance.username
//    let password = mainInstance.password
//   
//    // Get the current day, month, year
//    let date = NSDate()
//    let calendar = NSCalendar.current
//    
//    //Not sure what to do about the date. what form should it be in
//    
//    //yyyy-MM-dd, string for date
//    
//   
//    @IBAction func clickSubmit(_ sender: Any) {
//        DateDP.datePickerMode = UIDatePickerMode.date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let selectedDate = dateFormatter.string(from: DateDP.date)
//        
//        let resource = API.addDrinks
//        
//        // Need to add the rest of the fields
//        let postData = ["username":username, "pwd":password, "day": selectedDate, "money": MoneyTextEdit.text!, "shots": ShotsTextEdit.text!, "liquor": LiquerTextEdit.text!, "wine": WineTextEdit.text!, "beer": BeerTextEdit.text!]
//        
//        resource.request(.post, urlEncoded: postData).onSuccess() { data in
//            
//            // This code gets the response from the user in the form ["passed": 'y'/'n']
//            var response = data.jsonDict
//            let responseAnswer = response["passed"]
//            
//            //startNightAnswer either returns a unique night ID or 'n'(failed)
//            if let responseAnswer = responseAnswer as? String, responseAnswer == "y" {
//                print("Drinks added")
//            } else if let responseAnswer = responseAnswer as? String, responseAnswer == "n" {
//                print("Drinks not added")
//            }
//        }
//    }
}
