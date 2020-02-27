//
//  LeaguesTableViewCell.swift
//  fundü
//
//  Created by Adam Moffitt on 2/7/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class LeaguesTableViewCell: UITableViewCell {

    var rankingLabel : UILabel!
    var titleLabel : UILabel!
    var stockLabel : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let gap : CGFloat = 10
        let labelHeight: CGFloat = 30
        let labelWidth: CGFloat = self.contentView.frame.width/2
        let stockLabelWidth: CGFloat = self.contentView.frame.width-(labelWidth+(3*gap)+30)
        
        rankingLabel = UILabel()
        rankingLabel.frame = CGRect(x: gap, y: gap, width: 40, height: labelHeight)
        rankingLabel.textColor = UIColor.black
        rankingLabel.backgroundColor = .clear
        contentView.addSubview(rankingLabel)
        
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 2*gap + 40 , y: gap, width: labelWidth, height: labelHeight)
        titleLabel.textColor = FunduModel.shared.hedgeMainTextColor
        titleLabel.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        
        stockLabel = UILabel()
        stockLabel.frame = CGRect(x: 3*gap + labelWidth+40, y: 10, width: stockLabelWidth, height: labelHeight)
        stockLabel.textColor = UIColor.black
        stockLabel.backgroundColor = .clear
        contentView.addSubview(stockLabel)
        
        self.contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        self.isUserInteractionEnabled = true
    }
}
