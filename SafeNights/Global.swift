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
    init(username:String) {
        self.username = username
    }
}
var mainInstance = Main(username:"user")
