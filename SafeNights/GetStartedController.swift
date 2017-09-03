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
import CZPicker

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
    let locationManager = CLLocationManager()
    
    // Global Var
    var nightHasStarted : Bool = false
    var destinationAddress : String = ""
    var destinationLatitude : Double = 0.0
    var destinationLongitude : Double = 0.0
    var contactNames : [String] = []
    var contactNumbers = [String]()
    
    var storedLocationNames = [String]()
    var storedLocations = [String]()
    var storedCoordinates = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Style Submit Button
        submitButton.layer.borderColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 2.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        storedLocationNames = self.preferences.value(forKey:"storedLocationNames") as! [String]
        storedLocations = self.preferences.value(forKey:"storedLocations") as! [String]
        storedCoordinates = self.preferences.value(forKey: "storedCoordinates") as! [Double]
    }

    //MARK:- CNContactPickerDelegate Method
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        self.contactNames.removeAll()
        self.contactNumbers.removeAll()
        var newTitle : String = ""
        contacts.forEach { contact in
            let contactName = contact.givenName
            var contactNumber = ""
            var foundMobile = false
            for number in contact.phoneNumbers {
                if(!foundMobile) {
                    contactNumber = (number.value).stringValue
                }
                if number.label == CNLabelPhoneNumberMobile {
                    contactNumber = (number.value).stringValue
                    foundMobile = true
                }
            }
            if contactNumber != "" {
                //Build the string to change the label
                if( newTitle == "") {
                    newTitle += contactName
                } else {
                    newTitle += ", " + contactName
                }
                self.contactNames.append(contactName)
                self.contactNumbers.append(contactNumber)
            }
        }
        self.contactButton.setTitle(newTitle, for: .normal)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    // Pick place starts GMSPlacePicker
    @IBAction func pickPlace(_ sender: Any) {
        let picker = CZPickerView(headerTitle: "Strongholds", cancelButtonTitle: "Add New", confirmButtonTitle: "Select")
        picker?.delegate = self
        picker?.dataSource = self
        picker?.headerBackgroundColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0)
        picker?.confirmButtonBackgroundColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0)
        picker?.cancelButtonNormalColor = UIColor.black
        picker?.needFooterView = true
        picker?.show()
    }
    
    func startPlacePicker() {
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
        if(CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedAlways) {
            if(!(self.destinationAddress == "" || self.destinationLongitude == 0.0 || self.destinationLatitude == 0.0 || self.contactNames.count == 0 || contactNames.isEmpty)) {
                if(!nightHasStarted) {
                    // Disable button so they can't spam nights
                    self.submitButton.isEnabled = false
                    
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
                            self.preferences.set("Home", forKey: "currentAddress")
                            self.sendTextToGuardians()

                            self.trackingLocation.performBackgroundTask()
                            
                            self.submitButton.setTitle("FINISH", for: .normal)
                            self.submitButton.titleLabel?.textAlignment = NSTextAlignment.center
                            self.startAdventureLabel.text = "You're On Your Way!"
                            self.nightHasStarted = true
                            // Disable button so user can't be stupid
                            self.contactButton.isEnabled = false
                            self.placeButton.isEnabled = false
                            
                            // Re-enable button so they can end/restart night
                            self.submitButton.isEnabled = true
                        }
                        else if let startNightAnswer = startNightAnswer as? String, startNightAnswer == "n" {
                            // Display alert to screen to let user know error
                            let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                                print("night has not started")
                            }
                            let alert = UIAlertController(title: "Error", message: "There was an error starting your night! Please try again :)", preferredStyle: .alert)
                            alert.addAction(OKAction)
                            self.present(alert, animated: true, completion: nil)
                            
                            // Re-enable button so they can end/restart night
                            self.submitButton.isEnabled = true
                        }
                    }.onFailure { _ in
                            // Display alert to screen to let user know error
                            let OKAction = UIAlertAction(title: "Ok", style: .default){ (action:UIAlertAction) in
                                print("Request failed")
                            }
                            let alert = UIAlertController(title: "Warning", message: "Something went wrong! :( Make sure you have internet access", preferredStyle: .alert)
                            alert.addAction(OKAction)
                            self.present(alert, animated: true, completion: nil)
                        
                            // Re-enable button so they can end/restart night
                            self.submitButton.isEnabled = true
                    }
                } else {
                    // Flip Bool
                    self.nightHasStarted = false
                    
                    // Enable buttons
                    self.contactButton.isEnabled = true
                    self.placeButton.isEnabled = true
                    
                    // Clear Labels
                    self.submitButton.setTitle("SET OFF", for: .normal)
                    self.submitButton.titleLabel?.textAlignment = NSTextAlignment.center
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
                    
                    // Let guardians know that user made it back home
                    self.preferences.set("1", forKey: "messageType")
                    self.sendTextToGuardians()
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
        } else {
            // Request User Location Permissions
            self.locationManager.requestAlwaysAuthorization()
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
        }.onFailure { _ in
            
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
        
        // Set Global Variables
        self.destinationAddress = place.formattedAddress!
        self.destinationLatitude = place.coordinate.latitude
        self.destinationLongitude = place.coordinate.longitude
        
        self.placeButton.setTitle(place.name, for: .normal)
        
        // Add to storedLocations and save to sharedprefs
        storedCoordinates.append(place.coordinate.latitude)
        storedCoordinates.append(place.coordinate.longitude)
        storedLocations.append(place.formattedAddress!)
        storedLocationNames.append(place.name)
        self.preferences.set(storedLocationNames, forKey: "storedLocationNames")
        self.preferences.set(storedLocations, forKey: "storedLocations")
        self.preferences.set(storedCoordinates, forKey: "storedCoordinates")
        
//        print("Place name \(place.name)")
//        print("Place address \(place.formattedAddress)")
//        print("Place attributions \(place.attributions)")
//        print("Place attributions \(place.coordinate)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}

extension GetStartedController: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        return nil
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return storedLocationNames.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return storedLocationNames[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print(storedLocationNames[row])
        // Set Global Variables
        self.destinationAddress = storedLocations[row]
        self.destinationLatitude = storedCoordinates[row*2]
        self.destinationLongitude = storedCoordinates[(row*2)+1]
        
        print(self.destinationAddress)
        print(self.destinationLatitude)
        print(self.destinationLongitude)
        
        self.placeButton.setTitle(storedLocationNames[row], for: .normal)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        // Start Google Place Picker
        startPlacePicker()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if let row = row as? Int {
                print(storedLocationNames[row])
            }
        }
    }
}
