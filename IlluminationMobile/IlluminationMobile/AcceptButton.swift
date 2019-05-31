//
//  AcceptButton.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 14/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import UIKit

class AcceptButton: UIButton {

    override func draw(_ rect: CGRect) {
        let button = CALayer()
        button.bounds = CGRect(x: 100, y: 100, width: 200, height: 60)
        button.backgroundColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1).cgColor
        button.cornerRadius = 30
        button.position = CGPoint(x: layer.frame.width / 2, y: layer.frame.height / 2)
        self.layer.insertSublayer(button, at: 1)
        
    }
}
