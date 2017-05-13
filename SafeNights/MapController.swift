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
    
    var latitude = mainInstance.latitude
    var longitude = mainInstance.longitude
    
    var coordinateTimer: Timer!
    
   
    // Anytime the user comes back to this view, draw out the route they've taken
    override func viewDidLoad() {
        super.viewDidLoad()
        drawBetweenPoints(latStart: self.latitude, lonStart: self.longitude, latEnd: self.latitude - 0.01, lonEnd: self.longitude - 0.03)
        
       drawBetweenPoints(latStart: self.latitude - 0.01, lonStart: self.longitude - 0.03, latEnd: self.latitude + 0.05, lonEnd: self.longitude + 0.05)
    }
    
    
    
    func drawBetweenPoints(latStart:CLLocationDegrees, lonStart:CLLocationDegrees, latEnd:CLLocationDegrees, lonEnd:CLLocationDegrees) {
        mapView.delegate = self
        
        // Set the latitude and longtitude of the locations
        let sourceLocation = CLLocationCoordinate2D(latitude: latStart, longitude: lonStart)
        let destinationLocation = CLLocationCoordinate2D(latitude: latEnd - 0.01, longitude: lonEnd - 0.005)
        
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
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 6.0
        
        return renderer
    }
    
}
