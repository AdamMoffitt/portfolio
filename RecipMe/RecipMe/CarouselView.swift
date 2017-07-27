//
//  CarouselView.swift
//  RecipMe
//
//  Created by Adam Moffitt on 3/7/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class CarouselView: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ownedIngredientsLabel: UILabel!
    @IBOutlet var yieldLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var totalTimeAmountLabel: UILabel!
    
    init(title: String, image: UIImage, totalTime: Int, yield: String, ownedIngredients: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
        
        print(title)
        print(yield)
        print(ownedIngredients)
        self.titleLabel.text = title
        self.imageView.image = image
        self.totalTimeAmountLabel.text = "\(totalTime) mins"
        self.yieldLabel.text = "Yield: \(yield)"
        self.ownedIngredientsLabel.text = ownedIngredients
    }
    
   func set(title: String, image: UIImage, totalTime: Int, yield: String, ownedIngredients: String) {
        self.titleLabel.text = title
        self.imageView.image = image
        self.totalTimeAmountLabel.text = "\(totalTime) mins"
        self.yieldLabel.text = "Yield: \(yield)"
        self.ownedIngredientsLabel.text = ownedIngredients
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
