//
//  AddDrinksController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class AddDrinksController: UIViewController {
    
    @IBOutlet var DatePick: UIDatePicker!
    @IBOutlet var submitButton: UIButton!
    
    let seekBar1 = CircularSeeker()
    let seekBar2 = CircularSeeker()
    let seekBar3 = CircularSeeker()
    let seekBar4 = CircularSeeker()
    
    let API = MyAPI()
    
    let username = mainInstance.username
    let password = mainInstance.password
    
    let date = NSDate()
    let calendar = NSCalendar.current
    
    override func viewDidLoad() {
        seekBar1.frame = CGRect(x: 30, y: 300, width: 100, height: 100)
        seekBar1.startAngle = 120
        seekBar1.endAngle = 60
        seekBar1.currentAngle = 120
        seekBar1.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar1)
        
        seekBar2.frame = CGRect(x: 230, y: 300, width: 100, height: 100)
        seekBar2.startAngle = 120
        seekBar2.endAngle = 60
        seekBar2.currentAngle = 120
        seekBar2.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar2)
        
        seekBar3.frame = CGRect(x: 30, y: 450, width: 100, height: 100)
        seekBar3.startAngle = 120
        seekBar3.endAngle = 60
        seekBar3.currentAngle = 120
        seekBar3.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar3)
        
        seekBar4.frame = CGRect(x: 230, y: 450, width: 100, height: 100)
        seekBar4.startAngle = 120
        seekBar4.endAngle = 60
        seekBar4.currentAngle = 120
        seekBar4.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar4)
        
        DatePick.setValue(UIColor.white, forKeyPath: "textColor")
        
    }
    
    
    @IBAction func submit(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: DatePick.date)
        
        // NOTE -- selectedDate comes up in the format above: 2017-05-15, for example
        
        print(selectedDate)
        print(seekBar1.currentAngle)
    }
    
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
