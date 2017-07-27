//
//  KitchenFoldingCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 4/10/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit
import FoldingCell
import GTProgressBar

class KitchenFoldingCell: FoldingCell {
    
    //initial small table view cell
    @IBOutlet var freshnessIndicatorCircle: UIView!
    
    @IBOutlet var foodName: UILabel!
    
    @IBOutlet var daysLeftLabel: UILabel!
    
    @IBOutlet var foodQuantity: UILabel!
    
    //Expanded table view cell
    @IBOutlet var expandedFoodName: UILabel!
    @IBOutlet var expandedFoodQuantity: UILabel!
    @IBOutlet var expandedFreshBar: GTProgressBar!
    @IBOutlet var addedOnDate: UILabel!
    @IBOutlet var expirationDate: UILabel!
    @IBOutlet var nutritionalFactsLabel: UILabel!
     @IBOutlet var foodImageView: UIImageView!
    var foodItem = FoodItem()
    var freshColor = UIColor.green.cgColor
    var shapeLayer = CAShapeLayer()
    
    @IBAction func addRemoveStepper(_ sender: Any) {
        //TODO: increase food quanitity by one in label and in firebase
        foodQuantity.text = String(describing: foodItem.quantity!) + " " + foodItem.unitOfMeasurement!
        expandedFoodQuantity.text = String(describing: foodItem.quantity!) + " " + foodItem.unitOfMeasurement!
        
        
        
    }
   

    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        let centerX = (freshnessIndicatorCircle.frame.minX + freshnessIndicatorCircle.frame.width)/2
        let centerY = (freshnessIndicatorCircle.frame.minY + freshnessIndicatorCircle.frame.height)/2
        
         let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX,y: centerY), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = self.freshColor
        //you can change the stroke color
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        freshnessIndicatorCircle.layer.addSublayer(shapeLayer)
        
        expandedFreshBar.barBorderColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.barFillColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.barBackgroundColor = UIColor(red:0.77, green:0.93, blue:0.78, alpha:1.0)
        expandedFreshBar.barBorderWidth = 1
        expandedFreshBar.barFillInset = 2
        expandedFreshBar.labelTextColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        expandedFreshBar.font = UIFont.boldSystemFont(ofSize: 18)
        expandedFreshBar.barMaxHeight = 12
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26, 0.26, 0.26, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    
}
