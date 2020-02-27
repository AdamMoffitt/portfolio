//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Adam Moffitt on 9/30/16.
//  Copyright © 2016 USC SCOPE. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
