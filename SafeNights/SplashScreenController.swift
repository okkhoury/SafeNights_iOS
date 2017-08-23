//
//  SplashScreenController.swift
//  SafeNights
//
//  Created by Zachary Skemp on 8/11/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class SplashScreenController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        let preferences = UserDefaults.standard
        
        let tutorialKey = "Tutorial"
        let loginKey = "Login"
        
        if (preferences.object(forKey: tutorialKey) == nil) {
            //First time user
            _ = preferences.set("Complete", forKey: tutorialKey)
            performSegue(withIdentifier: "TutorialSegue", sender: self)
        } else if (preferences.object(forKey: loginKey) == nil)  {
            //  Doesn't exist
            performSegue(withIdentifier: "LoginSegue", sender: self)
        } else {
            //Already has login information
            performSegue(withIdentifier: "HomeSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeSegue" {
            _ = segue.destination as? GetStartedController
        }
        if segue.identifier == "LoginSegue" {
            _ = segue.destination as? LoginController
        }
        if segue.identifier == "TutorialSegue" {
            _ = segue.destination as? TutorialController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

