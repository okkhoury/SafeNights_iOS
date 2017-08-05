//
//  HistoryController.swift
//  SafeNights
//
//  Created by Owen Khoury on 5/13/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta

/**
 * Controller for getting history of previous nights.
 * Currently just tests that controller can get previous night 
 * history from database.
 */
class HistoryController: UIViewController {
    
     let API = MyAPI()
    
    @IBOutlet weak var historyButton: UIButton!
    
    @IBAction func getHistory(_ sender: Any) {
        
        print(mainInstance.nightID)
        print(mainInstance.username)
        print(mainInstance.password)
        
        let resource = API.getHistory
        
        let postData = ["username": mainInstance.username,
                        "pwd": mainInstance.password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            //var response = data.jsonDict
            //let answer = response["passed"]
            
//            var json: Any?
//            do {
//                json = try JSONSerialization.jsonObject(with: data)
//            } catch {
//                print(error)
//            }
//            guard let item = json?.first as? [String: Any],
//                let person = item["person"] as? [String: Any],
//                let age = person["age"] as? Int else {
//                    return
//            }
            
        }
    }
}
