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
    var waypointMission: DJIMutableWaypointMission?
    
    
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
        
        //mapView.isUserInteractionEnabled = false // the map wont be dragged
        
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
    
    
    
    
    //------------------------------------------------------ DJI --------------------------------------------------------------------------------------------
    
    
    
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
    
    
    
    
    
    
// ---------------------------------------------------------- BUTTONS ----------------------------------------------------------------------------
    
    
    
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
            /* -----------------  FOCUS MAP  ------------------------*/
            if(droneLocation != nil){
                if CLLocationCoordinate2DIsValid(droneLocation){
                    var region: MKCoordinateRegion = MKCoordinateRegion.init()
                    region.center = droneLocation
                    region.span.latitudeDelta = 0.001
                    region.span.longitudeDelta = 0.001
                       
                    mapView.setRegion(region, animated: true)
                }
            }
            /*-----------------------------------------------------*/
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
        if(droneLocation != nil){
            if CLLocationCoordinate2DIsValid(droneLocation){
                var region: MKCoordinateRegion = MKCoordinateRegion.init()
                region.center = droneLocation
                region.span.latitudeDelta = 0.001
                region.span.longitudeDelta = 0.001
            
                mapView.setRegion(region, animated: true)
            }
        }
        else{
            self.showAlertViewWithTittle(title: "Location Services is not avaible", WithMessage: "")
            NSLog("No tengo la localizacion del dron!!\n")
        }
        
    }
    
    @IBAction func cleanWaypoints(_ sender: Any) {
        mapController?.cleanAllPointsWithMapView(with: mapView)
    }
    
    
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer?){
        let point = tapGesture?.location(in: self.mapView)
        
        if (tapGesture?.state == .ended){
            
            if isEditingPoints {
                mapController?.addPoint(point!, with: mapView)
            }
        }
    }
    
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
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------
       
       
       
       
       //MARK: Custom Functions
    
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
    
    
    
    // Funcion para mostrar una alerta en la pantalla del dispositivo
    func showAlertViewWithTittle(title: String, WithMessage message: String){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // Inicializamos los labels del UI
    func initUI(){
        self.modeLabel.text     = "N/A"
        self.gpsLabel.text      = "0"
        self.vsLabel.text       = "0.0 M/S"
        self.hsLabel.text       = "0.0 M/S"
        self.altitudeLabel.text = "0 M"
    }
    
    // Inicializamos los objetos
    func initData(){
        userLocation = kCLLocationCoordinate2DInvalid
        droneLocation = kCLLocationCoordinate2DInvalid
        
        mapController = DJIMapControler()
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addWaypoints(tapGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        
    }
    
    
    
//------------------------------------------------------------ MAP VIEW -----------------------------------------------------------------------------------------------
    
    //MARK: MKMapViewDelegate Method
    
    
    // Funcion delegate de MKMapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolygonRenderer.init(overlay: overlay)
            polylineRenderer.strokeColor = .orange
            polylineRenderer.lineWidth = 4
        }
        else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer.init(overlay: overlay)
            polygonView.fillColor = .green
            return polygonView
        }
        return MKPolygonRenderer(overlay: overlay)
    }
    
    
    
    // Cuando el usario empieza a dibujar en la pantalla,
    // vamos guardondo los touchpoints en la array de coordenadas de mapController
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mapView.removeOverlays(mapView.overlays)
        
        if let touch = touches.first {
            mapController?.addPoint(touch.location(in: mapView), with: mapView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            mapController?.addPoint(touch.location(in: mapView), with: mapView)
            
            let polyline = MKPolyline(coordinates: (mapController?.auxwayPoints())!, count: (mapController?.auxwayPoints()!.count)!)
            mapView.addOverlay(polyline)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let polygon = MKPolygon(coordinates: (mapController?.auxwayPoints())!, count: (mapController?.auxwayPoints()!.count)!)
        mapView.addOverlay(polygon)
        
        mapController?.cleanAllPointsWithMapView(with: mapView)
    }
    
    
    
    
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
        
        
    
    
    //MARK: DJIFlightControllerDelegate
    
    //Funcion de Delegate de DJIFlightController
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


//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations.last
        
        if let coordinate = location?.coordinate{
            userLocation = coordinate
        }
        
    }
    
    
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    //MARK: Action Functions
    
    // Clase que se encarga de dar las ordenes de vuelo
    func missionOperator() -> DJIWaypointMissionOperator? {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    
    
    // Funcion que se invoca en el boton de "Finished"
    // pasamos el array de coordenadas de mapController a la cola de vuelo de MissionOperator
    // y seteamos los parametros de vuelo
    func finishBtnAction() {
        let wayPoints = self.mapController?.wayPoints()
        
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
            let location = wayPoints![i] as? CLLocation
            if let coordinate = location?.coordinate{
                if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location!.coordinate)
                    waypointMission!.add(waypoint)
                }
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
    
    
    
 //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
}
