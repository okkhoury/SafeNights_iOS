//
//  GetStartedController.swift
//  SafeNights
//
//  Created by Owen Khoury on 5/13/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta
import ContactsUI
import GooglePlacePicker

class GetStartedController: UIViewController, CNContactPickerDelegate {
    
    /** The location you plan at which user plans to end night. */
    @IBOutlet var locationTextField: UITextField!
    
    /** Name of person to contact in case of emergency. */
    @IBOutlet var contactTextField: UITextField!
    
    @IBOutlet weak var contactButton: UIButton!
    /** Email of person to contact in case of emergency. */
    @IBOutlet var emailTextField: UITextField!
    
    /** Submits contact and location info. */
    @IBOutlet var submitButton: UIButton!
    
    let API = MyAPI()
    
    //MARK:- CNContactPickerDelegate Method
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach { contact in
            for number in contact.phoneNumbers {
                let phoneNumber = number.value
                print("number is = \(phoneNumber)")
            }
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    @IBAction func pickPlace(_ sender: Any) {
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        
//        present(placePicker, animated: true, completion: nil)
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePicker(config: config)
//        
//        placePicker.pickPlace(callback: {(place, error) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let place = place {
//                print(place.name)
//                print(place.formattedAddress?.components(separatedBy: ", ")
//                    .joined(separator: "\n"))
//            } else {
//                print("No place selected")
//                print("")
//            }
//        })
    }
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    @IBAction func contactAction(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    
    /**
     * Clicking submit sends a post request of username and password
     * and returns an adventureID if they are valid.
     */
    @IBAction func submit(_ sender: Any) {
        let username = mainInstance.username
        let password = mainInstance.password
        
        let resource = API.startNight
        let postData = ["username": username, "pwd": password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            var response = data.jsonDict
            let startNightAnswer = response["passed"]
            
            if let startNightAnswer = startNightAnswer as? String, startNightAnswer != "n" {
                print(startNightAnswer)
                mainInstance.nightID = startNightAnswer
                
                mainInstance.performBackgroundTask()
            }
            else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                print("night has not started")
            }
        }
        
    }
}
