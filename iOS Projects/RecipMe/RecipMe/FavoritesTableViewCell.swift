//
//  FavoritesTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 2/23/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet var favoriteRecipeImageView: UIImageView!

    @IBOutlet var favoriteRecipeLabel: UILabel!
    
    var recipe = Recipe()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
