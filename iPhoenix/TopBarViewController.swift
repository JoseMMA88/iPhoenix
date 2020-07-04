//
//  TopBarViewController.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 03/07/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import UIKit


/*@objc protocol TopBarViewControllerDelegate: NSObjectProtocol {
    func updatePar(mode: UILabel?, gps: UILabel?, hs: UILabel?, vs: UILabel?, altitudeLabel: UILabel?)
}*/

class TopBarViewController: UIViewController {
    
    //MARK: Vars
    //weak var delegate: TopBarViewControllerDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var modeText: UILabel!
    @IBOutlet weak var gpsText: UILabel!
    @IBOutlet weak var hsText: UILabel!
    @IBOutlet weak var vsText: UILabel!
    @IBOutlet weak var altitudeText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        initUI()

    }
    
    
    func initStyle(){
        view.backgroundColor = UIColor.init(named: "background-color")?.withAlphaComponent(0.78)
        //view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.init(displayP3Red: 148/255.0, green: 148/255.0, blue: 146/255.0, alpha: 0.78).cgColor
        //view.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        //view.layer.shadowOpacity = 0.8
        
        modeText.textColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        gpsText.textColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        vsText.textColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        hsText.textColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        altitudeText.textColor = UIColor.init(displayP3Red: 63/255.0, green: 106/255.0, blue: 215/255.0, alpha: 0.95)
        
        imageView.image = UIImage.init(named: "app-icon")
        imageView.frame = CGRect(x: ((UIScreen.main.bounds.maxX - imageView.frame.width) / 2) + 3, y: imageView.frame.minY, width: imageView.frame.width, height: imageView.frame.height)
        self.view.addSubview(imageView)
        
        altitudeLabel.alpha = 0
        altitudeText.alpha = 0
        
        gpsLabel.alpha = 0
        gpsText.alpha = 0
        
        hsLabel.alpha = 0
        hsText.alpha = 0
        
        vsLabel.alpha = 0
        vsText.alpha = 0
        
        modeLabel.alpha = 0
        modeText.alpha = 0
    }
    
    func initUI(){
        modeLabel.text     = "N/A"
        gpsLabel.text      = "0"
        vsLabel.text       = "0.0 M/S"
        hsLabel.text       = "0.0 M/S"
        altitudeLabel.text = "0 M"
    }
    
    /*func updatePar(mode: UILabel?, gps: UILabel?, hs: UILabel?, vs: UILabel?, altitudeLabel: UILabel?){
        if delegate!.responds(to: #selector(delegate!.updatePar(mode:gps:hs:vs:altitudeLabel:))) {
            delegate!.updatePar(mode: modeLabel, gps: gpsLabel, hs: hsLabel, vs: vsLabel, altitudeLabel: altitudeLabel)
        }
    }*/

}
