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
    var startNight: Resource { return resource("api/v1/startnight/") }
    var addDrinks: Resource { return resource("api/v1/adddrinks/") }
    var addLoc: Resource { return resource("api/v1/addloc/iOS/") }
    var getHistory: Resource { return resource("api/v1/gethistory/") }
    var getLastNight: Resource { return resource("api/v1/getnight/") }
    
    var safetyAlert: Resource { return resource("api/v1/sendTextiOS/") }
}

