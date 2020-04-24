//
//  FlyPathController.swift
//  GSDemo
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
    
    
    var points: [MKAnnotation] = [] // Aristas del poligono
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
    init(mapView: MKMapView?) {
        super.init()
        self.mapView = mapView!
    }
    
    func getDroneLocation(droneLocation: CLLocationCoordinate2D){
        self.droneLocation = droneLocation
    }
    
    func updatePolygon(){
        NSLog("UpdatePolygon")
        // Si hay polygon lo borramos
        if (polygon != nil){
            mapView!.removeOverlay(polygon!)
        }
        
        // Creamos un nuevo poligono
        let coords = points.map { $0.coordinate }
        polygon = MKPolygon.init(coordinates: coords, count: coords.count)
        
        //NSLog(String(regionArea(locations: coords)))
       
        mapView!.addOverlay(polygon!)
        
        // TRIANGULACION
        if(points.count > 2){
            if(center != nil){
                mapView!.removeOverlay(center!)
            }
            if(path_coord.count > 0){
                path_coord.removeAll()
                //arr_circle_auxs2.removeAll()
            }
            let centr = polygon!.coordinate
            
            // Creamos el circulo
            center = MKCircle.init(center: centr, radius: 5)
            mapView!.addOverlay(center!)
            
            //Triangulamos
            updateTriangles(poli: polygon!)
        }
        
        // Buscamos y dibujamos el punto mas cercano al dron
        if(path_coord.count > 0 && points.count > 2){
            for i in 0..<points.count{
                path_coord.append(points[i].coordinate)
            }
            updateCircle(coord: findStartWaypoint()!)
            
            // Anyadimos el punto mas cercano al path de vuelo
            // y creamos el flight path
            /*NSLog("----------------------------------------------------")
            NSLog("Path Coords: ")
            NSLog(String(path_coord.count))*/
            createFlightPath()
        }
    }
    
    
    // Draw MKCircle
    func updateCircle(coord: CLLocationCoordinate2D){
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
    func updateTriangles(poli: MKPolygon){
        var aux_points: [CLLocationCoordinate2D] = []
        
        // Añadimos el centro del poligono al path
        addPointoPath(point: poli.coordinate)
        
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
        for i in 0..<points.count{
            if(i == 0){
                aux_points.append(poli.coordinate)
            }
            var aux_arr: [CLLocationCoordinate2D] = []
            aux_arr.append(poli.coordinate)
            
            let p1 = points[i > 0 ? i - 1 : points.count - 1]
            aux_arr.append(p1.coordinate)
            aux_points.append(p1.coordinate)
            
            let p2 = points[i]
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
            addPointoPath(point: triangles[h].coordinate)
            
            
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
                addPointoPath(point: aux_trian.coordinate)
            }
        }
        
        for h2 in 0..<triangles2.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles2[h2].coordinate)
            
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
                addPointoPath(point: aux_trian.coordinate)
            }
        }
        
        
        for h3 in 0..<triangles3.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles3[h3].coordinate)
            
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
                addPointoPath(point: aux_trian.coordinate)
            }
        }
        
        for h4 in 0..<triangles4.count{
            //Anyade y dibuja circulos
            addPointoPath(point: triangles4[h4].coordinate)
            
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
                addPointoPath(point: aux_trian.coordinate)
            }
        }
    }
    
    
    // Find the closest waypoint to DronLocation
    func findStartWaypoint() -> CLLocationCoordinate2D?{
        if(points.count>0){
            var aux = points[0]
            let p1 = MKMapPoint(droneLocation)
            let p2 = MKMapPoint(points[0].coordinate)
            var dis = p1.distance(to: p2)
            for i in 0..<points.count {
                let dis2 = p1.distance(to: MKMapPoint(points[i].coordinate))
                if(dis2 < dis){
                    aux = points[i]
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
                    //NSLog(String(dis))
                }

            }
            
            if(polygonView != nil){
                let mapPoint = MKMapPoint(point)
                let cgpoint = polygonView!.point(for: mapPoint)
            
                if(distancia == true && polygonView!.path.contains(cgpoint)){
                    let center2 = MKCircle.init(center: point, radius: 5)
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
    func createFlightPath(){
        var aux_coords: [CLLocationCoordinate2D] = path_coord
        var derecha_coords: [CLLocationCoordinate2D] = []
        var izquierda_coords: [CLLocationCoordinate2D] = []
        var enco: Bool = false
        if(fly_points.count>0){
            fly_points.removeAll()
        }
        
        // Empezamos por el punto mas cercano al dron
        fly_points.append(findStartWaypoint()!)
        
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
        
        var aux0 = points[0].coordinate
        let p1 = MKMapPoint(findStartWaypoint()!)
        let p2 = MKMapPoint(points[0].coordinate)
        var dis = p1.distance(to: p2)
        for n0 in 0..<points.count{
            let dis2 = p1.distance(to: MKMapPoint(points[n0].coordinate))
            if(dis2 > dis){
                aux0 = points[n0].coordinate
                dis = dis2
            }
        }

        if(pointsLatPosition(coord_guia: findStartWaypoint()!, coord2: aux0) == 2){
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
                        enco2=true
                    }
                    i2+=1
                }
                n+=1
            }
        }
        
        /*NSLog("-----------------------------------------------------")
        for i3 in 0..<fly_points.count{
            NSLog(String(fly_points[i3].latitude))
            NSLog(String(fly_points[i3].longitude))
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
    
    
    func cleanAllPoints(aircraft: DJIAircraftAnnotation?){
        fly_points.removeAll()
        points.removeAll()
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
        
        let annos: NSArray = NSArray.init(array: mapView!.annotations)
        for i in 0..<annos.count{
            weak var ann = annos[i] as? MKAnnotation
            if (!(ann!.isEqual(aircraft))){
                mapView?.removeAnnotation(ann!)
            }
        }
    }
    
    
}
