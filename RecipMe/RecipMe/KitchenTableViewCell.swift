//
//  KitchenFoodItemCellTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/24/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class KitchenTableViewCell: UITableViewCell {

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
//        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftMethod: )];
//        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//        [self.view addGestureRecognizer:swipeLeft];
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
