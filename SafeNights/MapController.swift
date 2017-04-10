//
//  MapController.swift
//  SafeNights
//
//  Created by Owen Khoury on 4/9/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    let locManager = CLLocationManager()
    
    var latitude:CLLocationDegrees = 0
    var longitude:CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user's current latitude and longitude
        locManager.requestWhenInUseAuthorization()
        var currentLocation = CLLocation()
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
        
            currentLocation = locManager.location!
            
            self.latitude = currentLocation.coordinate.latitude
            self.longitude = currentLocation.coordinate.longitude
            
        }
        
        print(self.latitude)
        print(self.longitude)
        
        
        mapView.delegate = self
        
        // Set the latitude and longtitude of the locations
        let sourceLocation = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: 40.748441, longitude: -73.985564)
        
        // Create placemark objects containing the location's coordinates
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // MKMapitems are used for routing. This class encapsulates information about a specific point on the map
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // The MKDirectionsRequest class is used to compute the route
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    // This method return the renderer object which will be used to draw the route on the map. A red color is used with a line thickness of 4.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
        
        
//        let userLocationCoordinates = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
//        let pinForUserLocation = MKPointAnnotation()
//        pinForUserLocation.coordinate = userLocationCoordinates
//        mapView.addAnnotation(pinForUserLocation)
//        mapView.showAnnotations([pinForUserLocation], animated: true)
        
        //Zoom to user location
//        let noLocation = CLLocationCoordinate2D()
//        let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 200, 200)
//        mapView.setRegion(viewRegion, animated: false)
        
        
//        let locManager = CLLocationManager()
//        locManager.requestWhenInUseAuthorization()
//        
//        var currentLocation = CLLocation()
//        
//        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
//            
//            currentLocation = locManager.location!
//        }
//        
//        let latitude:CLLocationDegrees = currentLocation.coordinate.latitude
//        let longitude:CLLocationDegrees = currentLocation.coordinate.longitude
//        
//        let latDelta:CLLocationDegrees = 0.05
//        let lonDelta:CLLocationDegrees = 0.05
//        
//        let span = MKCoordinateSpanMake(latDelta, lonDelta)
//        
//        let location = CLLocationCoordinate2DMake(latitude, longitude)
//        
//        let region = MKCoordinateRegionMake(location, span)
//        
//        mapView.setRegion(region, animated: false)
        
    
}
