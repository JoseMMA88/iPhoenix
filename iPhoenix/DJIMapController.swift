//
//  DJIMapController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 04/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit
import MapKit

class DJIMapControler: NSObject {
    
    
    
    //MARK: VARs
    var editPoints: [MKAnnotation] = []
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    var polygon: MKPolygon?
    var polygonView: MKPolygonRenderer?
    var arr_circle_auxs2: [MKCircle] = []
    var circle: MKCircle?
    var circlee: MKCircle?
    var circleView: MKCircleRenderer?
    var center: MKCircle?
    
    // Variables dron
    var kradio: Int = 15
    
    // Path
    var triangles: [MKPolygon] = []
    var triangles2: [MKPolygon] = []
    var triangles3: [MKPolygon] = []
    var triangles4: [MKPolygon] = []
    var triangles5: [MKPolygon] = []
    
    
    //MARK: Functions
    
    // Init a DJIMapController instance and create editPoints array
    override init() {
        super.init()
        //editPoints = [CLLocationCoordinate2D]()
    }
    
    // Ad waypoints in Map
    func addPoint(_ point: CGPoint, with mapView: MKMapView?, and pathController: FlyPathController?){
        let coodinate: CLLocationCoordinate2D = ((mapView?.convert(point, toCoordinateFrom: mapView) ?? nil)!)
        let location: CLLocation = CLLocation(latitude: coodinate.latitude, longitude: coodinate.longitude)
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        annotation.coordinate = location.coordinate
        mapView?.addAnnotation(annotation)
        
        editPoints.append(annotation)
        //updatePolygon(with: mapView, and: pathController)
        
    }
    
    
    // Clean all waypoints in Map
    func cleanAllPointsWithMapView(with mapView: MKMapView?, and pathController: FlyPathController){
        mapView!.removeOverlays(mapView!.overlays)
        arr_circle_auxs2.removeAll()
        editPoints.removeAll()
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        for i in 0..<annos.count{
            weak var ann = annos[i] as? MKAnnotation
            if (!(ann!.isEqual(self.aircraftAnnotation))){
                mapView?.removeAnnotation(ann!)
            }
        }
        pathController.cleanAllPoints()
        updatePolygon(with: mapView, and: pathController)
    }
    
    // Return NSArray contains multiple CCLocation objects
    func wayPoints()->NSArray?{
        return self.editPoints as NSArray?
    }
    
    
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
    
    func updatePolygon(with mapView: MKMapView?, and pathController: FlyPathController?){
        NSLog("UpdatePolygon")
        // Si hay polygon lo borramos
        if (polygon != nil){
            mapView!.removeOverlay(polygon!)
        }
        
        // Creamos un nuevo poligono
        let coords = editPoints.map { $0.coordinate }
        polygon = MKPolygon.init(coordinates: coords, count: coords.count)
        
        //NSLog(String(regionArea(locations: coords)))
       
        mapView!.addOverlay(polygon!)
        
        // TRIANGULACION
        if(editPoints.count > 1){
            if(center != nil){
                mapView!.removeOverlay(center!)
            }
            if(pathController!.path_coord.count > 0){
             pathController!.path_coord.removeAll()
                //arr_circle_auxs2.removeAll()
            }
            let centr = polygon!.coordinate
            
            // Creamos el circulo
            center = MKCircle.init(center: centr, radius: 5)
            mapView!.addOverlay(center!)
            
            //Triangulamos
            updateTriangles(poli: polygon!, with: mapView!, and: pathController!)
        }
        
        // Buscamos y dibujamos el punto mas cercano al dron
        if(pathController!.path_coord.count > 0 && editPoints.count > 2){
            for i in 0..<editPoints.count{
                pathController!.path_coord.append(editPoints[i].coordinate)
            }
            updateCircle(coord: pathController!.findStartWaypoint(points: editPoints)!, with: mapView)
            
            // Anyadimos el punto mas cercano al path de vuelo
            // y creamos el flight path
            /*NSLog("----------------------------------------------------")
            NSLog("Path Coords: ")
            NSLog(String(path_coord.count))*/
            pathController!.createFlightPath(with: editPoints)
        }
        else{
            mapView?.removeOverlays(mapView!.overlays)
            pathController?.fly_points.removeAll()
            pathController?.fly_points_p1.removeAll()
            pathController?.fly_points_p2.removeAll()
        }
    }
    
    
    // Draw MKCircle
    func updateCircle(coord: CLLocationCoordinate2D, with mapView: MKMapView?){
        let rad: CLLocationDistance = CLLocationDistance(kradio) //metros
        if (circle != nil){
            mapView!.removeOverlay(circle!)
        }
        
        // Creamos el circulo
        circle = MKCircle.init(center: coord, radius: rad)
        
        //updatePeriPoints(cent: coord, rad: rad)
        mapView!.addOverlay(circle!)
    }
    
