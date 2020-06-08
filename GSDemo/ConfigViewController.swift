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
    @IBOutlet weak var dronesNumSegmentedControl: UISegmentedControl!
    
    
    //MARK: Vars
    weak var delegate: ConfigViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        //multiFlyVC!.view.alpha = 0
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
        altitudeTextField.keyboardType = UIKeyboardType.numberPad
        autoFlightSpeedTextField.keyboardType = UIKeyboardType.numberPad
        maxFlightSpeedTextField.keyboardType = UIKeyboardType.numberPad
        altitudeTextField.text = "15"//Set altitude
        autoFlightSpeedTextField.text = "6" //Set auto speed
        maxFlightSpeedTextField.text = "8" //Set max speed
        actionSegmentedControl.selectedSegmentIndex = 1
        headingSegmentedControl.selectedSegmentIndex = 0
        dronesNumSegmentedControl.selectedSegmentIndex = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
