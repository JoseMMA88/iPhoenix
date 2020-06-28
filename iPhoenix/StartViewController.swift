//
//  StartViewController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 11/05/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

@objc protocol StartViewControllerDelegate: NSObjectProtocol {
    func startBtnAction(inButtonVC BtnVC: StartViewController?)
    func stopBtnAction(inButtonVC BtnVC: StartViewController?)
    func multiFlyBtnAction(inButtonVC BtnVC: StartViewController?)
}

class StartViewController: UIViewController {
    
    //MARK: Vars
    weak var delegate: StartViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: Buttons Methods
    @IBAction func startBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.startBtnAction(inButtonVC:))){
            delegate!.startBtnAction(inButtonVC: self)
        }
    }
    
    @IBAction func stopBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.stopBtnAction(inButtonVC:))){
            delegate!.stopBtnAction(inButtonVC: self)
        }
    }
    
    @IBAction func resumeBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.multiFlyBtnAction(inButtonVC:))){
             delegate!.multiFlyBtnAction(inButtonVC: self)
         }
    }
    
}
