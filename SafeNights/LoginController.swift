//
//  LoginController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

/**
 * Controller for the user login page.
 */
class LoginController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    /** Text field where user enters username. */
    @IBOutlet var username: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    /** Text field where user enters password. */
    @IBOutlet var password: UITextField!
    
    /** Indicator that appears when user hits login. */
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /** button used clicked to attempt to login. */
    @IBOutlet var submitButton: UIButton!
    /** button used to go to the signup page. */
    @IBOutlet var registerButton: UIButton!
    
    let preferences = UserDefaults.standard
    let loginKey = "Login"
    let API = MyAPI()
    
    /**
     * When user clicks submit send post request of username and
     * password. Allow access if response does not equal 'n'.
     */
    @IBAction func Login(_ sender: Any) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        let resource = API.signin
        let usernameStr = self.username.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordStr = self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let postData = ["username": usernameStr, "pwd": passwordStr]
        resource.request(.post, urlEncoded: postData as! [String : String] ).onSuccess() { data in
            
            var response = data.jsonDict
            let loginAnswer = response["passed"]
            
            if let loginAnswer = loginAnswer as? String, loginAnswer != "n"{

                let names = loginAnswer.components(separatedBy: ",")
                let fname = names[0]
                let lname = names[1]
                
                mainInstance.username = self.username.text!
                mainInstance.password = self.password.text!
                _ = self.preferences.set(fname, forKey: "fname")
                _ = self.preferences.set(lname, forKey: "lname")
                
                _ = self.preferences.set("Logged In", forKey: self.loginKey)
                
                //  Save to disk
                self.preferences.synchronize()
                //  Stop loading animation
                self.loadingIndicator.stopAnimating()
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Permission Denied")
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate = self
        password.delegate = self
        
        // Makes keyboard go away when click off
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        usernameLabel.isHidden = true
        passwordLabel.isHidden = true
        loadingIndicator.isHidden = true
        
        submitButton.layer.borderColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 2.0
    }
    
    /** Used to create underline for textfields */
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x:0, y: username.frame.size.height - width, width: username.frame.size.width, height: username.frame.size.height)
        let border2 = CALayer()
        border2.borderColor = UIColor.white.cgColor
        border2.frame = CGRect(x:0, y: password.frame.size.height - width, width: password.frame.size.width, height: password.frame.size.height)
        border.borderWidth = width
        border2.borderWidth = width
        
        username.layer.addSublayer(border)
        username.layer.masksToBounds = true
        password.layer.addSublayer(border2)
        password.layer.masksToBounds = true
    }
    
    /** Shows the labels above the textfields and removes placeholder */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.username:
            self.usernameLabel.isHidden = false
            self.username.placeholder = ""
        default:
            self.passwordLabel.isHidden = false
            self.password.placeholder = ""
        }
    }
    
    /** Checks on finishing editing to see if anything has been entered. 
     * If nothing was entered, returns to how screen first rendered
     * If something was then does nothing, we like it this way */
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.username:
            if self.username.text == "" {
                self.usernameLabel.isHidden = true
                self.username.placeholder = "Username"
            }
        default:
            if self.password.text == "" {
                self.passwordLabel.isHidden = true
                self.password.placeholder = "Password"
            }
        }
    }
}
    
   
    
    

