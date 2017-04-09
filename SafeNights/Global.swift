//
//  Global.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/9/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//


// This class holds any global variables that will be needed across views. Currently just holds username

class Main {
    var username:String
    var password:String
    var nightID:String
    init(username:String, password:String, nightID:String) {
        self.username = username
        self.password = password
        self.nightID = nightID
    }
}

//Not sure if nightID should be given an initial value 
var mainInstance = Main(username:"user", password:"pwd", nightID:"")
