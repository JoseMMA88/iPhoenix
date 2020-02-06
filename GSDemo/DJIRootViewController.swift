//
//  DJIRootViewController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 03/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import DJISDK
import MapKit
import UIKit
import CoreLocation

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate{
    
    //MARK: Vars
    var mapController: DJIMapControler?
    var isEditingPoints: Bool = false
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D!
    
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var editBtn: UIButton!
    
    
    //MARK: View Controller functions
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.registerApp()
        
        userLocation = kCLLocationCoordinate2DInvalid
        
        mapController = DJIMapControler()
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        
        
        //TODO: self.initUI
        //TODO: self.initData
    }
    
    override func viewWillAppear(_ animated: Bool){
        //viewWillAppear(animated)
        startUpdateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    func prefersStatusBarHidden()-> Bool{
        return false
    }
    
    
    //MARK: DJI Functions
    
    //Register the app with DJISIDKManager call
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }
    
    func appRegisteredWithError(_ error: Error?) {
        NSLog("App registrada!")
        DJISDKManager.startConnectionToProduct()
        DJISDKManager.appActivationManager().delegate = self as? DJIAppActivationManagerDelegate

    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        // vacio
    }
    
    
    //MARK:Buttons Functions
    @IBAction func editBtnAction(_ sender: Any) {
        if isEditingPoints {
            mapController?.cleanAllPointsWithMapView(with: mapView)
            editBtn.setTitle("Edit", for: .normal)
        }
        else{
            editBtn.setTitle("Reset", for: .normal)
        }
        
        isEditingPoints = !isEditingPoints
    }
    
    @IBAction func focusMapAction(_ sender: Any) {
        if CLLocationCoordinate2DIsValid(userLocation){
            var region: MKCoordinateRegion = MKCoordinateRegion.init()
            region.center = userLocation
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    
    //MARK: Custom Functions
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer?){
        let point = tapGesture?.location(in: self.mapView)
        
        if (tapGesture?.state == .ended){
            
            if isEditingPoints {
                mapController?.addPoint(point!, with: mapView)
            }
        }
    }
    
    func startUpdateLocation(){
        if CLLocationManager.locationServicesEnabled(){
            if locationManager == nil {
                locationManager = CLLocationManager.init()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.distanceFilter = 0.1
                
                if (locationManager?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))!{
                    locationManager?.requestAlwaysAuthorization()
                }
                locationManager?.startUpdatingLocation()
            }
        }
        else{
            let alert = UIAlertController.init(title: "Location Services is not available", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    //MARK: MKMapViewDelegate Method
    func viewForAnnotation(_ mapView: MKMapView, viewFor annotation: MKAnnotation)-> MKPinAnnotationView? {
        
        if annotation.isKind(of: MKPointAnnotation.self){
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            pinView.pinTintColor = .purple
            
            return pinView
        }
        
        return nil
        
    }
    
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations.last
        
        if let coordinate = location?.coordinate{
            userLocation = coordinate
        }
    }
    
    
    
}
