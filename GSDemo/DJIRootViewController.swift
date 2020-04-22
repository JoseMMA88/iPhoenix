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
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    //MARK: Vars
    var mapController: DJIMapController?
    var pathController: FlyPathController?
    var isEditingPoints: Bool = false
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D!
    var droneLocation: CLLocationCoordinate2D!
    var waypointMission: DJIMutableWaypointMission?
    
    
    //MARK: View Controller functions
    
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        
        //self.registerApp()
        self.initUI()
        self.initData()
        pathController = FlyPathController(mapView: mapView!)
        pathController!.updatePolygon()
        mapView.mapType = .satellite
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*super.viewDidAppear(animated)
        */
        
        self.registerApp()
    }
    
    override func viewWillAppear(_ animated: Bool){
        //viewWillAppear(animated)
        startUpdateLocation()
    }
    
   /* override func viewWillDisappear(_ animated: Bool){
        //viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }*/
    

    
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
        }
        
        self.showAlertViewWithTittle(title: "Registro de App", WithMessage: message)
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if (product != nil){
            self.showAlertViewWithTittle(title: "Dron connected!", WithMessage: "")
            NSLog("Producto conectado \n")
            let flightControler = DemoUtility.fetchFlightController()
            if(flightControler != nil){
                flightControler!.delegate = self
            }
        }
        else{
            NSLog("Producto desconectado \n")
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        // vacio
    }
    
    
    //MARK:Buttons Functions
    @IBAction func editBtnAction(_ sender: Any) {
        if isEditingPoints {
            isEditing = false
            finishBtnAction()
            //mapController?.cleanAllPointsWithMapView(with: mapView)
            editBtn.setTitle("Add", for: .normal)
        }
        else{
            isEditing = true
            
            focusMap()
            
            editBtn.setTitle("Finished", for: .normal)
        }
        
        isEditingPoints = !isEditingPoints
    }
    
    
    @IBAction func startBtnAction(_ sender: Any) {
        missionOperator()?.startMission(completion: { error in
            if (error != nil){
                self.showAlertViewWithTittle(title: "Start Mission Failed!", WithMessage: error!.localizedDescription)
            }
            else{
                self.showAlertViewWithTittle(title: "Mission Started!", WithMessage: "")
            }
        })
    }
    
    
    @IBAction func focusMapAction(_ sender: Any) {
        focusMap()
        
    }
    
    
    @IBAction func cleanWaypoints(_ sender: Any) {
        //mapController?.cleanAllPointsWithMapView(with: mapView)
        pathController?.cleanAllPoints(aircraft: mapController?.getAircraftAnno())
    }
    
    
    //MARK: Custom Functions
    /*@objc func addWaypoints(tapGesture: UITapGestureRecognizer?){
        let point = tapGesture?.location(in: self.mapView)
        
        if (tapGesture?.state == .ended){
            
            if isEditingPoints {
                mapController?.addPoint(point!, with: mapView)
            }
        }
    }*/
    
    
    @IBAction func stopBtnAction(_ sender: Any) {
        missionOperator()?.stopMission(completion: { error in
            if(error != nil){
                self.showAlertViewWithTittle(title: "Stop Mission Failed: ", WithMessage: error!.localizedDescription)
            }
            else{
                self.showAlertViewWithTittle(title: "Stop Mission", WithMessage: "")
            }
        })
    }
    
    
    @IBAction func addPointBtnAction(_ sender: Any) {
        if isEditingPoints {
            //NSLog("points count: " + String(pathController!.points.count))
            if(pathController!.points.count == 0){
                let point = MKPointAnnotation()
                pathController!.points.append(point)
                point.coordinate = CLLocation(latitude: droneLocation.latitude + pathController!.d, longitude: droneLocation.longitude + pathController!.d).coordinate
                
                mapView.addAnnotation(point)
                pathController!.updatePolygon()
            }
            else{
                let point = MKPointAnnotation()
                pathController!.points.append(point)
                let lat = pathController!.points[0].coordinate.latitude
                let long = pathController!.points[0].coordinate.longitude
                point.coordinate = CLLocation(latitude: lat + pathController!.d, longitude: long + pathController!.d).coordinate
            
                mapView.addAnnotation(point)
                pathController!.updatePolygon()
            }
        }
    }
    
    
    @IBAction func removeLastPointsBtnAction(_ sender: Any) {
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        var borrlat: Double = 0
        var borrlong: Double = 0
               
        // Borramos en la array points
        for i in 0..<pathController!.points.count{
            if(i == (pathController!.points.count-1)){
            //if (!(ann!.isEqual(self.aircraftAnnotation)))
                borrlat = pathController!.points[i].coordinate.latitude
                borrlong = pathController!.points[i].coordinate.longitude
                        
                pathController!.points.remove(at: i)
            }
        }
        
        // Borramos en la array de Annotations
        for n in 0..<annos.count{
            weak var ann = annos[n] as? MKAnnotation
                if((borrlat == ann!.coordinate.latitude) && (borrlong == ann!.coordinate.longitude)){
                    // Borramos annotation
                    mapView?.removeAnnotation(ann!)
                }
        }
        pathController!.updatePolygon()
    }
    
    
    @IBAction func btnActionDebug(_ sender: Any) {
        mapView.removeAnnotations(pathController!.points)
        for i in 0..<pathController!.fly_points.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points[i]
            ano.title = String(i)
            mapView.addAnnotation(ano)
            
            if(i < pathController!.fly_points.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points[i], pathController!.fly_points[i+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }
        
    }
    
    
    
//-----------------------------------------------------------------------------------------------------//
    
    //MARK: MKMapViewDelegate Method
     
     
    // Se llama al principio de la ejecucion y cuando movemos un annotation
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        NSLog("MAPVIEW 1")
           if overlay is MKPolygon {
             NSLog("MKPOLYGON")
             pathController!.polygonView! = MKPolygonRenderer(overlay: overlay)
             pathController!.polygonView!.strokeColor = .green
             pathController!.polygonView!.lineWidth = 1.0
             pathController!.polygonView!.fillColor = UIColor.green.withAlphaComponent(0.25)
             return pathController!.polygonView!
           }
           else if overlay is MKCircle {
             NSLog("MKPOLYGON")
             pathController!.circleView! = MKCircleRenderer(overlay: overlay)
             pathController!.circleView!.strokeColor = .red
             pathController!.circleView!.lineWidth = 2.0
             pathController!.circleView!.fillColor = UIColor.red.withAlphaComponent(0.25)
             return pathController!.circleView!
         }
           else if overlay is MKPolyline {
             NSLog("MKPOLYGON")
             pathController!.routeLineView! = MKPolylineRenderer(overlay: overlay)
             pathController!.routeLineView!.strokeColor = UIColor.blue.withAlphaComponent(0.2)
             pathController!.routeLineView!.fillColor = UIColor.blue.withAlphaComponent(0.2)
             pathController!.routeLineView!.lineWidth = 45
             return pathController!.routeLineView!
         }
           return MKOverlayRenderer()
    }
    
    
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        NSLog("MAPVIEW 2")
        if(annotation.isKind(of: DJIAircraftAnnotation.self)){
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? DJIAircraftAnnotation)?.annotationView = annoView
            
            return annoView
            
        }
        
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "marker")
        
        if (view == nil){
            view = MKMarkerAnnotationView.init(annotation: annotation, reuseIdentifier: "marker")
            view?.canShowCallout = false
            view?.isDraggable = false
            
            // Sobreescribimos la logica de drag con la nuestra propia
            let drag = UILongPressGestureRecognizer(target: self, action: #selector(handleDrag(gesture:)))
            
            drag.minimumPressDuration = 0 // instant bru
            drag.allowableMovement = .greatestFiniteMagnitude
            view?.addGestureRecognizer(drag)
        }
        else{
            view?.annotation = annotation
        }
        return view
    }
     
     
     // Se llama a esta funcion cuando se arrastra un Annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        NSLog("MAPVIEW 3")
        pathController!.updatePolygon()
    }*/

     
    // -------------------------------------------------------------------------------------------------------- //
    
    
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
        
        mapController = DJIMapController()
        //tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        //mapView.addGestureRecognizer(tapGesture)
        
    }
    
    
 
    
    //MARK: TOUCH HANDLING
    //Handle drag custom
    @objc func handleDrag(gesture: UILongPressGestureRecognizer){
        let annotationView = gesture.view as! MKAnnotationView
        annotationView.setSelected(false, animated: false)
        
        let location = gesture.location(in: mapView)
        
        if(gesture.state == .began){
            pathController!.startLocation = location
        }
        else if (gesture.state == .changed){
            gesture.view?.transform = CGAffineTransform.init(translationX: location.x - pathController!.startLocation!.x, y: location.y - pathController!.startLocation!.y)
        }
        else if (gesture.state == .ended || gesture.state == .cancelled){
            let annotation = annotationView.annotation as! MKPointAnnotation
            let translate = CGPoint.init(x: location.x - pathController!.startLocation!.x , y: location.y - pathController!.startLocation!.y)
            let originalLocaton = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let updatedLocation = CGPoint.init(x: originalLocaton.x + translate.x, y: originalLocaton.y + translate.y)
            
            annotationView.transform = CGAffineTransform.identity
            annotation.coordinate = mapView.convert(updatedLocation, toCoordinateFrom: mapView)
            
            //Actualizamos el poligono cuando acaba el gesto
            pathController!.updatePolygon()
            
        }
    }
    
    
    func focusMap(){
         let regionRadius: CLLocationDistance = 200//[m]
         if(droneLocation != nil && CLLocationCoordinate2DIsValid(droneLocation)){
             let region: MKCoordinateRegion = MKCoordinateRegion.init(center: droneLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
             pathController?.getDroneLocation(droneLocation: droneLocation)
             mapView.setRegion(region, animated: true)
         }
         else{
             if(userLocation != nil && CLLocationCoordinate2DIsValid(userLocation)){
                 let region: MKCoordinateRegion = MKCoordinateRegion.init(center: userLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                 pathController?.getDroneLocation(droneLocation: userLocation)
                 mapView.setRegion(region, animated: true)
             }
             else{
                 self.showAlertViewWithTittle(title: "Location Services is not avaible", WithMessage: "")
                 NSLog("No tengo la localizacion del dron!!\n")
             }
         }
     }
    
    
    //MARK: DJIFlightControllerDelegate
    func flightController(_ fc: DJIFlightController,didUpdate state: DJIFlightControllerState){
        droneLocation = state.aircraftLocation?.coordinate
        
        modeLabel.text = state.flightModeString
        gpsLabel.text = String.init(format: "%lu", state.satelliteCount)
        vsLabel.text = String.init(format: "%0.1f M/S", state.velocityZ)
        hsLabel.text = String.init(format: "%0.1f M/S", (sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY)))
        altitudeLabel.text = String.init(format: "%0.1f M", state.altitude)
        
        if(droneLocation != nil){
            mapController?.updateAircraftLocation(location: droneLocation, withMapView: mapView)
                                        //degrees to radians
            let radianYaw: Double = (state.attitude.yaw) * .pi / 180
            mapController?.updateAicraftHeading(heading: Float(radianYaw))
        }
    }
    
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){

        let location = locations.last
        
        if let coordinate = location?.coordinate{
            userLocation = coordinate
        }
        
    }

    
    //MARK: Action Functions
    func missionOperator() -> DJIWaypointMissionOperator? {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    
    func finishBtnAction() {
        //let wayPoints = self.mapController?.wayPoints()
        let wayPoints = self.pathController?.fly_points
        if(wayPoints == nil || wayPoints!.count < 2){
            showAlertViewWithTittle(title: "No or not enought waypoints for mission", WithMessage: "")
        }
        
        if(self.waypointMission != nil){
            self.waypointMission?.removeAllWaypoints()
        }
        else{
            self.waypointMission = DJIMutableWaypointMission()
        }
        
        for i in 0..<wayPoints!.count{
            let location = CLLocation(latitude: wayPoints![i].latitude,longitude: wayPoints![i].longitude)
            let coordinate = location.coordinate
            if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location.coordinate)
                    waypointMission!.add(waypoint)
            }
        }
        
        
        if(waypointMission != nil){
            for i in 0..<waypointMission!.waypointCount{
                let waypoint = waypointMission?.waypoint(at: i)
                waypoint?.altitude = 20  //MARK: ALTITUD DE WAYPOINT
            }
        
            waypointMission?.maxFlightSpeed = 10 //MARK: VELOCIDAD MAXIMA
            waypointMission?.autoFlightSpeed = 10 //MARK: VELOCIDAD AUTOMATICA
            waypointMission?.headingMode = DJIWaypointMissionHeadingMode.auto //MARK: HEADING AUTO
            waypointMission?.finishedAction = DJIWaypointMissionFinishedAction.goHome //MARK: ACCION AL FINAL
        
            missionOperator()?.load(waypointMission!)
        
            missionOperator()?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { error in
                if(error != nil){
                    if let descripcion = error?.localizedDescription {
                        self.showAlertViewWithTittle(title: "MISION EXECUTION FAILED", WithMessage: descripcion)
                    }
                }
                else{
                    self.showAlertViewWithTittle(title: "MISSION EXECUTION FINISHED", WithMessage: "")
                }
            })
        
            missionOperator()?.uploadMission(completion: { error in
                if(error != nil){
                    self.showAlertViewWithTittle(title: "UPLOAD MISSION FAILED", WithMessage: error!.localizedDescription)
                }
                else{
                    self.showAlertViewWithTittle(title: "UPLOAD MISSION FINISHED", WithMessage: "")
                }
            })
        }
    }
    
    
    
    
    
    
    
}
