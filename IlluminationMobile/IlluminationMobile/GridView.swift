//
//  GridView.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 13/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import Foundation

class GridView: UIView
{
    private var path = UIBezierPath()
    
    let numHorLines: CGFloat = 3.0
    let numVerLines: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        let width = bounds.width
        let height = bounds.height
        
        let horSpacing = height/numHorLines
        let verSpacing = width/numVerLines
        
        for i in 1...Int(numHorLines-1) {
            let lineStart = CGPoint(x:0, y: CGFloat(i)*horSpacing)
            let lineEnd = CGPoint(x:width, y: CGFloat(i)*horSpacing)
            path.move(to: lineStart)
            path.addLine(to: lineEnd)
        }
        
        for i in 1...Int(numVerLines-1) {
            let lineStart = CGPoint(x:CGFloat(i)*verSpacing, y: 0)
            let lineEnd = CGPoint(x:CGFloat(i)*verSpacing, y: height)
            path.move(to: lineStart)
            path.addLine(to: lineEnd)
        }
        
        path.close()
        path.lineWidth = 1.0
        UIColor.white.setStroke()
        path.stroke()
    }
}
