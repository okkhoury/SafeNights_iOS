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
    @IBOutlet var moneySlider: UISlider!
    @IBOutlet var moneyLabel: UILabel!
    
    let seekBar1 = CircularSeeker()
    let seekBar2 = CircularSeeker()
    let seekBar3 = CircularSeeker()
    let seekBar4 = CircularSeeker()
    
    let API = MyAPI()
    
    let username = mainInstance.username
    let password = mainInstance.password
    
    let date = NSDate()
    let calendar = NSCalendar.current
    
    @IBAction func sliderMoved(_ sender: Any) {
        // Get value from Slider when it is moved.
        let value = Int(moneySlider.value)
        
        // Assign text to string representation of float.
        moneyLabel.text = "Money Spent: $" + String(value)
    }
    
    
    // This function is putting the circularSeekers on the interface
    override func viewDidLoad() {
        //Wine
        seekBar1.frame = CGRect(x: 40, y: 355, width: 75, height: 75)
        seekBar1.startAngle = 120
        seekBar1.endAngle = 60
        seekBar1.currentAngle = 120
        seekBar1.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar1)
        
        //Beer
        seekBar2.frame = CGRect(x: 260, y: 355, width: 75, height: 75)
        seekBar2.startAngle = 120
        seekBar2.endAngle = 60
        seekBar2.currentAngle = 120
        seekBar2.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar2)
        
        //Liquor
        seekBar3.frame = CGRect(x: 40, y: 465, width: 75, height: 75)
        seekBar3.startAngle = 120
        seekBar3.endAngle = 60
        seekBar3.currentAngle = 120
        seekBar3.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar3)
        
        //Shots
        seekBar4.frame = CGRect(x: 260, y: 465, width: 75, height: 75)
        seekBar4.startAngle = 120
        seekBar4.endAngle = 60
        seekBar4.currentAngle = 120
        seekBar4.addTarget(self, action: Selector(("seekBarDidChangeValue:")), for: .valueChanged)
        self.view.addSubview(seekBar4)
        
        // Change the text color of the datePicker to white
        DatePick.setValue(UIColor.white, forKeyPath: "textColor")

    }
    
    
    @IBAction func submit(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: DatePick.date)
        
        // NOTE -- selectedDate comes up in the format above: 2017-05-15, for example
        
        print(selectedDate)
        print(seekBar1.currentAngle)
        
        // Siesta requires the post requests data to all be strings
        let wineAmount = String(Int(seekBar1.currentAngle))
        let beerAmount = String(Int(seekBar2.currentAngle))
        let liquorAmount = String(Int(seekBar3.currentAngle))
        let shotsAmount = String(Int(seekBar4.currentAngle))
        let moneyAmount = String(Int(moneySlider.value))
        
        // Get the API for adding drinks
        let API = MyAPI()
        let resource = API.addDrinks
        
        // Get the global values for username and password
        let username = mainInstance.username
        let password = mainInstance.password
        
        // The data to be entered into the database
        let postData = ["username":username, "pwd":password, "day": selectedDate,
                        "money": moneyAmount,"shots": shotsAmount, "liquor":liquorAmount,
                        "wine": wineAmount, "beer": beerAmount] as [String : Any]
        
        
        resource.request(.post, urlEncoded: postData as! [String : String]).onSuccess() { data in
            
            // Get the response from the user in the form ["passed": 'y'/'n']
            var response = data.jsonDict
            let responseAnswer = response["passed"]
            
            // check if the data was correctly added
            if let responseAnswer = responseAnswer as? String, responseAnswer == "y" {
                print("Drinks added")
            } else {
                print("Drinks not added")
            }
            
        }
    }
}
