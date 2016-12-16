//
//  RecipMeTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/3/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class RecipMeTableViewCell: UITableViewCell {

    @IBOutlet var recipeName: UILabel!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var ownedIngredients: UILabel!
    
    var recipeId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func getRecipeId() -> Int {
        return self.recipeId!
    }
    
    func setRecipeId(id:Int) {
        self.recipeId = id
    }

}
