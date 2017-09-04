//
//  LastNightController.swift
//  SafeNights
//
//  Created by Zachary Skemp on 8/16/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import GoogleMaps

class LastNightController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var viewMap: GMSMapView!
    
    let API = MyAPI()
    let preferences = UserDefaults.standard
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apikey = "AIzaSyAvgr7MEpW6tAr_FpWPrdGwJL1_jSxbYbk"
    
    var allData : [LocFields] = []
    var timesArray: [String] = []
    var markersArray: Array<GMSMarker> = []
    var routePolyline: GMSPolyline!
    
    var tmpLat : String = ""
    var tmpLon : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        // Do any additional setup after the view appears
        // Style the map
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.viewMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        // Call API
        callLastNightAPI()
    }
    
    func setUpMap(mapView: GMSMapView!) {
        // Location Coordinate for later
        var lastLat : Double = 0.0
        var lastLon : Double = 0.0
        
        for loc in allData {
            var time : String = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let index = loc.time!.index(loc.time!.startIndex, offsetBy: (loc.time!.characters.count-5))
            if let checkDate = dateFormatter.date(from: loc.time!.substring(to: index)) {
                let date = checkDate
                let newFormat = DateFormatter()
                newFormat.dateFormat = "HH:mm"
                dateFormatter.timeZone = TimeZone.current
                time = newFormat.string(from: date)
            } else {
                time = "?"
                //print("Could not parse")
            }
            
            let lat = Double(loc.xcord!)
            let lon = Double(loc.ycord!)
            
            // Get the actual location address
            //GEOCODER
            self.tmpLat = loc.xcord!
            self.tmpLon = loc.ycord!
            var address : String = "?"
            getAddress() { (returnAddress) in
                address = "\(returnAddress)"
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                marker.title = address
                marker.snippet = time
                marker.icon = GMSMarker.markerImage(with: UIColor(red: 86/225, green: 197/225, blue: 239/255, alpha: 1.0))
                marker.map = mapView
                
                self.timesArray.append(time)
                self.markersArray.append(marker)
                // POLYLINE, add location
            }
            // Update lastLat and lastLon for camera at end
            lastLat = lat!
            lastLon = lon!
        }
        
        // Color Polyline
        // Add to map
        // THIS IS AN INSANE AMOUNT OF WORK... WHY :(
        
        
        //Move Camera
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lastLat, longitude: lastLon, zoom: 11.5)
        viewMap.camera = camera
    }
    
    func getAddress(currentAdd : @escaping ( _ returnAddress :String)->Void){
        let geocoder = GMSGeocoder()
        let coordinate = CLLocationCoordinate2DMake(Double(self.tmpLat)!,Double(self.tmpLon)!)
        
        var currentAddress = String()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                
                currentAddress = lines[0]
                currentAdd(currentAddress)
            }
        }
    }
    
    func callLastNightAPI() {
        let resource = API.getLastNight
        
        // Get the global values for username and password
        let username = self.preferences.string(forKey: "username")!
        let password = self.preferences.string(forKey: "password")!
        let adventureID = self.preferences.string(forKey: "adventureID") ?? ""
        
        let postData = ["username": username,
                        "pwd": password, "id": adventureID]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            
            var response = data.jsonDict
            let answer = response["locationtable"] as! NSArray!
          
            let arr = Locationtable.modelsFromDictionaryArray(array: answer!)
            
            for item in arr {
                self.allData.append(item.fields!)
            }
            self.setUpMap(mapView: self.viewMap)
            
        }.onFailure { _ in
            
        }
    }
}
