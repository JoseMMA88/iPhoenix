//
//  TokenViewController.swift
//  iPhoenix
//
//  Created by Jose Manuel Malagón Alba on 09/06/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit

@objc protocol InsertTokenViewControllerDelegate: NSObjectProtocol {
    func cancel2BtnAction(inButtonVC BtnVC: TokenViewController?)
    func requestBtnAction(textField: UITextField? ,inButtonVC BtnVC: TokenViewController?)
}

class TokenViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: OUTLETS
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var cancel2Btn: UIButton!

    
    //MARK: Vars
    weak var delegate: InsertTokenViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }

    @IBAction func cancel2BtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.cancel2BtnAction(inButtonVC:))){
            delegate!.cancel2BtnAction(inButtonVC: self)
        }
    }
    
    @IBAction func requestBtnAction(_ sender: Any) {
        if delegate!.responds(to: #selector(delegate!.requestBtnAction(textField:inButtonVC:))){
            delegate!.requestBtnAction(textField: tokenTextField, inButtonVC: self)
        }
    }
    
    func initUI(){
        tokenTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        tokenTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard  let textFieldText = tokenTextField.text, let rangeOfTextReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 5
    }
    
    

}
