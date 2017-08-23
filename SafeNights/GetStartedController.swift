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
    @IBOutlet weak var placeButton: UIButton!
    
    
    @IBOutlet weak var contactButton: UIButton!
    
    /** Submits contact and location info. */
    @IBOutlet var submitButton: UIButton!
    
    let trackingLocation = TrackingLocation()
    
    let API = MyAPI()
    let preferences = UserDefaults.standard
    
    // Global Var
    var destinationAddress : String = ""
    var destinationLatitude : Double = 0.0
    var destinationLongitude : Double = 0.0
    var contactNames : [String] = []
    var contactNumbers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Style Submit Button
        submitButton.layer.borderColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 2.0
    }

    //MARK:- CNContactPickerDelegate Method
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        self.contactNames.removeAll()
        self.contactNumbers.removeAll()
        var newTitle : String = ""
        contacts.forEach { contact in
            for number in contact.phoneNumbers {
                let contactName = contact.givenName
                let contactNumber = (number.value).stringValue
                if number.label == CNLabelPhoneNumberMobile {
                    self.contactNames.append(contactName)
                    self.contactNumbers.append(contactNumber)
                    //Build the string to change the label
                    if( newTitle == "") {
                        newTitle += contactName
                    } else {
                        newTitle += ", " + contactName
                    }
                }
            }
        }
        self.contactButton.setTitle(newTitle, for: .normal)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    // Pick place starts GMSPlacePicker
    @IBAction func pickPlace(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
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
        // Get the global values for username and password
        let username = self.preferences.string(forKey: "username")!
        let password = self.preferences.string(forKey: "password")!
        
        // Set global values for the service to use
        _ = self.preferences.set(destinationAddress, forKey: "finalAddress")
        _ = self.preferences.set(destinationLatitude, forKey: "finalLatitude")
        _ = self.preferences.set(destinationLongitude, forKey: "finalLongitude")
        _ = self.preferences.set(contactNames, forKey: "contactNames")
        _ = self.preferences.set(contactNumbers, forKey: "contactNumbers")
        
        print(destinationAddress)
        print(destinationLatitude)
        print(destinationLongitude)
        print(contactNames)
        print(contactNumbers)
        
        let resource = API.startNight
        let postData = ["username": username, "pwd": password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            var response = data.jsonDict
            let startNightAnswer = response["passed"]
            
            if let startNightAnswer = startNightAnswer as? String, startNightAnswer != "n" {
                print(startNightAnswer)
                _ = self.preferences.set(startNightAnswer, forKey: "adventureID")

                self.trackingLocation.performBackgroundTask()
            }
            else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                print("night has not started")
            }
        }
    }
}

extension GetStartedController: GMSPlacePickerViewControllerDelegate {
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        self.destinationAddress = place.formattedAddress!
        self.destinationLatitude = place.coordinate.latitude
        self.destinationLongitude = place.coordinate.longitude
        
        self.placeButton.setTitle(place.name, for: .normal)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
        print("Place attributions \(place.coordinate)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}
