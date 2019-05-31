//
//  CaptureButton.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 11/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import UIKit

class CaptureButton: UIButton {

    override func draw(_ rect: CGRect) {
        
        
        let circle = CALayer()
        circle.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        circle.backgroundColor = UIColor.black.cgColor
        circle.cornerRadius = 40
        circle.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
        circle.borderWidth = 2
        circle.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/245, alpha: 1.00).cgColor
        
        let innerCircleOne = CALayer()
        innerCircleOne.bounds = CGRect(x: 0, y: 0, width: 74, height: 74)
        innerCircleOne.borderWidth = 3
        innerCircleOne.borderColor = UIColor(red: 220/255, green: 228/255, blue: 225/245, alpha: 1.00).cgColor
        innerCircleOne.cornerRadius = 37
        innerCircleOne.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
        
        self.layer.insertSublayer(circle, at: 0)
        self.layer.insertSublayer(innerCircleOne, at: 1)
        
    }
 
}
