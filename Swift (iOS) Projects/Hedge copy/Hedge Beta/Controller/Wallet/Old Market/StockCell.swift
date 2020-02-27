//
//  StockCell.swift
//  fundü
//
//  Created by Hunter Hurja on 2/6/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class StockCell: UITableViewCell {
    let padding: CGFloat = 5
    var background: UIView!
    //var typeLabel: UILabel!
    var nameLabel: UILabel!
    var priceLabel: UILabel!
    var isExpanded: Bool!
    
    var stock: Stock? {
        didSet {
            if let s = stock {
                background.backgroundColor = s.backgroundColor
                priceLabel.text = s.price
                if s.price != nil && Double(s.price!)! > 0.0 {
                   priceLabel.textColor = UIColor.green
                } else {
                    priceLabel.textColor = UIColor.red
                }
                priceLabel.backgroundColor = s.priceLabelColor
//                typeLabel.text = s.action
//                typeLabel.backgroundColor = s.typeColor
                nameLabel.text = s.name
                setNeedsLayout()
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isExpanded = false
        backgroundColor = FunduModel.shared.funduColor
        selectionStyle = .none
        background = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        background.alpha = 1
        contentView.addSubview(background)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColor.black
        contentView.addSubview(nameLabel)
        
//        typeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//        typeLabel.textAlignment = .center
//        typeLabel.textColor = UIColor.white
//        contentView.addSubview(typeLabel)
        
        priceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        priceLabel.textAlignment = .center
        priceLabel.textColor = UIColor.white
        contentView.addSubview(priceLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.frame = CGRect(x: 0, y: padding, width: frame.width, height: frame.height - 2*padding)
        //typeLabel.frame = CGRect(x: padding, y: (frame.height - 25)/2, width: 40, height: 25)
        priceLabel.frame = CGRect(x: frame.width - 100, y: padding, width: 100, height: frame.height - 2 * padding)
        nameLabel.frame = CGRect(x: padding+40 + 10, y: 0, width: frame.width - priceLabel.frame.width - (padding+40 + 10), height: frame.height)
    }
    
    
}

