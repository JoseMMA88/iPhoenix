//
//  DemoUtility.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 10/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//
import UIKit
import DJISDK

func ShowMessage(_ tittle: NSString?,_ message: NSString?,_ target: Any?, _ cancleBtnTittle: NSString?){
    DispatchQueue.main.async(execute: {
        /*_ = UIAlertView.init(title: tittle! as String, message: message! as String, delegate: target as? UIAlertViewDelegate, cancelButtonTitle: cancleBtnTittle as String?, otherButtonTitles: "")*/
        
        NSLog(tittle! as String)
        NSLog(" ")
        NSLog(message! as String)
    })
}



class DemoUtility: NSObject {
    class func fetchFlightController()-> DJIFlightController? {
        var controler: DJIAircraft? = nil
        /*if (DJISDKManager.product() == nil) {
            NSLog("EL PRODUCTO ES NIL \n")
            controler
        }*/
        if(DJISDKManager.product() is DJIAircraft){
            controler = DJISDKManager.product() as? DJIAircraft
            //return controler?.flightController
        }
        return controler?.flightController
    }
}
