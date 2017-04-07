//
//  MyAPI.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/6/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import Siesta

class MyAPI: Service {
    
    
    
    
    init() {
        super.init(baseURL: "https://gentle-badlands-54918.herokuapp.com/")
    }
    
    var signin: Resource { return resource("api/v1/signin/") }
    var signup:  Resource { return resource("api/v1/signup/") }
    
    
    // I dont think this function is doing anything
    
//    func item(id: String) -> Resource {
//        return items.child(id)
//    }
}

