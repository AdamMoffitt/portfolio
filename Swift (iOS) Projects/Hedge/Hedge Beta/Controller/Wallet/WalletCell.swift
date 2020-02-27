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

class WalletCell: UITableViewCell {
    
    let padding: CGFloat = 5
    var background: UIView!
    //var typeLabel: UILabel!
    var tickerNameLabel: UILabel!
    var priceLabel: UILabel!
    var numberOfSharesLabel: UILabel!
    var companyNameLabel: UILabel!

    var stock: Stock? {
        didSet {
            print("set stock")
            if let s = stock {
                priceLabel.text = s.price
                if s.price != nil && Double(s.price!)! > 0.0 {
                    priceLabel.textColor = UIColor.green
                } else {
                    priceLabel.textColor = UIColor.red
                }
                let t = tickerToStockName()
                //s. name is the ticker
                tickerNameLabel.text = t.dictionary[s.name!]
                companyNameLabel.text = s.name
                setNeedsLayout()
                FunduModel.shared.checkOwnership(ticker: s.name!) { (teams, owned) in
                    if owned {
                        var numShares = 0
                        for team in teams {
                            numShares = numShares + team.stockQuantity
                        }
                        self.numberOfSharesLabel.text = String(numShares) + " shares"
                        print("\(s.name!) \(numShares) shares")
                    } else {
                        self.numberOfSharesLabel.text = "Not owned"
                        print("\(s.name!) not owned")
                    }
                    self.reloadInputViews()
                }
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = UIColor.clear
        tickerNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tickerNameLabel.textAlignment = .left
        tickerNameLabel.textColor = FunduModel.shared.hedgeMainTextColor
        contentView.addSubview(tickerNameLabel)
        
        companyNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        companyNameLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        companyNameLabel.textAlignment = .left
        contentView.addSubview(companyNameLabel)
        
        priceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        priceLabel.textAlignment = .right
        priceLabel.textColor = FunduModel.shared.hedgeMainTextColor
        contentView.addSubview(priceLabel)
        
        numberOfSharesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        numberOfSharesLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        numberOfSharesLabel.textAlignment = .right
        contentView.addSubview(numberOfSharesLabel)

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tickerNameLabel.removeFromSuperview()
        priceLabel.removeFromSuperview()
        numberOfSharesLabel.removeFromSuperview()
        companyNameLabel.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        priceLabel.frame = CGRect(
            x: self.contentView.frame.width/2 ,
            y: 10,
            width: self.contentView.frame.width/2 - 20,
            height: frame.height/2 - 20)
        numberOfSharesLabel.frame = CGRect(
            x: self.contentView.frame.width/2,
            y: 10 + priceLabel.frame.height,
            width: self.contentView.frame.width/2 - 20,
            height: frame.height/2 - 20)
        
        tickerNameLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: self.contentView.frame.width/2,
            height: frame.height/2-20)
        companyNameLabel.frame = CGRect(
            x: 10,
            y: 10 + tickerNameLabel.frame.height,
            width: self.contentView.frame.width/2,
            height: frame.height/2-20)
    }
}
