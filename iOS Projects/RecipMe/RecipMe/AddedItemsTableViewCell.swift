//
//  AddedItemsTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 4/16/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class AddedItemsTableViewCell: UITableViewCell {
    
    @IBOutlet var foodNameLabel: UILabel!

    @IBOutlet var foodQuantityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
