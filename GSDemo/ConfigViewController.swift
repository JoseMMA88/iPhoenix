//
//  ConfigViewController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 07/05/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

@objc protocol ConfigViewControllerDelegate: NSObjectProtocol {
    func cancelBtnAction(inButtonVC BtnVC: ConfigViewController?)
    func finishBtnAction(inButtonVC BtnVC: ConfigViewController?)
}

class ConfigViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!
    
    //MARK: Vars
    weak var delegate: ConfigViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    //MARK: Buttons Methods
    @IBAction func cancelBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.cancelBtnAction(inButtonVC:))){
            delegate!.cancelBtnAction(inButtonVC: self)
        }
    }
    
    @IBAction func finishBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.finishBtnAction(inButtonVC:))){
            delegate!.finishBtnAction(inButtonVC: self)
        }
    }
    
    
    //MARK: Custom Methods
    func initUI(){
        altitudeTextField.text = "20"//Set altitude
        autoFlightSpeedTextField.text = "8" //Set auto speed
        maxFlightSpeedTextField.text = "10" //Set max speed
        actionSegmentedControl.selectedSegmentIndex = 1
        headingSegmentedControl.selectedSegmentIndex = 0
    }
    
    
}
