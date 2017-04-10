//
//  Global.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/9/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//


// This class holds any global variables that will be needed across views. Currently just holds username
import MapKit

class Main {
    var username:String
    var password:String
    var nightID:String
    var latitude:CLLocationDegrees
    var longitude:CLLocationDegrees
    
    init(username:String, password:String, nightID:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        self.username = username
        self.password = password
        self.nightID = nightID
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

//Not sure if nightID should be given an initial value 
var mainInstance = Main(username:"user", password:"pwd", nightID:"", latitude:0, longitude:0)

