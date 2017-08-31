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
    @IBOutlet weak var startAdventureLabel: UILabel!
    
    /** The location you plan at which user plans to end night. */
    @IBOutlet weak var placeButton: UIButton!
    
    @IBOutlet weak var contactButton: UIButton!
    
    /** Submits contact and location info. */
    @IBOutlet var submitButton: UIButton!
    
    let trackingLocation = TrackingLocation()
    
    let API = MyAPI()
    let preferences = UserDefaults.standard
    
    // Global Var
    var nightHasStarted : Bool = false
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

        if(!(self.destinationAddress == "" || self.destinationLongitude == 0.0 || self.destinationLatitude == 0.0 || self.contactNames.count == 0 || contactNames.isEmpty)) {
            if(!nightHasStarted) {
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
                
                        // Let guardians know that user successfully started night
                        self.preferences.set("0", forKey: "messageType")
                        self.sendTextToGuardians();

                        self.trackingLocation.performBackgroundTask()
                        
                        self.submitButton.titleLabel?.text = "FINISH"
                        self.startAdventureLabel.text = "You're On Your Way!"
                        self.nightHasStarted = true
                    }
                    else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                        // Display alert to screen to let user know error
                        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                            print("night has not started")
                        }
                        let alert = UIAlertController(title: "Error", message: "There was an error starting your night! Please try again :)", preferredStyle: .alert)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                // Flip Bool
                self.nightHasStarted = false
                
                // Clear Labels
                self.submitButton.setTitle("SET OFF", for: .normal)
                self.startAdventureLabel.text = "Start Adventure!"
                self.placeButton.setTitle("My Strongholds", for: .normal)
                self.contactButton.setTitle("My Guardian Angels", for: .normal)
                
                // Clear Variables
                self.destinationAddress = ""
                self.destinationLatitude = 0.0
                self.destinationLongitude = 0.0
                self.contactNames.removeAll()
                self.contactNumbers.removeAll()
                
                stopBackgroundThreads()
            }
        } else {
            // Display alert to screen to let user know error
            let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                print("night has not started")
            }
            let alert = UIAlertController(title: "Warning", message: "You must give all fields before starting your night!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendTextToGuardians() -> Void {
        
        let messageType = self.preferences.value(forKey: "messageType")
        
        let contactNumbersArray = self.preferences.value(forKey: "contactNumbers") as! [String]
        let contactNumbers = contactNumbersArray.joined(separator: ",")
        let contactNamesArray = self.preferences.value(forKey: "contactNames") as! [String]
        let contactNames = contactNamesArray.joined(separator: ",")
        
        let username = self.preferences.value(forKey: "username")
        let password = self.preferences.value(forKey: "password")
        let firstName = self.preferences.value(forKey: "fname")
        let lastName = self.preferences.value(forKey: "lname")
        
        let adventureID = self.preferences.value(forKey: "adventureID")
        let finalAddress = self.preferences.value(forKey: "finalAddress")
        
        self.preferences.set("Home", forKey: "currentAddress")
        
        let currentAddress = self.preferences.value(forKey: "currentAddress")
        
        let postData = ["contactNumbers": contactNumbers, "contactNames": contactNames,
                        "username": username, "pwd": password, "fname": firstName,
                        "lname": lastName, "id": adventureID, "finalAddress": finalAddress,
                        "currentAddress": currentAddress, "messageType": messageType]
        
        print(postData)
        
        let resource = API.safetyAlert
        
        resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
            
            var response = data.jsonDict
            let loginAnswer = response["passed"]
            
            print("Response")
            print(response)
            
            if let loginAnswer = loginAnswer as? String, loginAnswer == "y" {
                print("successfully sent text.")
            }
            else {
                print("failed to send text.")
                
                // TODO: give user notification that text did not go through
            }
        }
    }
    
    func stopBackgroundThreads() {
        trackingLocation.stopBackgroundTask()
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
