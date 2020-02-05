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

class DJIRootViewController: UIViewController, MKMapViewDelegate, DJISDKManagerDelegate{
    
    //MARK: Vars
    var mapController: DJIMapControler?
    var isEditingPoints: Bool = false
    
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var editBtn: UIButton!
    
    
    //MARK: View Controller functions
    /*func viewWillAppear(_ animated: Bool){
        viewWillAppear(animated)
        //startUpdateLocation()
    }
    
    func viewWillDisappear(_ animated: Bool){
        viewWillDisappear(animated)
    }*/
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.registerApp()
        
        mapController = DJIMapControler()
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        
        //TODO: self.initUI
        //TODO: self.initData
    }
    
    
    //MARK: DJI Functions
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
    
    
    
    
    //MARK: Custom Functions
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer?){
        let point = tapGesture?.location(in: self.mapView)
        
        if (tapGesture?.state == .ended){
            
            if isEditingPoints {
                mapController?.addPoint(point!, with: mapView)
            }
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
    
}
