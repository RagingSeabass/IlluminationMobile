//
//  ProgressViewController.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 13/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import Foundation
import QuartzCore

class ProgressViewController: UIViewController {
    
    var text:String = ""
    
    // MARK: Properties
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var cellOne: UIView!
    @IBOutlet weak var cellTwo: UIView!
    @IBOutlet weak var cellThree: UIView!
    @IBOutlet weak var cellFour: UIView!
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVisuals()
        
    
        
    }
    
    func setupVisuals() {
        let color = UIColor.darkGray
        
        self.allBordersStatusInitial()
        
        let bg_color = UIColor(red: 24/255, green: 26/255, blue: 28/255, alpha: 1)
        
        cellOne.backgroundColor = bg_color
        cellTwo.backgroundColor = bg_color
        cellThree.backgroundColor = bg_color
        cellFour.backgroundColor = bg_color
        
        self.cellOne.layer.cornerRadius = 12
        self.cellTwo.layer.cornerRadius = 12
        self.cellThree.layer.cornerRadius = 12
        self.cellFour.layer.cornerRadius = 12
        
        self.cellOne.clipsToBounds = true
        
    }
    
    func changeCellStatusActive(cellIndex: Int) {
        
        let borderColor = UIColor.white//UIColor(red: 123/255, green: 58/255, blue: 228/255, alpha: 1)
        
        switch cellIndex {
        case 1:
            self.setupBorder(cell: self.cellOne, color: borderColor)
        case 2:
            self.setupBorder(cell: self.cellTwo, color: borderColor)
        case 3:
            self.setupBorder(cell: self.cellThree, color: borderColor)
        case 4:
            self.setupBorder(cell: self.cellFour, color: borderColor)
        default:
            print("changeBorderColor: Invalid cellIndex")
        }
    }
    
    func changeCellStatusDone(cellIndex: Int) {
        
        let borderColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1)
        
        switch cellIndex {
        case 1:
            self.setupBorder(cell: self.cellOne, color: borderColor)
        case 2:
            self.setupBorder(cell: self.cellTwo, color: borderColor)
        case 3:
            self.setupBorder(cell: self.cellThree, color: borderColor)
        case 4:
            self.setupBorder(cell: self.cellFour, color: borderColor)
        default:
            print("changeBorderColor: Invalid cellIndex")
        }
    }
    
    func setupBorder(cell: UIView, color: UIColor) {
        let bottomBorder = CALayer()
        
        let height = cell.frame.height - 20
        let width = cell.frame.width - 37
        
        bottomBorder.frame = CGRect(x: 12.0, y: height, width: width, height: 1.0)
        bottomBorder.backgroundColor = color.cgColor
        cell.layer.addSublayer(bottomBorder)
    }
    
    func allBordersStatusInitial() {
        let color = UIColor.darkGray
        
        self.setupBorder(cell: cellOne, color: color)
        self.setupBorder(cell: cellTwo, color: color)
        self.setupBorder(cell: cellThree, color: color)
        self.setupBorder(cell: cellFour, color: color)
    }
   
    
}
