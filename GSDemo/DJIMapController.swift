//
//  DJIMapController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 04/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit
import MapKit

class DJIMapController: NSObject {
    
    
    
    //MARK: VARs
    //var editPoints: [AnyHashable]?
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    
    
    //MARK: Functions
    
    // Init a DJIMapController instance and create editPoints array
    override init() {
        super.init()
        //editPoints = [AnyHashable]()
    }
    
    // Ad waypoints in Map
    /*func addPoint(_ point: CGPoint, with mapView: MKMapView?){
        let coodinate: CLLocationCoordinate2D = ((mapView?.convert(point, toCoordinateFrom: mapView) ?? nil)!)
        let location: CLLocation = CLLocation(latitude: coodinate.latitude, longitude: coodinate.longitude)
        
        editPoints?.append(location)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView?.addAnnotation(annotation)
        
    }*/
    
    
    // Clean all waypoints in Map
    /*func cleanAllPointsWithMapView(with mapView: MKMapView?){
        //editPoints?.removeAll()
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        for i in 0..<annos.count{
            weak var ann = annos[i] as? MKAnnotation
            if (!(ann!.isEqual(self.aircraftAnnotation))){
                mapView?.removeAnnotation(ann!)
            }
        }
    }*/
    
    // Return NSArray contains multiple CCLocation objects
    /*func wayPoints()->NSArray?{
        return self.editPoints as NSArray?
    }*/
    
    
    // Update Aircraft´s location in Map View
    func updateAircraftLocation(location: CLLocationCoordinate2D, withMapView mapView: MKMapView?){
        //let locatione = location as? CLLocation
        
        if(aircraftAnnotation != nil){
            aircraftAnnotation!.setCoordinate(location)
            /*NSLog(String(location.latitude))
            NSLog("\n")*/
        }
        else{
            self.aircraftAnnotation = DJIAircraftAnnotation.init(coordinate: location)
            mapView?.addAnnotation(self.aircraftAnnotation!)
        }
        /*NSLog("Latitud: ")
        NSLog(String(location.latitude))
        NSLog("\n")
        
        NSLog("Longitud: ")
        NSLog(String(location.longitude))
        NSLog("\n")*/
        
    }
    
    func updateAicraftHeading(heading: Float){
        if(aircraftAnnotation != nil){
            aircraftAnnotation!.updateHeading(heading: heading)
        }
        
    }
    
    func getAircraftAnno()-> DJIAircraftAnnotation?{
        return aircraftAnnotation
    }
    
    
    
}