    // Calcula el centro del poligono y triangula con los verticles,
    // hace una segunda triangulacion a partir de la primera triangulacion
    func updateTriangles(poli: MKPolygon, with mapView: MKMapView?, and pathController: FlyPathController?){
        var aux_points: [CLLocationCoordinate2D] = []
        
        // Añadimos el centro del poligono al path
        addPointoPath(point: poli.coordinate, with: mapView, and: pathController)
        
        // Borramos los triangulos si existes
        if(triangles.count > 0){
            mapView!.removeOverlays(triangles)
            triangles.removeAll()
            aux_points.removeAll()
            mapView!.removeOverlays(triangles2)
            triangles2.removeAll()
            mapView!.removeOverlays(triangles3)
            triangles3.removeAll()
        }
        // Creamos los primero triangulos
        for i in 0..<editPoints.count{
            if(i == 0){
                aux_points.append(poli.coordinate)
            }
            var aux_arr: [CLLocationCoordinate2D] = []
            aux_arr.append(poli.coordinate)
            
            let p1 = editPoints[i > 0 ? i - 1 : editPoints.count - 1]
            aux_arr.append(p1.coordinate)
            aux_points.append(p1.coordinate)
            
            let p2 = editPoints[i]
            aux_arr.append(p2.coordinate)
            aux_points.append(p2.coordinate)
            
            // Dibujamos los triangulos
            let aux_trian = MKPolygon.init(coordinates: aux_arr, count: 3)
            /*mapView.addOverlay(aux_trian)*/
            triangles.append(aux_trian)
        }
        
        // Borramos circulos
        if(arr_circle_auxs2.count > 0){
            mapView!.removeOverlays(arr_circle_auxs2)
            arr_circle_auxs2.removeAll()
        }
        
        for h in 0..<triangles.count{
            // Anyade y dibuja circulos
            addPointoPath(point: triangles[h].coordinate, with: mapView, and: pathController)
            
            for h1 in 0..<triangles[h].pointCount{
                var aux_arr: [CLLocationCoordinate2D] = []
                
                // Anyadimos puntos
                aux_arr.append(triangles[h].coordinate)
                let p2 = triangles[h].points()[h1 > 0 ? h1 - 1 : triangles[h].pointCount - 1]
                aux_arr.append(p2.coordinate)
                let p3 = triangles[h].points()[h1]
                aux_arr.append(p3.coordinate)
                
                
                // Dibujamos triangulos2
                let aux_trian = MKPolygon.init(coordinates: aux_arr, count: 3)
                //mapView.addOverlay(aux_trian)
                triangles2.append(aux_trian)
                
                // Anyane y dubuja circulos
                addPointoPath(point: aux_trian.coordinate, with: mapView, and: pathController)
            }
        }
        
        for h2 in 0..<triangles2.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles2[h2].coordinate, with: mapView, and: pathController)
            
            for h22 in 0..<triangles2[h2].pointCount{
                var aux_arr: [CLLocationCoordinate2D] = []
                
                // Anyadimos puntos
                aux_arr.append(triangles2[h2].coordinate)
                let p2 = triangles2[h2].points()[h22 > 0 ? h22 - 1 : triangles2[h2].pointCount - 1]
                aux_arr.append(p2.coordinate)
                let p3 = triangles2[h2].points()[h22]
                aux_arr.append(p3.coordinate)
                
                
                // Dibujamos triangulos3
                let aux_trian = MKPolygon.init(coordinates: aux_arr, count: 3)
                triangles3.append(aux_trian)
                
                //Anyade y dibuja circulos
                addPointoPath(point: aux_trian.coordinate, with: mapView, and: pathController)
            }
        }
        
        
        for h3 in 0..<triangles3.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles3[h3].coordinate, with: mapView, and: pathController)
            
            for h33 in 0..<triangles3[h3].pointCount{
                var aux_arr: [CLLocationCoordinate2D] = []
                
                // Anyadimos puntos
                aux_arr.append(triangles3[h3].coordinate)
                let p2 = triangles3[h3].points()[h33 > 0 ? h33 - 1 : triangles3[h3].pointCount - 1]
                aux_arr.append(p2.coordinate)
                let p3 = triangles3[h3].points()[h33]
                aux_arr.append(p3.coordinate)
                
                
                // Dibujamos triangulos3
                let aux_trian = MKPolygon.init(coordinates: aux_arr, count: 3)
                triangles4.append(aux_trian)
                
                //Anyade y dibuja circulos
                addPointoPath(point: aux_trian.coordinate, with: mapView, and: pathController)
            }
        }
        
        for h4 in 0..<triangles4.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles4[h4].coordinate, with: mapView, and: pathController)
            
            for h44 in 0..<triangles4[h4].pointCount{
                var aux_arr: [CLLocationCoordinate2D] = []
                
                // Anyadimos puntos
                aux_arr.append(triangles4[h4].coordinate)
                let p2 = triangles4[h4].points()[h44 > 0 ? h44 - 1 : triangles4[h4].pointCount - 1]
                aux_arr.append(p2.coordinate)
                let p3 = triangles4[h4].points()[h44]
                aux_arr.append(p3.coordinate)
                
                
                // Dibujamos triangulos3
                let aux_trian = MKPolygon.init(coordinates: aux_arr, count: 3)
                triangles5.append(aux_trian)
                
                //Anyade y dibuja circulos
                addPointoPath(point: aux_trian.coordinate, with: mapView, and: pathController)
            }
        }
    }
    
    func addPointoPath(point: CLLocationCoordinate2D, with mapView: MKMapView?, and pathController: FlyPathController?){
        var distancia = true
        
        if(pathController!.path_coord.count == 0){
            pathController!.path_coord.append(point)
        }
        else if(editPoints.count > 2){
            let p2 = MKMapPoint(point)
            for i in 0..<pathController!.path_coord.count{
                let p1 = MKMapPoint(pathController!.path_coord[i])
                let dis = p2.distance(to: p1)
                
                if(dis < CLLocationDistance(kradio)){
                    distancia = false
                }

            }
            
            let mapPoint = MKMapPoint(point)

            let cgpoint = polygonView!.point(for: mapPoint)
            
            if(distancia == true && polygonView!.path.contains(cgpoint)){
                let center2 = MKCircle.init(center: point, radius: 5)
                mapView!.addOverlay(center2)
                
                // Añadimos los puntos medios al path
                arr_circle_auxs2.append(center2)
                pathController!.path_coord.append(point)
                distancia = false
            }

        }

    }
    
    
    
}
