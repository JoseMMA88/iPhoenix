//
//  ButtonControllerViewController.swift
//  GSDemo
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
        setMode(mode: ViewMode._ViewMode)
        // Do any additional setup after loading the view.
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
