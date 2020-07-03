//
//  ConfigViewController.swift
//  iPhoenix
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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var autoflightLabel: UILabel!
    @IBOutlet weak var actionafterLabel: UILabel!
    @IBOutlet weak var dronesLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var maxflightLabel: UILabel!
    
    
    //MARK: Vars
    weak var delegate: ConfigViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initStyle()
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
    
    func initStyle(){
        view.backgroundColor = UIColor.init(named: "background-color")
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        view.layer.shadowOpacity = 0.8
        
        let lineView = UIView(frame: CGRect(x: 0, y: titleLabel.frame.height, width: view.frame.width, height: 0.4))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        self.view.addSubview(lineView)
        
        let icon: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon = UIImage.init(systemName: "xmark", withConfiguration: smallconfig)!
        } else {
            icon = UIImage.init(named: "cancel-icon.png")!
        }
        cancelButton.setImage(icon, for: .normal)
        cancelButton.imageView?.contentMode = .scaleAspectFit
        cancelButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        cancelButton.layer.cornerRadius = 8
        cancelButton.backgroundColor = UIColor.init(named: "background-color")
        cancelButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        /*cancelButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        cancelButton.layer.shadowOpacity = 0.8
        cancelButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)*/
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        let icon2: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon2 = UIImage.init(systemName: "checkmark", withConfiguration: smallconfig)!
        } else {
            icon2 = UIImage.init(named: "done-icon.png")!
        }
        finishButton.setImage(icon2, for: .normal)
        finishButton.imageView?.contentMode = .scaleAspectFit
        finishButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        finishButton.layer.cornerRadius = 8
        finishButton.backgroundColor = UIColor.init(named: "background-color")
        finishButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        /*finishButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        finishButton.layer.shadowOpacity = 0.8
        finishButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)*/
        finishButton.layer.borderWidth = 0.5
        finishButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        let font = UIFont.systemFont(ofSize: 11)
        actionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        headingSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        titleLabel.textColor = UIColor.init(named: "text-color")
        altitudeLabel.textColor = UIColor.init(named: "text-color")
        autoflightLabel.textColor = UIColor.init(named: "text-color")
        maxflightLabel.textColor = UIColor.init(named: "text-color")
        dronesLabel.textColor = UIColor.init(named: "text-color")
        actionafterLabel.textColor = UIColor.init(named: "text-color")
        headingLabel.textColor = UIColor.init(named: "text-color")
        
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
