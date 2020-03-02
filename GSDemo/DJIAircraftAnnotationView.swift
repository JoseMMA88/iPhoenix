//
//  DJIAircraftAnnotationView.swift
//  GSDemo
//
//  Created by Jose Manuel Malagón Alba on 10/02/2020.
//  Copyright © 2020 Jose Manuel Malagón Alba. All rights reserved.
//

import MapKit


class DJIAircraftAnnotationView: MKAnnotationView{
    //MARK: Vars
    
    
    //MARK: Custom Functions
    
    //Changes de Aricraft rotation
    func updateHeading(_ heading: Float){
        self.transform = CGAffineTransform.identity
        self.transform = CGAffineTransform(rotationAngle: CGFloat(heading))
        
    }
    
    
    //Initializes MKAnnotationView object and variables
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        /*self.isEnabled = false
        self.isDraggable = false*/
        self.image = UIImage.init(named: "aircraft.png")
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
