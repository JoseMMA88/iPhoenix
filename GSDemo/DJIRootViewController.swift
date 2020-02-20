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

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate{
    
    //MARK: Vars
    var mapController: DJIMapControler?
    var isEditingPoints: Bool = false
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D!
    var droneLocation: CLLocationCoordinate2D!
    
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    
    //MARK: View Controller functions
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //self.registerApp()
        self.initUI()
        self.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*super.viewDidAppear(animated)
        
        let alert = UIAlertController.init(title: "prueba", message: "message", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
              
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)*/
        
        self.registerApp()
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
        var message = "App registrada"
        
        if (error != nil){
            message = "Error al registrar la App"
        }
        else{
            NSLog("App registrada!\n")
            DJISDKManager.startConnectionToProduct()
            //DJISDKManager.appActivationManager().delegate = self as? DJIAppActivationManagerDelegate
        }
        
        self.showAlertViewWithTittle(title: "Registro de App", WithMessage: message)
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
         self.showAlertViewWithTittle(title: "Conectando con el producto", WithMessage: "en proceso")
        if (product != nil){
            //self.showAlertViewWithTittle(title: "Conectandoo con el producto", WithMessage: "producto conectado")
            NSLog("Producto conectado \n")
            let flightControler = DemoUtility.fetchFlightController()
            if(flightControler != nil){
                NSLog("flightContriler delegated! \n")
                flightControler!.delegate = self
                NSLog("flightContriler deleg111ated! \n")
            }
        }
        else{
            //self.showAlertViewWithTittle(title: "Conectandooo con el producto", WithMessage: "error al conectar el producto")
            //ShowMessage("Product disconnected", nil, nil, "OK")
            NSLog("Producto desconectado \n")
        }
        //self.showAlertViewWithTittle(title: "Conectandooooo con el producto", WithMessage: "se acabó el proceso")
        NSLog("se acabó el procreso \n")
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
        if CLLocationCoordinate2DIsValid(droneLocation){
            var region: MKCoordinateRegion = MKCoordinateRegion.init()
            region.center = droneLocation
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            NSLog("Localizacion del dron:\n")
            
           /* let c:String = String(format:"%.1f", droneLocation.latitude)
            print("Latitud: \(c)")
            
            
            let c1:String = String(format:"%.1f", droneLocation.longitude)
            print("Longitud: \(c1)")*/
            mapView.setRegion(region, animated: true)
        }
        else{
            NSLog("No tengo la localizacion del dron!!\n")
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
                self.showAlertViewWithTittle(title: "Actualizando Localizacion", WithMessage: "")
            }
        }
        else{
            self.showAlertViewWithTittle(title: "Location Services is not avaible", WithMessage: "")
        }
    }
    
    func showAlertViewWithTittle(title: String, WithMessage message: String){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Initialize labels upmap
    func initUI(){
        self.modeLabel.text     = "N/A"
        self.gpsLabel.text      = "0"
        self.vsLabel.text       = "0.0 M/S"
        self.hsLabel.text       = "0.0 M/S"
        self.altitudeLabel.text = "0 M"
    }
    
    // Initialize
    func initData(){
        userLocation = kCLLocationCoordinate2DInvalid
        droneLocation = kCLLocationCoordinate2DInvalid
        
        mapController = DJIMapControler()
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        
    }
    
    //MARK: MKMapViewDelegate Method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)-> MKAnnotationView? {
        
        if annotation.isKind(of: MKPointAnnotation.self){
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            NSLog("Add new pin")
            pinView.pinTintColor = .green
            return pinView
        }
        else if(annotation.isKind(of: DJIAircraftAnnotation.self)){
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? DJIAircraftAnnotation)?.annotationView = annoView
            
            return annoView
            
        }
        
        return nil
        
    }
    
    
    //MARK: DJIFlightControllerDelegate
    func flightController(_ fc: DJIFlightController,didUpdate state: DJIFlightControllerState){
        droneLocation = state.aircraftLocation?.coordinate
        
        modeLabel.text = state.flightModeString
        gpsLabel.text = String.init(format: "%lu", state.satelliteCount)
        vsLabel.text = String.init(format: "%0.1f M/S", state.velocityZ)
        hsLabel.text = String.init(format: "%0.1f M/S", (sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY)))
        altitudeLabel.text = String.init(format: "0.1f M", state.altitude)
        
        mapController?.updateAircraftLocation(location: self.droneLocation, withMapView: self.mapView)
                                        //degrees to radians
        let radianYaw: Double = (state.attitude.yaw) * .pi / 180
        mapController?.updateAicraftHeading(heading: Float(radianYaw))
    }
    
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations.last
        
        if let coordinate = location?.coordinate{
            userLocation = coordinate
        }
        
        //self.showAlertViewWithTittle(title: "Location Manager Delegate", WithMessage: "")
    }
    
    
    
}
