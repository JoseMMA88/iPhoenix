//
//  FlyPathController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 24/04/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class FlyPathController: NSObject{
    
    //MARK:VARs
    var mapView: MKMapView?
    var polygon: MKPolygon?
    var polygonView: MKPolygonRenderer?
    var circle: MKCircle?
    var circlee: MKCircle?
    var circleView: MKCircleRenderer?
    var center: MKCircle?
    
    
    //var points: [MKAnnotation] = [] // Aristas del poligono
    var startLocation: CGPoint?
    var droneLocation: CLLocationCoordinate2D!
    var d: Double = 0.00015
    
    // Calcular area
    var kEarthRadius = 6378137.0 //Radio en el ecuador de la tierra
    
    // Puntos del perimetro del circulo
    var peripoints: [CLLocationCoordinate2D] = []
    var arr_circle_auxs: [MKCircle] = []
    
    // Path
    var fly_points: [CLLocationCoordinate2D] = []
    var fly_points_p1: [CLLocationCoordinate2D] = []
    var fly_points_p2: [CLLocationCoordinate2D] = []
    var fly_points_p11: [CLLocationCoordinate2D] = []
    var fly_points_p21: [CLLocationCoordinate2D] = []
    var fly_points_p31: [CLLocationCoordinate2D] = []
    var fly_points_p12: [CLLocationCoordinate2D] = []
    var fly_points_p22: [CLLocationCoordinate2D] = []
    var fly_points_p32: [CLLocationCoordinate2D] = []
    var fly_points_p42: [CLLocationCoordinate2D] = []
    var triangles: [MKPolygon] = []
    var triangles2: [MKPolygon] = []
    var triangles3: [MKPolygon] = []
    var triangles4: [MKPolygon] = []
    var triangles5: [MKPolygon] = []
    var path_coord: [CLLocationCoordinate2D] = []
    var arr_circle_auxs2: [MKCircle] = []
    
    // Debug visual
    var routeLineView: MKPolylineRenderer?
    var annotations: [MKAnnotation] = []
    
    //Variables dron
    var kradio: Int = 15
    
    // Init a FlyPathController instance
    override init() {
        super.init()
    }
    
   
    // Find the closest waypoint to DronLocation
    func findStartWaypoint(points: [MKAnnotation]?) -> CLLocationCoordinate2D?{
        if(points!.count>0){
            var aux = points![0]
            let p1 = MKMapPoint(droneLocation)
            let p2 = MKMapPoint(points![0].coordinate)
            var dis = p1.distance(to: p2)
            for i in 0..<points!.count {
                let dis2 = p1.distance(to: MKMapPoint(points![i].coordinate))
                if(dis2 < dis){
                    aux = points![i]
                    dis = dis2
                }
            }
            return aux.coordinate
        }
        else{
            return nil
        }
    }
    
    
    // Añade una coordenada a la array de coordenas path_coords
    func addPointoPath(point: CLLocationCoordinate2D){
        var distancia = true
        
        if(path_coord.count == 0){
            path_coord.append(point)
        }
        else{
            let p2 = MKMapPoint(point)
            for i in 0..<path_coord.count{
                let p1 = MKMapPoint(path_coord[i])
                let dis = p2.distance(to: p1)
                
                if(dis < CLLocationDistance(kradio)){
                    distancia = false
                }

            }
            
            if(polygonView != nil){
                let mapPoint = MKMapPoint(point)
                let cgpoint = polygonView!.point(for: mapPoint)
            
                if(distancia == true && polygonView!.path.contains(cgpoint)){
                    let center2 = MKCircle.init(center: point, radius: 3)
                    mapView!.addOverlay(center2)
                
                    // Añadimos los puntos medios al path
                    arr_circle_auxs2.append(center2)
                    path_coord.append(point)
                    distancia = false
                }
            }
        }
    }
    
    
    // Ordena la array path_coords dependiendo de cual sea el punto de inicio
    func createFlightPath(with editPoints: [MKAnnotation]){
        var player: Int = 2 // 2 players
        var player1: Int = 2 // 3 players
        var player2: Int = 2 // 4 players
        var aux_coords: [CLLocationCoordinate2D] = path_coord
        var derecha_coords: [CLLocationCoordinate2D] = []
        var izquierda_coords: [CLLocationCoordinate2D] = []
        var enco: Bool = false
        if(fly_points.count>0){
            fly_points.removeAll()
        }
        
        if(fly_points_p1.count>0){
            fly_points_p1.removeAll()
        }
        
        if(fly_points_p2.count>0){
            fly_points_p2.removeAll()
        }
        
        // Empezamos por el punto mas cercano al dron
        fly_points.append(findStartWaypoint(points: editPoints)!)
        fly_points_p1.append(findStartWaypoint(points: editPoints)!)
        fly_points_p11.append(findStartWaypoint(points: editPoints)!)
        fly_points_p12.append(findStartWaypoint(points: editPoints)!)
        
        var i = 0
        while ( i < aux_coords.count && enco == false){
            if(fly_points[0].latitude == aux_coords[i].latitude && fly_points[0].longitude == aux_coords[i].longitude){
                aux_coords.remove(at: i)
                enco=true
            }
            i+=1
        }
        
        // Determinamos la orientacion del recorrido
        var ori = 2 //2 --> Sur-Norte
                    //1 --> Norte-Sur
        
        var aux0 = editPoints[0].coordinate
        let p1 = MKMapPoint(findStartWaypoint(points: editPoints)!)
        let p2 = MKMapPoint(editPoints[0].coordinate)
        var dis = p1.distance(to: p2)
        for n0 in 0..<editPoints.count{
            let dis2 = p1.distance(to: MKMapPoint(editPoints[n0].coordinate))
            if(dis2 > dis){
                aux0 = editPoints[n0].coordinate
                dis = dis2
            }
        }

        if(pointsLatPosition(coord_guia: findStartWaypoint(points: editPoints)!, coord2: aux0) == 2){
            ori = 1
        }

        
        //let rad: CLLocationDistance = CLLocationDistance(kradio) //metros
        
        /*// Creamos el circulo
        circlee = MKCircle.init(center: aux0, radius: rad)
        if (circlee != nil){
            mapView.removeOverlay(circlee!)
        }
        //updatePeriPoints(cent: coord, rad: rad)
        mapView.addOverlay(circlee!)*/
        
        //NSLog("Ori: " + String(ori))
        
        
        let tam = aux_coords.count
        var n = 0
        while(n < tam){
            // Limpiamos
            if(izquierda_coords.count>0){
                izquierda_coords.removeAll()
            }
            if(derecha_coords.count>0){
                derecha_coords.removeAll()
            }
            
            
            
            // Miramos derecha - izquierda
            for n11 in 0..<aux_coords.count{
            if(pointsLongPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == 2 && pointsLatPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == ori ||
                 pointsLatPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == 0){
                derecha_coords.append(aux_coords[n11])
             }
             else if(pointsLongPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == 1 &&
                 pointsLatPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == ori ||
                 pointsLatPosition(coord_guia: fly_points[n], coord2: aux_coords[n11]) == 0){
                 izquierda_coords.append(aux_coords[n11])
             }
            }
            
            if(derecha_coords.count != 0 || izquierda_coords.count != 0){
                // Avanzamos DERECHA
                if(derecha_coords.count>0){
                    var aux = derecha_coords[0]
                    let p1 = MKMapPoint(fly_points[n])
                    let p2 = MKMapPoint(derecha_coords[0])
                    var dis = p1.distance(to: p2)
                    for n112 in 0..<derecha_coords.count{
                        let dis2 = p1.distance(to: MKMapPoint(derecha_coords[n112]))
                        if(dis2 < dis){
                            aux = derecha_coords[n112]
                            dis = dis2
                        }
                    }
                    
                    var i2 = 0
                    var enco2 = false
                    while (i2 < derecha_coords.count && enco2==false){
                        if(aux.latitude == derecha_coords[i2].latitude && aux.longitude == derecha_coords[i2].longitude){
                            derecha_coords.remove(at: i2)
                            fly_points.append(aux)
                            if(player == 2){
                                fly_points_p2.append(aux)
                                player = 1
                            }
                            else{
                                fly_points_p1.append(aux)
                                player = 2
                            }
                            
                            // 3 DRONES
                            if(player1 == 2){
                                fly_points_p21.append(aux)
                                player1 = 3
                            }
                            else if(player1 == 3){
                                fly_points_p31.append(aux)
                                player1 = 1
                            }
                            else if(player1 == 1){
                                fly_points_p11.append(aux)
                                player1 = 2
                            }
                            
                            
                            // 4 DRONES
                            if(player2 == 1){
                                fly_points_p12.append(aux)
                                player2 = 2
                            }
                            else if(player2 == 2){
                                fly_points_p22.append(aux)
                                player2 = 3
                            }
                            else if(player2 == 3){
                                fly_points_p32.append(aux)
                                player2 = 4
                            }
                            else if(player2 == 4){
                                fly_points_p42.append(aux)
                                player2 = 1
                            }
                            enco2=true
                        }
                        i2+=1
                    }
                    
                    var i22 = 0
                    var enco22 = false
                    while (i22 < aux_coords.count && enco22==false){
                        if(aux.latitude == aux_coords[i22].latitude && aux.longitude == aux_coords[i22].longitude){
                            aux_coords.remove(at: i22)
                            enco22=true
                        }
                        i22+=1
                    }
                }
            
                // Avanzamos Izquierda
                else if(izquierda_coords.count>0){
                    var aux = izquierda_coords[0]
                    let p1 = MKMapPoint(fly_points[n])
                    let p2 = MKMapPoint(izquierda_coords[0])
                    var dis = p1.distance(to: p2)
                    for n113 in 0..<izquierda_coords.count{
                        let dis2 = p1.distance(to: MKMapPoint(izquierda_coords[n113]))
                        if(dis2 < dis){
                            aux = izquierda_coords[n113]
                            dis = dis2
                        }
                    }
                    
                    var i2 = 0
                    var enco2 = false
                    while (i2 < izquierda_coords.count && enco2==false){
                        if(aux.latitude == izquierda_coords[i2].latitude && aux.longitude == izquierda_coords[i2].longitude){
                            izquierda_coords.remove(at: i2)
                            fly_points.append(aux)
                            
                            // 2 DRONES
                            if(player == 2){
                                fly_points_p2.append(aux)
                                player = 1
                            }
                            else{
                                fly_points_p1.append(aux)
                                player = 2
                            }
                            
                            // 3 DRONES
                            if(player1 == 2){
                                fly_points_p21.append(aux)
                                player1 = 3
                            }
                            else if(player1 == 3){
                                fly_points_p31.append(aux)
                                player1 = 1
                            }
                            else if(player1 == 1){
                                fly_points_p11.append(aux)
                                player1 = 2
                            }
                            
                            
                            // 4 DRONES
                            if(player2 == 1){
                                fly_points_p12.append(aux)
                                player2 = 2
                            }
                            else if(player2 == 2){
                                fly_points_p22.append(aux)
                                player2 = 3
                            }
                            else if(player2 == 3){
                                fly_points_p32.append(aux)
                                player2 = 4
                            }
                            else if(player2 == 4){
                                fly_points_p42.append(aux)
                                player2 = 1
                            }
                            
                            enco2=true
                        }
                        i2+=1
                    }
                    
                    var i22 = 0
                    var enco22 = false
                    while (i22 < aux_coords.count && enco22==false){
                        if(aux.latitude == aux_coords[i22].latitude && aux.longitude == aux_coords[i22].longitude){
                            aux_coords.remove(at: i22)
                            enco22=true
                        }
                        i22+=1
                    }
                }
                n+=1
            }
            
            else if (derecha_coords.count == 0 && izquierda_coords.count == 0){
                // Avanzamos DELANTE
                var aux = aux_coords[0]
                let p1 = MKMapPoint(fly_points[n])
                let p2 = MKMapPoint(aux_coords[0])
                var dis = p1.distance(to: p2)
                for n1 in 0..<aux_coords.count{
                    let dis2 = p1.distance(to: MKMapPoint(aux_coords[n1]))
                    if(dis2 < dis){
                        aux = aux_coords[n1]
                        dis = dis2
                    }
                }
                var i2 = 0
                var enco2 = false
                while (i2 < aux_coords.count && enco2==false){
                    if(aux.latitude == aux_coords[i2].latitude && aux.longitude == aux_coords[i2].longitude){
                        aux_coords.remove(at: i2)
                        fly_points.append(aux)
                        if(player == 2){
                            fly_points_p2.append(aux)
                            player = 1
                        }
                        else{
                            fly_points_p1.append(aux)
                            player = 2
                        }
                        
                        // 3 DRONES
                        if(player1 == 2){
                            fly_points_p21.append(aux)
                            player1 = 3
                        }
                        else if(player1 == 3){
                            fly_points_p31.append(aux)
                            player1 = 1
                        }
                        else if(player1 == 1){
                            fly_points_p11.append(aux)
                            player1 = 2
                        }
                        
                        
                        // 4 DRONES
                        if(player2 == 1){
                            fly_points_p12.append(aux)
                            player2 = 2
                        }
                        else if(player2 == 2){
                            fly_points_p22.append(aux)
                            player2 = 3
                        }
                        else if(player2 == 3){
                            fly_points_p32.append(aux)
                            player2 = 4
                        }
                        else if(player2 == 4){
                            fly_points_p42.append(aux)
                            player2 = 1
                        }
                        enco2=true
                    }
                    i2+=1
                }
                n+=1
            }
        }
        
        NSLog("-----------------------------------------------------")
        for i3 in 0..<fly_points.count{
            NSLog(String(fly_points[i3].latitude))
            NSLog(String(fly_points[i3].longitude))
        }
        NSLog("-----------------------------------------------------")
        
        /*NSLog("-----------------------------------------------------")
        for i3 in 0..<fly_points_p1.count{
            NSLog(String(fly_points_p1[i3].latitude))
            NSLog(String(fly_points_p1[i3].longitude))
        }
        NSLog("-----------------------------------------------------")
        
        NSLog("-----------------------------------------------------")
        for i3 in 0..<fly_points_p2.count{
            NSLog(String(fly_points_p2[i3].latitude))
            NSLog(String(fly_points_p2[i3].longitude))
        }
        NSLog("-----------------------------------------------------")*/
        
        /*NSLog("-----------------------------------------------------")
        for i4 in 0..<fly_points_p11.count{
            NSLog(String(fly_points_p11[i4].latitude))
            NSLog(String(fly_points_p11[i4].longitude))
        }
        NSLog("-----------------------------------------------------")
        
        NSLog("-----------------------------------------------------")
        for i5 in 0..<fly_points_p21.count{
            NSLog(String(fly_points_p21[i5].latitude))
            NSLog(String(fly_points_p21[i5].longitude))
        }
        NSLog("-----------------------------------------------------")
        
        NSLog("-----------------------------------------------------")
        for i6 in 0..<fly_points_p31.count{
            NSLog(String(fly_points_p31[i6].latitude))
            NSLog(String(fly_points_p31[i6].longitude))
        }
        NSLog("-----------------------------------------------------")*/
    }
    
    // Si devuelve 1 esta al Oeste
    // Si devuelve 2 esta al Este
    // Si devuelve 0 esta en la misma Longitud
    func pointsLongPosition(coord_guia: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Int{
        if(coord_guia.longitude < coord2.longitude){
            return 2
        }
        else if(coord_guia.longitude > coord2.longitude){
            return 1
        }
        return 0
    }
    
    
    // Si devuelve 1 esta al Norte
    // Si devuelve 2 esta al Sur
    // Si devuelve 0 esta en la misma Latitud
    func pointsLatPosition(coord_guia: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Int{
        if(coord_guia.latitude < coord2.latitude){
            return 1
        }
        else if(coord_guia.latitude > coord2.latitude){
            return 2
        }
        return 0
    }
    
    
    func cleanAllPoints(){
        fly_points.removeAll()
        peripoints.removeAll()
        arr_circle_auxs.removeAll()
        
        // Path
        triangles.removeAll()
        triangles2.removeAll()
        triangles3.removeAll()
        triangles4.removeAll()
        triangles5.removeAll()
        path_coord.removeAll()
        arr_circle_auxs2.removeAll()
        
        // Debug visual
        annotations.removeAll()
    }
    
    
    func setDroneLocation(droneLocation: CLLocationCoordinate2D!){
        self.droneLocation = droneLocation
    }
    
    
}
