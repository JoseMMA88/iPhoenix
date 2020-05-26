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

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate, ButtonViewControllerDelegate, ConfigViewControllerDelegate, StartViewControllerDelegate{

    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    //@IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    //MARK: Vars
    var pathController: FlyPathController?
    var mapController: DJIMapControler?
    var isEditingPoints: Bool = false
    
    var ButtonVC: ButtonControllerViewController?
    var waypointConfigVC: ConfigViewController?
    var StartVC: StartViewController?
    
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D!
    var droneLocation: CLLocationCoordinate2D!
    var waypointMission: DJIMutableWaypointMission?
    var startLocation: CGPoint?
    
    //MARK: View Controller functions
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //self.registerApp()
        self.initUI()
        self.initData()
        
        pathController = FlyPathController()
        mapController!.updatePolygon(with: mapView, and: pathController)
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
        var message = "Registration Complete!"
        
        if (error != nil){
            message = "Error registering app"
        }
        else{
          //  NSLog("App registrada!\n")
            DJISDKManager.startConnectionToProduct()
        }
        
        self.showAlertViewWithTittle(title: "App Registration", WithMessage: message)
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
    
    func addBtnAction(_ button: UIButton?, inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        if isEditingPoints {
            isEditingPoints = false
            //finishBtnActions()
            button?.setTitle("Add", for: .normal)
        } else {
            isEditingPoints = true
            button?.setTitle("Finished", for: .normal)
        }
    }
    
    func clearBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        mapController?.cleanAllPointsWithMapView(with: mapView, and: pathController!)
    }
    
    func focusMapBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        focusMap()
    }
    
    func startBtnAction(inButtonVC BtnVC: StartViewController?) {
        missionOperator()?.startMission(completion: { error in
            if (error != nil){
                self.showAlertViewWithTittle(title: "Start Mission Failed!", WithMessage: error!.localizedDescription)
            }
            else{
                self.showAlertViewWithTittle(title: "Mission Started!", WithMessage: "")
            }
        })
    }
    
    func stopBtnAction(inButtonVC BtnVC: StartViewController?) {
        missionOperator()?.stopMission(completion: { error in
            if(error != nil){
                self.showAlertViewWithTittle(title: "Stop Mission Failed: ", WithMessage: error!.localizedDescription)
            }
            else{
                self.showAlertViewWithTittle(title: "Stop Mission", WithMessage: "")
            }
        })
    }
    
    func deleteBtnAction(InGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        var borrlat: Double = 0
        var borrlong: Double = 0
        
        // Borramos en la array points
        for i in 0..<mapController!.editPoints.count{
            if(i == (mapController!.editPoints.count-1)){
                //if (!(ann!.isEqual(self.aircraftAnnotation)))
                borrlat = mapController!.editPoints[i].coordinate.latitude
                borrlong = mapController!.editPoints[i].coordinate.longitude
                                       
                mapController!.editPoints.remove(at: i)
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
        mapController!.updatePolygon(with: mapView, and: pathController)
    }
    
    func configBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        NSLog("CONFIIIIG!!!")
        
        let wayPoints = pathController!.fly_points
         
        if(wayPoints.count < 2){
            showAlertViewWithTittle(title: "No or not enought waypoints for mission", WithMessage: "")
        }
        else{
            waypointConfigVC!.view.alpha = 1.0
            if(self.waypointMission != nil){
                self.waypointMission?.removeAllWaypoints()
            }
            else{
                self.waypointMission = DJIMutableWaypointMission()
            }
        
            for i in 0..<wayPoints.count{
                let location = wayPoints[i]
                let coordinate = location
                if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location)
                    waypointMission!.add(waypoint)
                }
            }
        }
    }
    
    func switchto(to mode: ViewMode, inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        if(mode == ViewMode._EditMode){
            focusMap()
        }
    }
    
    func debugBtn(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        mapView.removeAnnotations(mapController!.editPoints)
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
    
    func cancelBtnAction(inButtonVC BtnVC: ConfigViewController?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC!.view.alpha = 0
        })
    }
    
    func finishBtnAction(inButtonVC BtnVC: ConfigViewController?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC?.view.alpha = 0
        })
        
        if(waypointMission != nil){
            for i in 0..<waypointMission!.waypointCount{
                let waypoint = waypointMission?.waypoint(at: i)
                waypoint?.altitude = 20  //MARK: ALTITUD DE WAYPOINT
            }
        
            waypointMission?.maxFlightSpeed = (waypointConfigVC!.maxFlightSpeedTextField.text! as NSString).floatValue //MARK: VELOCIDAD MAXIMA
            waypointMission?.autoFlightSpeed = (waypointConfigVC!.autoFlightSpeedTextField.text! as NSString).floatValue //MARK: VELOCIDAD AUTOMATICA
            waypointMission?.headingMode = DJIWaypointMissionHeadingMode(rawValue: DJIWaypointMissionHeadingMode.RawValue(waypointConfigVC!.headingSegmentedControl.selectedSegmentIndex))! as DJIWaypointMissionHeadingMode //MARK: HEADING AUTO
            waypointMission?.finishedAction = DJIWaypointMissionFinishedAction(rawValue: DJIWaypointMissionFinishedAction.RawValue(waypointConfigVC!.actionSegmentedControl.selectedSegmentIndex))! as DJIWaypointMissionFinishedAction //MARK: ACCION AL FINAL
        
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
                        self.StartVC!.view.alpha = 1
                    }
                })
        
            
            }
        
        
    }
    
    
    //MARK: Custom Functions
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer?){
        let point = tapGesture?.location(in: self.mapView)
        
        if (tapGesture?.state == .ended){
            
            if isEditingPoints {
                mapController?.addPoint(point!, with: mapView, and: pathController)
                mapController?.updatePolygon(with: mapView, and: pathController)
                //let coordinate: CLLocationCoordinate2D = ((mapView?.convert(point!, toCoordinateFrom: mapView) ?? nil)!)
                //pathController?.addPointoPath(point: coordinate, with: mapView)
            }
        }
    }
    
    //-----------------------------------------------------------------------------------------------------//
    
    
    
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
        
        ButtonVC = ButtonControllerViewController.init(nibName: "ButtonControllerViewController", bundle: Bundle.main)
        ButtonVC?.view.frame = CGRect(x: 0, y: CGFloat(Int(topBarView.frame.origin.y + topBarView.frame.size.height)), width: ButtonVC!.view.frame.size.width, height: ButtonVC!.view.frame.size.height)
        ButtonVC!.delegate = self
        view.addSubview(ButtonVC!.view)
        
        StartVC = StartViewController.init(nibName: "StartViewController", bundle: Bundle.main)
        StartVC!.view.alpha = 0
        
        let startVCOriginX: CGFloat = (topBarView.frame.width - StartVC!.view.frame.width - 5)
        let startVCOriginY: CGFloat = (view.frame.height - StartVC!.view.frame.height - 10)
        
        StartVC!.view.frame = CGRect(x: startVCOriginX, y: startVCOriginY, width: StartVC!.view.frame.size.width, height: StartVC!.view.frame.size.height)
        StartVC!.delegate = self
        view.addSubview(StartVC!.view)
        
        waypointConfigVC = ConfigViewController.init(nibName: "ConfigViewController", bundle: Bundle.main)
        waypointConfigVC!.view.alpha = 0
        
        waypointConfigVC!.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        let configVCOriginX: CGFloat = (view.frame.width - waypointConfigVC!.view.frame.width) / 2
        let configVCOriginY: CGFloat = topBarView.frame.height + topBarView.frame.minY + 8
        
        waypointConfigVC!.view.frame = CGRect(x: configVCOriginX, y: configVCOriginY, width: waypointConfigVC!.view.frame.width, height: waypointConfigVC!.view.frame.height)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            waypointConfigVC?.view.center = view.center
        }
        
        waypointConfigVC!.delegate = self
        view.addSubview(waypointConfigVC!.view)

    }
    
    // Initialize
    func initData(){
        userLocation = kCLLocationCoordinate2DInvalid
        droneLocation = kCLLocationCoordinate2DInvalid
        
        mapController = DJIMapControler()
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        startLocation = CGPoint.zero
        
    }
    
    //MARK: MKMapViewDelegate Method
    // Se llama al principio de la ejecucion y cuando movemos un annotation
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           if overlay is MKPolygon {
             mapController!.polygonView = MKPolygonRenderer(overlay: overlay)
             mapController!.polygonView!.strokeColor = .green
             mapController!.polygonView!.lineWidth = 1.0
             mapController!.polygonView!.fillColor = UIColor.green.withAlphaComponent(0.25)
             return mapController!.polygonView!
           }
           else if overlay is MKCircle {
             mapController!.circleView = MKCircleRenderer(overlay: overlay)
             mapController!.circleView!.strokeColor = .red
             mapController!.circleView!.lineWidth = 2.0
             mapController!.circleView!.fillColor = UIColor.red.withAlphaComponent(0.25)
             return mapController!.circleView!
         }
           else if overlay is MKPolyline {
             pathController!.routeLineView = MKPolylineRenderer(overlay: overlay)
             pathController!.routeLineView!.strokeColor = UIColor.blue.withAlphaComponent(0.2)
             pathController!.routeLineView!.fillColor = UIColor.blue.withAlphaComponent(0.2)
             pathController!.routeLineView!.lineWidth = 45
             return pathController!.routeLineView!
         }
           return MKOverlayRenderer()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)-> MKAnnotationView? {
        
        /*if annotation.isKind(of: MKPointAnnotation.self){
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            NSLog("Add new pin")
            return pinView
        }
        else*/ if(annotation.isKind(of: DJIAircraftAnnotation.self)){
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
          mapController!.updatePolygon(with: mapView, and: pathController)
      }
    
    
    //---------------------------------------------------------------------------------------------------------
    
    //MARK: TOUCH HANDLING
    //Handle drag custom
    @objc func handleDrag(gesture: UILongPressGestureRecognizer){
        let annotationView = gesture.view as! MKAnnotationView
        annotationView.setSelected(false, animated: false)
        
        let location = gesture.location(in: mapView)
        
        if(gesture.state == .began){
            
           startLocation = location
        }
        else if (gesture.state == .changed){
            gesture.view?.transform = CGAffineTransform.init(translationX: location.x - startLocation!.x, y: location.y - startLocation!.y)
        }
        else if (gesture.state == .ended || gesture.state == .cancelled){
            let annotation = annotationView.annotation as! MKPointAnnotation
            let translate = CGPoint.init(x: location.x - startLocation!.x , y: location.y - startLocation!.y)
            let originalLocaton = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let updatedLocation = CGPoint.init(x: originalLocaton.x + translate.x, y: originalLocaton.y + translate.y)
            
            annotationView.transform = CGAffineTransform.identity
            annotation.coordinate = mapView.convert(updatedLocation, toCoordinateFrom: mapView)
            
            //Actualizamos el poligono cuando acaba el gesto
            mapController!.updatePolygon(with: mapView, and: pathController)
            
        }
    }
    
    
    func focusMap(){
         let regionRadius: CLLocationDistance = 200//[m]
         if(droneLocation != nil && CLLocationCoordinate2DIsValid(droneLocation)){
             let region: MKCoordinateRegion = MKCoordinateRegion.init(center: droneLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                pathController?.setDroneLocation(droneLocation: droneLocation)
                mapView.setRegion(region, animated: true)
         }
         else{
             if(userLocation != nil && CLLocationCoordinate2DIsValid(userLocation)){
                 let region: MKCoordinateRegion = MKCoordinateRegion.init(center: userLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                 pathController?.setDroneLocation(droneLocation: userLocation)
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
    
    func finishBtnActions() {
        
        let wayPoints = pathController!.fly_points
        
        if(wayPoints.count < 2){
            showAlertViewWithTittle(title: "No or not enought waypoints for mission", WithMessage: "")
        }
        else{
            if(self.waypointMission != nil){
                self.waypointMission?.removeAllWaypoints()
            }
            else{
                self.waypointMission = DJIMutableWaypointMission()
            }
        
            for i in 0..<wayPoints.count{
                let location = wayPoints[i]
                let coordinate = location
                if CLLocationCoordinate2DIsValid(coordinate){
                        let waypoint = DJIWaypoint(coordinate: location)
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
    
    
    
    
    
    
    
}
