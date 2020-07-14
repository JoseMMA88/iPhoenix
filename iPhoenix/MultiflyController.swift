//
//  MultiflyController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 06/06/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

class MultiflyController: UIViewController {
    //MARK: VARS
    private let myUrl = URL(string: "https://almasalvajeagencia.com/multifly.php");

    private var passwordNameValue: String = ""
    private var playerNameValue: String = ""
    private var polygonNameValue: String = ""
    private var AltNameValue: String = ""
    private var AFSNameValue: String = ""
    private var MFSNameValue: String = ""
    private var AAFNameValue: String = ""
    private var headingNameValue: String = ""
    
    
    //MARK: FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    
    func postMultiFly(pathController:FlyPathController!, mapController:DJIMapControler!, player: String, Alt: String, AFS: String, MFS: String, AAF: String, heading: String)-> String{
                
           var request = URLRequest(url:myUrl!)
                
           request.httpMethod = "POST"
           
           let password = randomString(length: 5)
           let fun = "INSERT"
           
           var polygon = ""
           for n in 0..<mapController!.editPoints.count{
               let lat = mapController!.editPoints[n].coordinate.latitude
               let long = mapController!.editPoints[n].coordinate.longitude
               polygon = polygon + "@\(lat):\(long)"
           }
        
           
           let postString = "password=\(password)&polygon=\(polygon)&player=\(player)&fun=\(fun)&Alt=\(Alt)&AFS=\(AFS)&MFS=\(MFS)&AAF=\(AAF)&heading=\(heading)"
           
           //Concatenar variables
           request.httpBody = postString.data(using: String.Encoding.utf8)
           
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
           
        return password
    }
    
    func selectMultiFly(password: String, Djiroot: DJIRootViewController?){
    
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
                        if(parseJSON["password"] as? String ?? "" != ""){
                            self.passwordNameValue = parseJSON["password"] as! String
                            print("Password: \(String(self.passwordNameValue))")

                            self.polygonNameValue = parseJSON["polygon"] as! String
                            print("Polygon: \(String(self.polygonNameValue))")
                        
                            self.playerNameValue = parseJSON["player"] as! String
                            print("Player: \(String(self.playerNameValue))")
                            
                            self.AltNameValue = parseJSON["Alt"] as! String
                            print("Alt: \(String(self.AltNameValue))")
                        
                            self.AFSNameValue = parseJSON["AFS"] as! String
                            print("AFS: \(String(self.AFSNameValue))")
                        
                            self.MFSNameValue = parseJSON["MFS"] as! String
                            print("MFS: \(String(self.MFSNameValue))")

                            self.AAFNameValue = parseJSON["AAF"] as! String
                            print("AAF: \(String(self.AAFNameValue))")
                            
                            self.headingNameValue = parseJSON["heading"] as! String
                            print("Heading: \(String(self.headingNameValue))")
                            Djiroot!.closeWindowCool()
                            Djiroot!.loadData(passwordNameValue: self.passwordNameValue, polygonNameValue: self.polygonNameValue, playerNameValue: self.playerNameValue, AltNameValue: self.AltNameValue, AFSNameValue: self.AFSNameValue, MFSNameValue: self.MFSNameValue, AAFNameValue: self.AAFNameValue, headingNameValue: self.headingNameValue)
                        }
                        else{
                            Djiroot!.showAlertViewWithTittle(title: "TOKEN ERROR!", WithMessage: "The data could not be received")
                        }
                    }
                }
            }
            catch {
                print("JSON Error: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }
    
    func deleteMultifly(password: String){
                
           var request = URLRequest(url:myUrl!)
                
           request.httpMethod = "POST"// Metodo post

           let fun = "DELETE"
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
           }
           task.resume()
        
    }
       
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @objc private func dismissKeyboard() {
           view.endEditing(true)
       }
       
    
}
