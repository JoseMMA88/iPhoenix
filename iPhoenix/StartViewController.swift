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
    
    //MARK: Outlets
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    
    //MARK: FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()

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
    
    private func initStyle(){
        /*view.backgroundColor = UIColor.init(named: "background-color")
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        view.layer.shadowOpacity = 0.8*/
        view.layer.opacity = 0
        
        let icon = UIImage.init(named: "stop-icon.png")!
        stopBtn.frame.origin = CGPoint.init(x: view.frame.minX + 25, y: 0)
        stopBtn.setImage(icon, for: .normal)
        stopBtn.imageView?.contentMode = .scaleAspectFit
        stopBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        stopBtn.layer.cornerRadius = 8
        stopBtn.backgroundColor = UIColor.init(named: "background-color")
        stopBtn.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        stopBtn.layer.borderWidth = 0.5
        stopBtn.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        stopBtn.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        stopBtn.layer.shadowOpacity = 0.8
        stopBtn.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        
        
        startBtn.frame.origin = CGPoint.init(x: view.frame.maxX - 30, y: 0)
        startBtn.layer.cornerRadius = 20
        startBtn.backgroundColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.layer.borderWidth = 0.5
        startBtn.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        startBtn.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        startBtn.layer.shadowOpacity = 0.8
        startBtn.layer.shadowOffset = CGSize.init(width: 1, height: 1)
    }
    
}
