//
//  ButtonControllerViewController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 04/05/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

@objc enum ViewMode : Int {
    case _ViewMode
    case _EditMode
}


@objc protocol ButtonViewControllerDelegate: NSObjectProtocol {
    func clearBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func focusMapBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func deleteBtnAction(InGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func configBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func switchto(to mode: ViewMode, inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func debugBtn(inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func addBtnAction(_ button: UIButton?, inGSButtonVC GSBtnVC: ButtonControllerViewController?)
    func tokenBtnAction(inGSButtonVC GSBtnVC: ButtonControllerViewController?)
}


class ButtonControllerViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var configButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tokenButton: UIButton!
    
    
    //MARK: Vars
    var mode: ViewMode?
    weak var delegate: ButtonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initStyle()
        setMode(mode: ViewMode._ViewMode)
        // Do any additional setup after loading the view.
    }
    
    func initStyle(){
        // EDIT BUTTON
        let icon: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon = UIImage.init(systemName: "pencil", withConfiguration: smallconfig)!
        } else {
            icon = UIImage.init(named: "edit-icon.png")!
        }
        editButton.setImage(icon, for: .normal)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        editButton.layer.cornerRadius = 8
        editButton.backgroundColor = UIColor.init(named: "background-color")
        editButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        editButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        editButton.layer.shadowOpacity = 0.8
        editButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        editButton.layer.borderWidth = 0.5
        editButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // FOCUS BUTTON
        let icon3: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon3 = UIImage.init(systemName: "plus.magnifyingglass", withConfiguration: smallconfig)!
        } else {
            icon3 = UIImage.init(named: "focus-icon.png")!
        }
        focusButton.setImage(icon3, for: .normal)
        focusButton.imageView?.contentMode = .scaleAspectFit
        focusButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -18, bottom: 0, right: 0)
        focusButton.layer.cornerRadius = 8
        focusButton.backgroundColor = UIColor.init(named: "background-color")
        focusButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        focusButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        focusButton.layer.shadowOpacity = 0.8
        focusButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        focusButton.layer.borderWidth = 0.5
        focusButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // CLEAN BUTTON
        let icon4: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon4 = UIImage.init(systemName: "trash.fill", withConfiguration: smallconfig)!
        } else {
            icon4 = UIImage.init(named: "clean-icon.png")!
        }
        cleanButton.setImage(icon4, for: .normal)
        cleanButton.imageView?.contentMode = .scaleAspectFit
        cleanButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -18, bottom: 0, right: 0)
        cleanButton.layer.cornerRadius = 8
        cleanButton.backgroundColor = UIColor.init(named: "background-color")
        cleanButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        cleanButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        cleanButton.layer.shadowOpacity = 0.8
        cleanButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        cleanButton.layer.borderWidth = 0.5
        cleanButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // DELETE BUTTON
        let icon5: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon5 = UIImage.init(systemName: "minus.circle.fill", withConfiguration: smallconfig)!
        } else {
            icon5 = UIImage.init(named: "delete-icon.png")!
        }
        deleteButton.setImage(icon5, for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 0)
        deleteButton.layer.cornerRadius = 8
        deleteButton.backgroundColor = UIColor.init(named: "background-color")
        deleteButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        deleteButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        deleteButton.layer.shadowOpacity = 0.8
        deleteButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // CONFIG BUTTON
        let icon6 = UIImage.init(named: "config-icon.png")!
        configButton.setImage(icon6, for: .normal)
        configButton.imageView?.contentMode = .scaleAspectFit
        configButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        configButton.layer.cornerRadius = 8
        configButton.backgroundColor = UIColor.init(named: "background-color")
        configButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        configButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        configButton.layer.shadowOpacity = 0.8
        configButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        configButton.layer.borderWidth = 0.5
        configButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // BACK BUTTON
        let icon2: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon2 = UIImage.init(systemName: "arrow.uturn.left", withConfiguration: smallconfig)!
        } else {
            icon2 = UIImage.init(named: "back-icon.png")!
        }
        backButton.setImage(icon2, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        backButton.layer.cornerRadius = 8
        backButton.backgroundColor = UIColor.init(named: "background-color")
        backButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        backButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        backButton.layer.shadowOpacity = 0.8
        backButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        backButton.layer.borderWidth = 0.5
        backButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // DEBUG BUTTON
        let icon9: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon9 = UIImage.init(systemName: "ant.circle.fill", withConfiguration: smallconfig)!
        } else {
            icon9 = UIImage.init(named: "add-icon.png")!
        }
        debugButton.setImage(icon9, for: .normal)
        debugButton.imageView?.contentMode = .scaleAspectFit
        debugButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        debugButton.layer.cornerRadius = 8
        debugButton.backgroundColor = UIColor.init(named: "background-color")
        debugButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        debugButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        debugButton.layer.shadowOpacity = 0.8
        debugButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        debugButton.layer.borderWidth = 0.5
        debugButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // ADD BUTTON
        let icon7: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon7 = UIImage.init(systemName: "skew", withConfiguration: smallconfig)!
        } else {
            icon7 = UIImage.init(named: "add-icon.png")!
        }
        addButton.setImage(icon7, for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        addButton.layer.cornerRadius = 8
        addButton.backgroundColor = UIColor.init(named: "background-color")
        addButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        addButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        addButton.layer.shadowOpacity = 0.8
        addButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        addButton.layer.borderWidth = 0.5
        addButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        // TOKEN BUTTON
        let icon8: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon8 = UIImage.init(systemName: "arrowtriangle.down.square.fill", withConfiguration: smallconfig)!
        } else {
            icon8 = UIImage.init(named: "insert-icon.png")!
        }
        tokenButton.setImage(icon8, for: .normal)
        tokenButton.imageView?.contentMode = .scaleAspectFit
        tokenButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -14, bottom: 0, right: 0)
        tokenButton.layer.cornerRadius = 8
        tokenButton.backgroundColor = UIColor.init(named: "background-color")
        tokenButton.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        tokenButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        tokenButton.layer.shadowOpacity = 0.8
        tokenButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        tokenButton.layer.borderWidth = 0.5
        tokenButton.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
    }

    func setMode(mode: ViewMode){
        self.mode = mode

        editButton.isHidden = (mode == ViewMode._EditMode)
        focusButton.isHidden = (mode == ViewMode._EditMode)
        
        backButton.isHidden = (mode == ViewMode._ViewMode)
        cleanButton.isHidden = (mode == ViewMode._ViewMode)
        configButton.isHidden = (mode == ViewMode._ViewMode)
        debugButton.isHidden = (mode == ViewMode._ViewMode)
        deleteButton.isHidden = (mode == ViewMode._ViewMode)
        tokenButton.isHidden = (mode == ViewMode._ViewMode)
        addButton.isHidden = (mode == ViewMode._ViewMode)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        setMode(mode: ViewMode._ViewMode)
        /*if delegate!.responds(to:#selector(delegate!.switchto(to:inGSButtonVC:))) {
            delegate!.switchto(to: self.mode!, inGSButtonVC: self)
        }*/
    }
    
    @IBAction func focusmapBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.focusMapBtnAction(inGSButtonVC:))) {
            delegate!.focusMapBtnAction(inGSButtonVC: self)
        }
    }
    
    
    @IBAction func editBtnAction(_ sender: Any) {
        setMode(mode: ViewMode._EditMode)
        if delegate!.responds(to: #selector(delegate!.switchto(to:inGSButtonVC:))) {
            delegate!.switchto(to: self.mode!, inGSButtonVC: self)
        }
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.deleteBtnAction(InGSButtonVC:))){
            delegate!.deleteBtnAction(InGSButtonVC: self)
        }
    }
    
    
    @IBAction func configBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.configBtnAction(inGSButtonVC:))) {
            delegate!.configBtnAction(inGSButtonVC: self)
        }
    }
    
    
    @IBAction func cleanBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.clearBtnAction(inGSButtonVC:))) {
            delegate!.clearBtnAction(inGSButtonVC: self)
        }
    }
    
    
    @IBAction func debugBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.debugBtn(inGSButtonVC:))) {
            delegate!.debugBtn(inGSButtonVC: self)
        }
    }
    
    
    @IBAction func addBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.addBtnAction(_:inGSButtonVC:))) {
            delegate!.addBtnAction(addButton, inGSButtonVC: self)
        }
    }

    @IBAction func tokenBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.tokenBtnAction(inGSButtonVC:))) {
            delegate!.tokenBtnAction(inGSButtonVC: self)
        }
    }
    
    
    
    

}
