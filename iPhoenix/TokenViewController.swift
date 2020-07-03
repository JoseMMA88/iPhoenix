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
    @IBOutlet weak var title2Label: UILabel!
    
    
    
    //MARK: Vars
    weak var delegate: InsertTokenViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
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
    
    func initStyle(){
        view.backgroundColor = UIColor.init(named: "background-color")
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        view.layer.shadowOpacity = 0.8
        
        let lineView = UIView(frame: CGRect(x: 0, y: title2Label.frame.height + 10, width: self.view.frame.width, height: 0.4))
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
        cancel2Btn.setImage(icon, for: .normal)
        cancel2Btn.imageView?.contentMode = .scaleAspectFit
        cancel2Btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        cancel2Btn.layer.cornerRadius = 8
        cancel2Btn.backgroundColor = UIColor.init(named: "background-color")
        cancel2Btn.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        /*cancelButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        cancelButton.layer.shadowOpacity = 0.8
        cancelButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)*/
        cancel2Btn.layer.borderWidth = 0.5
        cancel2Btn.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        
        let icon2: UIImage
        if #available(iOS 13.0, *) {
            let smallconfig = UIImage.SymbolConfiguration.init(scale: .small)
            icon2 = UIImage.init(systemName: "checkmark", withConfiguration: smallconfig)!
        } else {
            icon2 = UIImage.init(named: "done-icon.png")!
        }
        requestBtn.setImage(icon2, for: .normal)
        requestBtn.imageView?.contentMode = .scaleAspectFit
        requestBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
        requestBtn.layer.cornerRadius = 8
        requestBtn.backgroundColor = UIColor.init(named: "background-color")
        requestBtn.setTitleColor(UIColor.init(named: "text-color"), for: .normal)
        /*finishButton.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
        finishButton.layer.shadowOpacity = 0.8
        finishButton.layer.shadowOffset = CGSize.init(width: 1, height: 1)*/
        requestBtn.layer.borderWidth = 0.5
        requestBtn.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 1).cgColor
        
        title2Label.textColor = UIColor.init(named: "text-color")
        
        /*let screenSize = UIScreen.main.bounds
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
        view.sendSubviewToBack(overlay)*/
      
    }
    
    func initUI(){
        tokenTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        tokenTextField.delegate = self
        tokenTextField.placeholder = "Insert token"
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
