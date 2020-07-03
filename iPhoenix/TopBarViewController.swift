//
//  TopBarViewController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 03/07/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit


@objc protocol TopBarViewControllerDelegate: NSObjectProtocol {
    func updatePar(textField: UITextField?)
}

class TopBarViewController: UIViewController {
    
    //MARK: Vars
    weak var delegate: TopBarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        initUI()

    }
    
    
    func initStyle(){
        
    }
    
    func initUI(){
        /*self.modeLabel.text     = "N/A"
        self.gpsLabel.text      = "0"
        self.vsLabel.text       = "0.0 M/S"
        self.hsLabel.text       = "0.0 M/S"
        self.altitudeLabel.text = "0 M"*/
    }

}
