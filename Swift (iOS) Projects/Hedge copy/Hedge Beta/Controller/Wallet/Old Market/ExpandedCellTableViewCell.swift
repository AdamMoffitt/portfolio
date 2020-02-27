//
//  ExpandedCellTableViewCell.swift
//  fundü
//
//  Created by Adam Moffitt on 2/18/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class ExpandedCellTableViewCell: UITableViewCell {

    var delegate: ExpandableTableViewCellDelegate? = nil
    var stockSymbol : String = ""
    var buyButton : UIButton!
    var sellButton : UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func buyButtonPressed() {
        delegate?.buyButtonPressed(stockSymbol: stockSymbol)
    }
    
    @objc func sellButtonPressed() {
        delegate?.sellButtonPressed(stockSymbol: stockSymbol)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let width = self.contentView.frame.width
        buyButton = UIButton(frame: CGRect(x: 0, y:0, width: width/2, height: frame.height))
        buyButton.backgroundColor = UIColor.green
        buyButton.setTitle("Buy", for: .normal)
        buyButton.titleLabel?.textColor = UIColor.black
        buyButton.addTarget(self, action: #selector(buyButtonPressed), for: .touchUpInside)
        self.contentView.addSubview(buyButton)
        
        sellButton = UIButton(frame: CGRect(x: width/2, y:0, width: width/2, height: frame.height))
        sellButton.addTarget(self, action: #selector(sellButtonPressed), for: .touchUpInside)
        sellButton.backgroundColor = UIColor.red
        sellButton.titleLabel?.textColor = UIColor.black
        sellButton.setTitle("Sell", for: .normal)
        self.contentView.addSubview(sellButton)
        
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        buyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        sellButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        buyButton.trailingAnchor.constraint(equalTo: sellButton.leadingAnchor)
        
        sellButton.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true

        buyButton.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true

    }
}
