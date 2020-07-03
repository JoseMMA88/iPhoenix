//
//  DJIRootViewController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 03/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import DJISDK
import MapKit
import UIKit
import CoreLocation

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate, DJICameraDelegate, ButtonViewControllerDelegate, ConfigViewControllerDelegate, StartViewControllerDelegate, InsertTokenViewControllerDelegate{
    

    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
   
    
    //MARK: Vars
    var pathController: FlyPathController?
    var mapController: DJIMapControler?
    var multiController: MultiflyController?
    var flightControler: DJIFlightController?
    var isEditingPoints: Bool = false
    
    var ButtonVC: ButtonControllerViewController?
    var waypointConfigVC: ConfigViewController?
    var insertTokenVC: TokenViewController?
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
        multiController = MultiflyController.init()
        mapController!.updatePolygon(with: mapView, and: pathController)
        
        //Mapview style
        mapView.mapType = .satellite
        mapView.subviews[1].isHidden = true
        mapView.subviews[2].isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
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
        let camera = fetchCamera()
        if camera != nil{
            camera?.delegate = nil
        }
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
            DJISDKManager.startConnectionToProduct()
        }
        
        self.showAlertViewWithTittle(title: "App Registration", WithMessage: message)
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if (product != nil){
            //NSLog("Producto conectado \n")
            //let flightControler = DemoUtility.fetchFlightController()
            if(flightControler == nil){
                if(product is DJIAircraft){
                    flightControler = (product as! DJIAircraft).flightController
                //return controler?.flightController
                }
            }
            if(flightControler != nil){
                self.showAlertViewWithTittle(title: "Dron connected!", WithMessage: "")
                flightControler!.delegate = self
                let camera = fetchCamera()
                if(camera != nil){
                    camera?.delegate = self
                }
            }
            else{
                self.showAlertViewWithTittle(title: "Error connecting product", WithMessage: "")
            }
        }
        else{
            self.showAlertViewWithTittle(title: "Product not recognised", WithMessage: "")
            //NSLog("Producto desconectado \n")
        }
    }
    
    func productDisconnected() {
        let camera = fetchCamera()
        
        if (camera != nil){
            camera?.delegate = nil
        }
    }
    
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        // vacio
    }
    
    //MARK: Camera
    
    func fetchCamera() ->DJICamera? {
        if (DJISDKManager.product() == nil){
            return nil
        }
        // if drone
        if DJISDKManager.product() is DJIAircraft{
            return (DJISDKManager.product() as? DJIAircraft)?.camera
        }
        // if camera cool (Not used)
        else if DJISDKManager.product() is DJIHandheld{
            return (DJISDKManager.product() as? DJIHandheld)?.camera
        }
        return nil
    }
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        /*camera.setMode(DJICameraMode.recordVideo) { error in
            self.showAlertViewWithTittle(title: "Set DJICameraModeRecordVideo Failed", WithMessage: error!.localizedDescription)
        }*/
    }
    
    func startRecording(){
        let camera = fetchCamera()
        camera!.setMode(DJICameraMode.recordVideo) { error in
            if(error != nil){
                self.showAlertViewWithTittle(title: "Set DJICameraModeRecordVideo Failed", WithMessage: error!.localizedDescription)
            }
        }
        if camera != nil {
            camera?.startRecordVideo(completion: { error in
                if(error != nil){
                    self.showAlertViewWithTittle(title: "Start Record Video Error", WithMessage: error!.localizedDescription)
                }
            })
        }
    }
    
    func stopRecording(){
        let camera = fetchCamera()
        if camera != nil {
            camera?.stopRecordVideo(completion: { error in
                if(error != nil){
                    self.showAlertViewWithTittle(title: "Stop Record Video Error", WithMessage: error!.localizedDescription)
                }
            })
        }
    }
    
    //MARK:Buttons Functions
    
    func addBtnAction(_ button: UIButton?, inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        if isEditingPoints {
            isEditingPoints = false
            //finishBtnActions()
            //multiController!.selectMultiFly(password: "prueb")
            button?.setTitle("Add", for: .normal)
            let icon7: UIImage
            if #available(iOS 13.0, *) {
                let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
                icon7 = UIImage.init(systemName: "skew", withConfiguration: smallconfig)!
            } else {
                icon7 = UIImage.init(named: "add-icon.png")!
            }
            button?.setImage(icon7, for: .normal)
            button?.imageView?.contentMode = .scaleAspectFit
            button?.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        } else {
            isEditingPoints = true
            button?.setTitle("Finish", for: .normal)
            let icon4: UIImage
            if #available(iOS 13.0, *) {
                let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
                icon4 = UIImage.init(systemName: "checkmark.rectangle.fill", withConfiguration: smallconfig)!
            } else {
                icon4 = UIImage.init(named: "finish-icon.png")!
            }
            button?.setImage(icon4, for: .normal)
            button?.imageView?.contentMode = .scaleAspectFit
            button?.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        }
    }
    
    func clearBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        mapController?.cleanAllPointsWithMapView(with: mapView, and: pathController!)
        //isConfigured = false
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
                // Camera starts recording
                self.startRecording()
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
                // Camera stops recording
                self.stopRecording()
            }
        })
    }
    
    func multiFlyBtnAction(inButtonVC BtnVC: StartViewController?) {
        //multiController!.postMultiFly(pathController: pathController!, mapController: mapController!)
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
        
        let wayPoints = pathController!.fly_points
         
        if(pathController!.fly_points.count < 2){
            showAlertViewWithTittle(title: "No or not enought waypoints for mission", WithMessage: "")
        }
        else{
            waypointConfigVC!.view.alpha = 1
            ButtonVC!.view.alpha = 0
            if(self.waypointMission != nil){
                self.waypointMission?.removeAllWaypoints()
                //isConfigured = false
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
    
    func tokenBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?) {
        insertTokenVC!.view.alpha = 1
        ButtonVC!.view.alpha = 0
    }
    
    func cancel2BtnAction(inButtonVC BtnVC: TokenViewController?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.insertTokenVC!.view.alpha = 0
            self.ButtonVC!.view.alpha = 1
        })
    }
    
    func requestBtnAction(textField: UITextField?,inButtonVC BtnVC: TokenViewController?) {
        multiController!.selectMultiFly(password: (textField?.text)! as String, Djiroot: self)
        
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
        
        /*for i1 in 0..<pathController!.fly_points_p1.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points_p1[i1]
            ano.title = String(i1)
            mapView.addAnnotation(ano)
            
            if(i1 < pathController!.fly_points_p1.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points_p1[i1], pathController!.fly_points_p1[i1+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }
        
        for i2 in 0..<pathController!.fly_points_p2.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points_p2[i2]
            ano.title = String(i2)
            mapView.addAnnotation(ano)
            
            if(i2 < pathController!.fly_points_p2.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points_p2[i2], pathController!.fly_points_p2[i2+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }
        
        for i3 in 0..<pathController!.fly_points_p11.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points_p11[i3]
            ano.title = String(i3)
            mapView.addAnnotation(ano)
            
            if(i3 < pathController!.fly_points_p1.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points_p11[i3], pathController!.fly_points_p11[i3+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }
        
        for i4 in 0..<pathController!.fly_points_p21.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points_p21[i4]
            ano.title = String(i4)
            mapView.addAnnotation(ano)
            
            if(i4 < pathController!.fly_points_p21.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points_p21[i4], pathController!.fly_points_p21[i4+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }
        
        for i5 in 0..<pathController!.fly_points_p31.count{
            
            // Creamos Annotation
            let ano: MKPointAnnotation = MKPointAnnotation()
            ano.coordinate = pathController!.fly_points_p31[i5]
            ano.title = String(i5)
            mapView.addAnnotation(ano)
            
            if(i5 < pathController!.fly_points_p31.count-1){
                // Creamos lineas
                let lines: [CLLocationCoordinate2D] = [pathController!.fly_points_p31[i5], pathController!.fly_points_p31[i5+1]]
                let line = MKPolyline.init(coordinates: lines, count: 2)
                mapView.addOverlay(line)
            }
        }*/
    }
    
    func cancelBtnAction(inButtonVC BtnVC: ConfigViewController?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC!.view.alpha = 0
            self.ButtonVC!.view.alpha = 1
        })
    }
    
    func finishBtnAction(inButtonVC BtnVC: ConfigViewController?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC?.view.alpha = 0
            self.ButtonVC!.view.alpha = 1
        })
        
        let altitude = (waypointConfigVC!.altitudeTextField.text! as NSString).floatValue
        let AFS = (waypointConfigVC!.autoFlightSpeedTextField.text! as NSString).floatValue
        let MFS = (waypointConfigVC!.maxFlightSpeedTextField.text! as NSString).floatValue
        let heading = waypointConfigVC!.headingSegmentedControl.selectedSegmentIndex
        let AAF = waypointConfigVC!.actionSegmentedControl.selectedSegmentIndex
        
        if(waypointMission != nil){
            
        var token1 = ""
        var token2 = ""
        var token3 = ""
        
        if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 1){
            if(waypointMission != nil){
                waypointMission!.removeAllWaypoints()
            }
            
            let wayPoints = pathController!.fly_points_p1
            
            for i in 0..<wayPoints.count{
                let location = wayPoints[i]
                let coordinate = location
                if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location)
                    waypointMission!.add(waypoint)
                }
            }
            
            for i in 0..<waypointMission!.waypointCount{
                let waypoint = waypointMission?.waypoint(at: i)
                waypoint?.altitude = altitude  //MARK: ALTITUD DE WAYPOINT
            }
            
            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            self.showAlertViewWithTittle(title: "DRONES: ", WithMessage: "TOKEN 2: \(token1)")
        }
        else if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 2){
            if(waypointMission != nil){
                waypointMission!.removeAllWaypoints()
            }
            
            let wayPoints = pathController!.fly_points_p11
            
            for i in 0..<wayPoints.count{
                let location = wayPoints[i]
                let coordinate = location
                if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location)
                    waypointMission!.add(waypoint)
                }
            }
            
            for i in 0..<waypointMission!.waypointCount{
                let waypoint = waypointMission?.waypoint(at: i)
                waypoint?.altitude = altitude  //MARK: ALTITUD DE WAYPOINT
            }
            
            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            token2 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(3)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            self.showAlertViewWithTittle(title: "DRONES: ", WithMessage: "TOKEN 2: \(token1)\n\n TOKEN 3: \(token2)")
        }
        else if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 3){
            if(waypointMission != nil){
                waypointMission!.removeAllWaypoints()
            }
            
            let wayPoints = pathController!.fly_points_p12
            
            for i in 0..<wayPoints.count{
                let location = wayPoints[i]
                let coordinate = location
                if CLLocationCoordinate2DIsValid(coordinate){
                    let waypoint = DJIWaypoint(coordinate: location)
                    waypointMission!.add(waypoint)
                }
            }
            
            for i in 0..<waypointMission!.waypointCount{
                let waypoint = waypointMission?.waypoint(at: i)
                waypoint?.altitude = altitude  //MARK: ALTITUD DE WAYPOINT
            }
            
            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            token2 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(3)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            token3 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(4)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
            self.showAlertViewWithTittle(title: "DRONES: ", WithMessage: "TOKEN 2: \(token1)\n\n TOKEN 3: \(token2)\n\n TOKEN 4: \(token3)")
        }
            
            waypointMission?.maxFlightSpeed = MFS //MARK: VELOCIDAD MAXIMA
            waypointMission?.autoFlightSpeed = AFS //MARK: VELOCIDAD AUTOMATICA
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
                    // Camera stop recording
                    self.stopRecording()
                }
                })
        
                missionOperator()?.uploadMission(completion: { error in
                    if(error != nil){
                        self.showAlertViewWithTittle(title: "UPLOAD MISSION FAILED", WithMessage: error!.localizedDescription)
                    }
                    else{
                        /*var token1 = ""
                        var token2 = ""
                        var token3 = ""
                        
                        if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 1){
                            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                            self.showAlertViewWithTittle(title: "DRONES: ", WithMessage: "TOKEN 2: \(token1)")
                        }
                        else if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 2){
                            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                            token2 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(3)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                        }
                        else if(self.waypointConfigVC!.dronesNumSegmentedControl.selectedSegmentIndex == 3){
                            token1 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(2)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                            token2 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(3)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                            token3 = self.multiController!.postMultiFly(pathController: self.pathController!, mapController: self.mapController!,player: "\(4)", Alt: "\(altitude)", AFS: "\(AFS)", MFS: "\(MFS)", AAF: "\(AAF)", heading: "\(heading)" )
                        }*/
                        self.showAlertViewWithTittle(title: "UPLOAD MISSION FINISHED", WithMessage: "")
                        self.StartVC!.view.alpha = 1
                        //self.isConfigured = true
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
        
        //-------------------------------COLORS----------------------------------------------------------------
        
        /*topBarView = UIView.init()
        topBarView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: topBarView.frame.size.height)
        topBarView.backgroundColor = UIColor.init(displayP3Red: 105/255.0, green: 132/255.0, blue: 201/255.0, alpha: 1)*/
        
        // ------------------------- BUTTONVC -----------------------------------------------------------------
        ButtonVC = ButtonControllerViewController.init(nibName: "ButtonControllerViewController", bundle: Bundle.main)
        ButtonVC?.view.frame = CGRect(x: -10, y: CGFloat(Int(topBarView.frame.origin.y + topBarView.frame.size.height + 20)), width: ButtonVC!.view.frame.size.width, height: ButtonVC!.view.frame.size.height)
        ButtonVC!.delegate = self
        view.addSubview(ButtonVC!.view)
        
        // --------------------------------STARTVC-------------------------------------------------------------
        
        StartVC = StartViewController.init(nibName: "StartViewController", bundle: Bundle.main)
        StartVC!.view.alpha = 0
        
        let startVCOriginX: CGFloat = 0
        let startVCOriginY: CGFloat = (view.frame.height - StartVC!.view.frame.height - 20)
        
        StartVC!.view.frame = CGRect(x: startVCOriginX, y: startVCOriginY, width: self.view.frame.size.width, height: StartVC!.view.frame.size.height)
        StartVC!.delegate = self
        view.addSubview(StartVC!.view)
        
        // --------------------------------CONFIGVC-------------------------------------------------------------
        waypointConfigVC = ConfigViewController.init(nibName: "ConfigViewController", bundle: Bundle.main)
        waypointConfigVC!.view.alpha = 0
        waypointConfigVC!.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        let configVCOriginX: CGFloat = (view.frame.width - waypointConfigVC!.view.frame.width) / 2
        let configVCOriginY: CGFloat = (view.frame.height - waypointConfigVC!.view.frame.height) / 2
        
        waypointConfigVC!.view.frame = CGRect(x: configVCOriginX, y: configVCOriginY, width: waypointConfigVC!.view.frame.width, height: waypointConfigVC!.view.frame.height)
        
        waypointConfigVC!.delegate = self
        view.addSubview(waypointConfigVC!.view)
        
        // --------------------------------TOKENVC-------------------------------------------------------------
        insertTokenVC = TokenViewController.init(nibName: "TokenViewController", bundle: Bundle.main)
        insertTokenVC!.view.alpha = 0
        insertTokenVC!.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        let insertTokenOriginX: CGFloat = (view.frame.width - insertTokenVC!.view.frame.width) / 2
        let insertTokenOriginY: CGFloat =  topBarView.frame.height + topBarView.frame.minY + 50
        
        insertTokenVC!.view.frame = CGRect(x: insertTokenOriginX, y: insertTokenOriginY, width: insertTokenVC!.view.frame.width, height: insertTokenVC!.view.frame.height)
        
        insertTokenVC!.delegate = self
        view.addSubview(insertTokenVC!.view)
        
        
        //----------------------------------- iPAD view-----------------------------------------------
        if UIDevice.current.userInterfaceIdiom == .pad {
            waypointConfigVC!.view.center = view.center
            insertTokenVC!.view.center = view.center
        }
        
        //------------------------------- Activity Spinner -------------------------------------------


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
            mapController!.polygonView!.strokeColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
             mapController!.polygonView!.lineWidth = 2.0
             mapController!.polygonView!.fillColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.5)
             return mapController!.polygonView!
           }
           else if overlay is MKCircle {
             mapController!.circleView = MKCircleRenderer(overlay: overlay)
            mapController!.circleView!.strokeColor = UIColor.init(displayP3Red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 0.5)
             mapController!.circleView!.lineWidth = 1.0
            mapController!.circleView!.fillColor = UIColor.init(displayP3Red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 0.5)
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
        
        if(annotation.isKind(of: DJIAircraftAnnotation.self)){
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? DJIAircraftAnnotation)?.annotationView = annoView
            NSLog("LO DIBUJA????")
            return annoView
            
        }
        var marker = MKMarkerAnnotationView()
        
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        
        if let dequedView = (mapView.dequeueReusableAnnotationView(withIdentifier: "marker") as? MKMarkerAnnotationView){
            marker = dequedView
        }
        else{
            marker = MKMarkerAnnotationView.init(annotation: annotation, reuseIdentifier: "marker")
        }
        marker.markerTintColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        marker.canShowCallout = false
        marker.isDraggable = false
        //view?.backgroundColor = UIColor.green
            
        // Sobreescribimos la logica de drag con la nuestra propia
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(handleDrag(gesture:)))
            
        drag.minimumPressDuration = 0 // instant bru
        drag.allowableMovement = .greatestFiniteMagnitude
        marker.addGestureRecognizer(drag)
        /*else{
            marker.annotation = annotation
        }*/
        
        return marker
        
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
    
    
    
    //MARK: MULTIFLY METHODS
    
    func closeWindowCool(){
        UIView.animate(withDuration: 0.25, animations: {
            self.insertTokenVC?.view.alpha = 0
            self.ButtonVC?.view.alpha = 1
        })
    }
    
    func loadData(passwordNameValue: String, polygonNameValue: String, playerNameValue: String, AltNameValue: String, AFSNameValue: String, MFSNameValue: String, AAFNameValue: String, headingNameValue: String){
        
        if(mapController!.editPoints.count > 0){
            mapController!.editPoints.removeAll()
        }
        
        let arr_aux = polygonNameValue.components(separatedBy: "@")
        
        for i in 1..<arr_aux.count{
            let aux2 = arr_aux[i].components(separatedBy: ":")
            let lat = Double(aux2[0])
            let long = Double(aux2[1])
            let location: CLLocation = CLLocation(latitude: lat!, longitude: long!)
            let annotation: MKPointAnnotation = MKPointAnnotation()
            
            annotation.coordinate = location.coordinate
            mapView?.addAnnotation(annotation)
            
            mapController!.editPoints.append(annotation)
        }
        
        mapController!.updatePolygon(with: mapView!, and: pathController!)
        
        if(self.waypointMission != nil){
            self.waypointMission?.removeAllWaypoints()
        }
        else{
            self.waypointMission = DJIMutableWaypointMission()
        }
        var wayPoints: [CLLocationCoordinate2D] = []
        
        if(playerNameValue == "2"){
            wayPoints = pathController!.fly_points_p2
        }
        else if(playerNameValue == "3"){
            wayPoints = pathController!.fly_points_p31
        }
        else if(playerNameValue == "4"){
            wayPoints = pathController!.fly_points_p42
        }
        
        for i in 0..<wayPoints.count{
             let location = wayPoints[i]
             let coordinate = location
             if CLLocationCoordinate2DIsValid(coordinate){
                 let waypoint = DJIWaypoint(coordinate: location)
                 waypointMission!.add(waypoint)
             }
         }
        
        for i in 0..<waypointMission!.waypointCount{
            let waypoint = waypointMission?.waypoint(at: i)
            waypoint!.altitude = Float(AltNameValue)!  //MARK: ALTITUD DE WAYPOINT
        }
        
        waypointMission!.maxFlightSpeed = Float(MFSNameValue)! //MARK: VELOCIDAD MAXIMA
        waypointMission!.autoFlightSpeed = Float(AFSNameValue)! //MARK: VELOCIDAD AUTOMATICA
        waypointMission!.headingMode = DJIWaypointMissionHeadingMode(rawValue: DJIWaypointMissionHeadingMode.RawValue(headingNameValue)!)! as DJIWaypointMissionHeadingMode //MARK: HEADING AUTO
        waypointMission!.finishedAction = DJIWaypointMissionFinishedAction(rawValue: DJIWaypointMissionFinishedAction.RawValue(AAFNameValue)!)! as DJIWaypointMissionFinishedAction //MARK: ACCION AL FINAL
        
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
                self.multiController?.deleteMultifly(password: passwordNameValue)
                //self.isConfigured = true
            }
        })
        
        
    }
    
    
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
   
    
}
    

