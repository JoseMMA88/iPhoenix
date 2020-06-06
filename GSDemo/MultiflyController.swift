//
//  MultiflyController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 06/06/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import Foundation
class MultiflyController: NSObject {
    
    override init(){
        super.init()
    }
    
    func postMultiFly(pathController:FlyPathController!, mapController:DJIMapControler!){
           let myUrl = URL(string: "https://almasalvajeagencia.com/multifly.php");
                
           var request = URLRequest(url:myUrl!)
                
           request.httpMethod = "POST"// Metodo post
           
           let password = randomString(length: 5)
           let player = "2"
           let fun = "INSERT"
           var prueba = ""
           for i in 0..<pathController!.fly_points.count{
               let lat = pathController!.fly_points[i].latitude
               let long = pathController!.fly_points[i].longitude
               prueba = prueba + "@\(lat):\(long)"
           }
           
           var polygon = ""
           for n in 0..<mapController!.editPoints.count{
               let lat = mapController!.editPoints[n].coordinate.latitude
               let long = mapController!.editPoints[n].coordinate.longitude
               polygon = polygon + "@\(lat):\(long)"
           }
           
           let postString = "password=\(password)&polygon=\(polygon)&player=\(player)&fun=\(fun)";
           
           //Concatenar variables
           request.httpBody = postString.data(using: String.Encoding.utf8);
           
           //Peticion
           let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
           //Error en la peticion
           if error != nil{
               print("error=\(String(describing: error))")
               return
           }


               print("response = \(String(describing: response))")
           }
           task.resume()
           
       }
    
    func selectMultiFly(password: String){
        let myUrl = URL(string: "https://almasalvajeagencia.com/multifly.php");
                
           var request = URLRequest(url:myUrl!)
                
           request.httpMethod = "POST"// Metodo post

           let fun = "SELECT"
           let postString = "password=\(password)&fun=\(fun)";
           
           //Concatenar variables
           request.httpBody = postString.data(using: String.Encoding.utf8);
           
           //Peticion
           let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
           //Error en la peticion
           if error != nil{
               print("error=\(String(describing: error))")
               return
           }


               print("response = \(String(describing: response))")
               //Pasamos a NSdictionary object
               do {
                   let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                   if let parseJSON = json {
                       DispatchQueue.main.sync {
                           let passwordNameValue = parseJSON["password"] as? String
                           print("Password: \(String(passwordNameValue!))")
                           
                           let polygonNameValue = parseJSON["polygon"] as? String
                           print("Polygon: \(String(polygonNameValue!))")
                           
                           let playerNameValue = parseJSON["player"] as? String
                           print("Player: \(String(playerNameValue!))")
                       }
                   }
               }
               catch {
                   print("JSON Error: \(error.localizedDescription)")
               }
           }
           task.resume()
        
    }
       
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
