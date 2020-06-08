//
//  MultiflyViewController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 08/06/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

@objc protocol MultiflyViewControllerDelegate: NSObjectProtocol {
    func okBtnAction(inButtonVC BtnVC: MultiflyViewController?)
}

class MultiflyViewController: UIViewController {
    
    //MARK: Vars
    weak var delegate: MultiflyViewControllerDelegate?
    
    //MARK: OUTLET
    @IBOutlet weak var token2Label: UILabel!
    @IBOutlet weak var token22Label: UILabel!
    @IBOutlet weak var token3Label: UILabel!
    @IBOutlet weak var token33Label: UILabel!
    @IBOutlet weak var token4Label: UILabel!
    @IBOutlet weak var token44Label: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Buttons Methods
    @IBAction func okBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.okBtnAction(inButtonVC:))){
            delegate!.okBtnAction(inButtonVC: self)
        }
    }


}
