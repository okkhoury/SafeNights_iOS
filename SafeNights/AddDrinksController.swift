//
//  AddDrinksController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/7/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

class AddDrinksController: UIViewController {
    
    @IBOutlet var MoneyTextEdit: UITextField!
    @IBOutlet var ShotsTextEdit: UITextField!
    @IBOutlet var LiquerTextEdit: UITextField!
    @IBOutlet var WineTextEdit: UITextField!
    @IBOutlet var BeerTextEdit: UITextField!
    
    @IBOutlet var SubmitButton: UIButton!
    
    let API = MyAPI()
    
    @IBAction func clickCreateAccount(_ sender: Any) {
        let resource = API.addDrinks
        
        let beerAmount = BeerTextEdit.text
        
        
        
    }
}
