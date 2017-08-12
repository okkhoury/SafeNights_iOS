//
//  RegisterController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/5/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

/**
 * Controller for the sign up page. Used to create a new user.
 */
class RegisterController: UIViewController, UITextFieldDelegate {

    /** Text field and Label where user enters their last name. */
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstName: UITextField!
    /** Text field where user enters their last name. */
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastName: UITextField!
    /** Text field where user enters their email. */
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var emailAddress: UITextField!
    /** Text field where user enters their username. */
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    /** Text field where user enters their password.  */
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    /** Attempts to create new user account when pressed.  */
    @IBOutlet var createAccountButton: UIButton!
    
    let API = MyAPI()
    
    /**
     * When user clicks submit send post request to try and
     * create a new user.
     */
    @IBAction func clickCreateAccount(_ sender: Any) {
        let resource = API.signup
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("I pressed Ok button and worked")
        }
        
        // Validate the text fields
        if (username.text?.characters.count)! == 0 {
            let alert = UIAlertController(title: "Invalid", message: "Username is required!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (username.text?.characters.count)! > 20 {
            let alert = UIAlertController(title: "Invalid", message: "Username must be less than 20 characters", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if validateUsername(enteredUsername: username.text!) {
            let alert = UIAlertController(title: "Invalid", message: "Username can only contain uppercase/lowercase letters and numbers 0-9!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (firstName.text?.characters.count)! == 0 {
            let alert = UIAlertController(title: "Invalid", message: "First name is required!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (firstName.text?.characters.count)! > 20 {
            let alert = UIAlertController(title: "Invalid", message: "Username must be less than 20 characters", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (lastName.text?.characters.count)! == 0 {
            let alert = UIAlertController(title: "Invalid", message: "Last name is required!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (lastName.text?.characters.count)! > 20 {
            let alert = UIAlertController(title: "Invalid", message: "Username must be less than 5 characters", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (password.text?.characters.count)! == 0 {
            let alert = UIAlertController(title: "Invalid", message: "Password is required!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (password.text?.characters.count)! < 6 {
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 5 characters", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else if (password.text?.characters.count)! > 20 {
            let alert = UIAlertController(title: "Invalid", message: "Password must be less than 5 characters", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
//******************** FIX THIS. EMAIL IS NOT WORKING CORRECTLY *******************************
        } else if validateEmail(enteredEmail: emailAddress.text!) {
            let alert = UIAlertController(title: "Invalid", message: "Email Address is Invalid!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let postData = ["username": username.text,
                            "email": emailAddress.text,
                            "pwd": password.text,
                            "fname": firstName.text,
                            "lname": lastName.text]
            
            resource.request(.post, urlEncoded: postData as! [String : String]).onSuccess() { data in
                
                var response = data.jsonDict
                let signupAnswer = response["passed"]
                
                if let signupAnswer = signupAnswer as? String, signupAnswer == "y" {
                    print("User added to database")
                    
                } else if let signupAnswer = signupAnswer as? String, signupAnswer == "n" {
                    print("User not added")
                }
            }
            // Go back to the login page regardless what happens (should change this later)
            performSegue(withIdentifier: "signupToLogin", sender: nil)
        }
    }
    
    func validateUsername(enteredUsername:String) -> Bool {
        let usernameFormat = "[A-Za-z0-9]"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameFormat)
        return usernamePredicate.evaluate(with:enteredUsername)
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with:enteredEmail)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firstName.delegate = self
        lastName.delegate = self
        emailAddress.delegate = self
        username.delegate = self
        password.delegate = self
        
        // Makes keyboard go away when click off
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        firstNameLabel.isHidden = true
        lastNameLabel.isHidden = true
        emailAddressLabel.isHidden = true
        usernameLabel.isHidden = true
        passwordLabel.isHidden = true
        
        createAccountButton.layer.borderColor = UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0).cgColor
        createAccountButton.layer.borderWidth = 2.0
    }
    
    /** Used to create underline for textfields */
    override func viewDidLayoutSubviews() {
        let width = CGFloat(2.0)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x:0, y: username.frame.size.height - width, width: username.frame.size.width, height: username.frame.size.height)
        let border2 = CALayer()
        border2.borderColor = UIColor.white.cgColor
        border2.frame = CGRect(x:0, y: password.frame.size.height - width, width: password.frame.size.width, height: password.frame.size.height)
        let border3 = CALayer()
        border3.borderColor = UIColor.white.cgColor
        border3.frame = CGRect(x:0, y: firstName.frame.size.height - width, width: firstName.frame.size.width, height: firstName.frame.size.height)
        let border4 = CALayer()
        border4.borderColor = UIColor.white.cgColor
        border4.frame = CGRect(x:0, y: lastName.frame.size.height - width, width: lastName.frame.size.width, height: lastName.frame.size.height)
        let border5 = CALayer()
        border5.borderColor = UIColor.white.cgColor
        border5.frame = CGRect(x:0, y: emailAddress.frame.size.height - width, width: emailAddress.frame.size.width, height: emailAddress.frame.size.height)
        
        border.borderWidth = width
        border2.borderWidth = width
        border3.borderWidth = width
        border4.borderWidth = width
        border5.borderWidth = width
        
        username.layer.addSublayer(border)
        username.layer.masksToBounds = true
        password.layer.addSublayer(border2)
        password.layer.masksToBounds = true
        firstName.layer.addSublayer(border3)
        firstName.layer.masksToBounds = true
        lastName.layer.addSublayer(border4)
        lastName.layer.masksToBounds = true
        emailAddress.layer.addSublayer(border5)
        emailAddress.layer.masksToBounds = true
    }
    
    /** Shows the labels above the textfields and removes placeholder */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.username:
            self.usernameLabel.isHidden = false
            self.username.placeholder = ""
        case self.firstName:
            self.firstNameLabel.isHidden = false
            self.firstName.placeholder = ""
        case self.lastName:
            self.lastNameLabel.isHidden = false
            self.lastName.placeholder = ""
        case self.emailAddress:
            self.emailAddressLabel.isHidden = false
            self.emailAddress.placeholder = ""
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
        case self.firstName:
            if self.firstName.text == "" {
                self.firstNameLabel.isHidden = true
                self.firstName.placeholder = "First Name"
            }
        case self.lastName:
            if self.lastName.text == "" {
                self.lastNameLabel.isHidden = true
                self.lastName.placeholder = "Last Name"
            }
        case self.emailAddress:
            if self.emailAddress.text == "" {
                self.emailAddressLabel.isHidden = true
                self.emailAddress.placeholder = "Email Address"
            }
        default:
            if self.password.text == "" {
                self.passwordLabel.isHidden = true
                self.password.placeholder = "Password"
            }
        }
    }
}
