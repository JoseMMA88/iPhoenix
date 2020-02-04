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
    var tapGesture: UITapGestureRecognizer?
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
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
        
        //self.initUI
        //self.initData
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
    
    
    //MARK: Fix Functions
}
