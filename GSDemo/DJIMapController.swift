//
//  DJIMapController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 04/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

// Clase que hace de interfaz entre ViewController y MKView

import UIKit
import MapKit

class DJIMapControler: NSObject {
    
    
    
    //MARK: VARs
    var editPoints: [AnyHashable]?
    var auxPoints: [CLLocationCoordinate2D]?
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    
    
    //MARK: Functions
    
    // Init a DJIMapController instance and create editPoints array
    override init() {
        super.init()
        editPoints = [AnyHashable]()
        auxPoints = [CLLocationCoordinate2D]()
    }
    
    // Obtiene por parametro un CGPoint
    // introduce las Locations en la array editPoints y agrega un Annotaion al mapView
    func addPoint(_ point: CGPoint, with mapView: MKMapView?){
        
        // Pasamos de CGPoints a Coordinate y a Location
        let coodinate: CLLocationCoordinate2D = ((mapView?.convert(point, toCoordinateFrom: mapView) ?? nil)!)
        let location: CLLocation = CLLocation(latitude: coodinate.latitude, longitude: coodinate.longitude)
        
        auxPoints?.append(coodinate)
        
        
        editPoints?.append(location)
        
        
        // agregamos un Annotation con las coordenadas de CGPoint
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView?.addAnnotation(annotation)
        
    }
    
    
    // Vacia editPoints, recorre y borra todas las Annotations
    func cleanAllPointsWithMapView(with mapView: MKMapView?){
        editPoints?.removeAll()
        auxPoints?.removeAll()
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        for i in 0..<annos.count{
            weak var ann = annos[i] as? MKAnnotation
            if (!(ann!.isEqual(self.aircraftAnnotation))){
                mapView?.removeAnnotation(ann!)
            }
        }
    }
    
    // Return NSArray contains multiple CCLocation objects
    func wayPoints()->NSArray?{
        return self.editPoints as NSArray?
    }
    
    func auxwayPoints()->[CLLocationCoordinate2D]?{
        return auxPoints
    }
    
    
    // Update Aircraft´s location in Map View
    func updateAircraftLocation(location: CLLocationCoordinate2D, withMapView mapView: MKMapView?){
        
        if(aircraftAnnotation != nil){
            aircraftAnnotation!.setCoordinate(location)
        }
        else{
            self.aircraftAnnotation = DJIAircraftAnnotation.init(coordinate: location)
            mapView?.addAnnotation(self.aircraftAnnotation!)
        }
        
    }
    
    func updateAicraftHeading(heading: Float){
        if(aircraftAnnotation != nil){
            aircraftAnnotation!.updateHeading(heading: heading)
        }
        
    }
    
    
    
}
