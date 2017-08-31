//
//  AddDrinksController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

protocol VcDelegate {
    func valueChanged(value: Float)
}

class AddDrinksController: UIViewController, CircularSeekerDelegate, UITextFieldDelegate {
    
   // @IBOutlet var DatePick: UIDatePicker!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var moneySlider: UISlider!
    @IBOutlet var moneyLabel: UILabel!
    
    @IBOutlet weak var beerLabel: UILabel!
    @IBOutlet weak var wineLabel: UILabel!
    @IBOutlet weak var mixedLabel: UILabel!
    @IBOutlet weak var liquorLabel: UILabel!
    
    @IBOutlet weak var calendarBackgroundView: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    var popDatePicker : PopDatePicker?
    
    let seekBar1 = CircularSeeker()
    let seekBar2 = CircularSeeker()
    let seekBar3 = CircularSeeker()
    let seekBar4 = CircularSeeker()
    
    let API = MyAPI()
    let preferences = UserDefaults.standard
    
    var selectedDate = "yyyy-MM-dd"
    let date = NSDate()
    let calendar = NSCalendar.current
    
    @IBAction func sliderMoved(_ sender: Any) {
        // Get value from Slider when it is moved.
        let value = Int(moneySlider.value)
        
        // Assign text to string representation of float.
        moneyLabel.text = "Money Spent: $" + String(value)
    }
    
    // TODO: Figure out way to not hardcode these positions.
    // or use different UI element. 
    
    // This function is putting the circularSeekers on the interface
    override func viewDidLoad() {
        //Date Logic
        let today = Date()
        selectedDate = dateToString(day: today)!
        dateTextField.text = dateToString_Short(day: today)!
        
        //Send View To Be Background for Calendar Pic
        view.sendSubview(toBack: calendarBackgroundView)
        
        //Beer
        seekBar1.frame = CGRect(x: (self.view.frame.size.width) * 0.1,
                                y: (self.view.frame.size.height) * 0.4,
                                width: (self.view.frame.size.width) * 0.3,
                                height: (self.view.frame.size.width) * 0.3)
        seekBar1.startAngle = 120
        seekBar1.endAngle = 60
        seekBar1.currentAngle = 120
        seekBar1.delegate = self
        self.view.addSubview(seekBar1)
        
        //Wine
        seekBar2.frame = CGRect(x: (self.view.frame.size.width) * 0.6,
                                y: (self.view.frame.size.height) * 0.4,
                                width: (self.view.frame.size.width) * 0.3,
                                height: (self.view.frame.size.width) * 0.3)
        seekBar2.startAngle = 120
        seekBar2.endAngle = 60
        seekBar2.currentAngle = 120
        seekBar2.delegate = self
        self.view.addSubview(seekBar2)
        
        //Liquor
        seekBar3.frame = CGRect(x: (self.view.frame.size.width) * 0.1,
                                y: (self.view.frame.size.height) * 0.6,
                                width: (self.view.frame.size.width) * 0.3,
                                height: (self.view.frame.size.width) * 0.3)
        seekBar3.startAngle = 120
        seekBar3.endAngle = 60
        seekBar3.currentAngle = 120
        seekBar3.delegate = self
        self.view.addSubview(seekBar3)
        
        //Mixed Drinks
        seekBar4.frame = CGRect(x: (self.view.frame.size.width) * 0.6,
                                y: (self.view.frame.size.height) * 0.6,
                                width: (self.view.frame.size.width) * 0.3,
                                height: (self.view.frame.size.width) * 0.3)
        seekBar4.startAngle = 120
        seekBar4.endAngle = 60
        seekBar4.currentAngle = 120
        seekBar4.delegate = self
        self.view.addSubview(seekBar4)
        
        // Change slider color to the theme accent
        moneySlider.tintColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0)
        
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        
        //Style Submit Button
        submitButton.layer.borderColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 2.0
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField === dateTextField) {
            //Resign fist responder so keyboard doesn't appear
            dateTextField.resignFirstResponder()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let initDate : Date? = formatter.date(from: dateTextField.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                // Update Global Var to new date
                self.selectedDate = (self.dateToString(day: newDate) ?? "?") as String
                // Update UI
                forTextField.text = (self.dateToString_Short(day: newDate) ?? "?") as String
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    func dateToString(day : Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: day)
    }
    
    func dateToString_Short(day : Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: day)
    }
    
    @IBAction func submit(_ sender: Any) {
        // Siesta requires the post requests data to all be strings
        let beerAmount = String(calculateNumberOfDrinks(angle: seekBar1.currentAngle))
        let wineAmount = String(calculateNumberOfDrinks(angle: seekBar2.currentAngle))
        let liquorAmount = String(calculateNumberOfDrinks(angle: seekBar3.currentAngle))
        let shotsAmount = String(calculateNumberOfDrinks(angle: seekBar4.currentAngle))
        let moneyAmount = String(Int(moneySlider.value))
        
        // Get the API for adding drinks
        let API = MyAPI()
        let resource = API.addDrinks
        
        // Get the global values for username and password
        let username = self.preferences.string(forKey: "username")!
        let password = self.preferences.string(forKey: "password")!
        
        // The data to be entered into the database
        // NOTE -- selectedDate comes up in the format above: 2017-05-15, for example
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
                // Send them to history
                self.tabBarController?.selectedIndex = 2
            } else {
                print("Drinks not added")
                //Display Error
                let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                    print("There was an error. User recognized")
                }
                let alert = UIAlertController(title: "Error", message: "There was a problem uploading your drink recording. Please make sure you have internet access", preferredStyle: .alert)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
            }
        }.onFailure { _ in
            // Display alert to screen to let user know error
            let OKAction = UIAlertAction(title: "Ok", style: .default){ (action:UIAlertAction) in
                print("Request failed")
            }
            let alert = UIAlertController(title: "Warning", message: "Something went wrong :( Make sure you have internet access", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func circularSeeker(_ seeker: CircularSeeker, didChangeValue value: Float) {
        beerLabel.text = String(calculateNumberOfDrinks(angle: seekBar1.currentAngle))
        wineLabel.text = String(calculateNumberOfDrinks(angle: seekBar2.currentAngle))
        liquorLabel.text = String(calculateNumberOfDrinks(angle: seekBar3.currentAngle))
        mixedLabel.text = String(calculateNumberOfDrinks(angle: seekBar4.currentAngle))
    }
    
    func calculateNumberOfDrinks(angle: Float) -> Int {
        if angle < 120 {
            return (8 + Int(angle/30.0))
        } else {
            return (Int((angle-120.0)/30.0))
        }
    }
}
