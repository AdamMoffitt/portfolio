//
//  KitchenFoodItemCellTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/24/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import GTProgressBar

class KitchenTableViewCell: UITableViewCell {

    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodQuantity: UILabel!
    
    @IBOutlet var expandedFreshBar: GTProgressBar!
    @IBOutlet var addedOnDate: UILabel!
    @IBOutlet var expirationDate: UILabel!
    
    var foodItem = FoodItem()
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        expandedFreshBar.barBorderColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.barFillColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.barBackgroundColor = UIColor(red:0.77, green:0.93, blue:0.78, alpha:1.0)
        expandedFreshBar.barBorderWidth = 1
        expandedFreshBar.barFillInset = 2
        expandedFreshBar.labelTextColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        expandedFreshBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        expandedFreshBar.font = UIFont.boldSystemFont(ofSize: 18)
        expandedFreshBar.barMaxHeight = 12

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
