//
//  SelectionToggleCell.swift
//  fundü
//
//  Created by Jordan Coppert on 3/5/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class SelectionToggleCell: UITableViewCell {

    var resultImage:UIImageView!
    var resultText:UILabel!
    var tickerText: UILabel!
    var imageString:String!
    var textString:String!
    var company:Bool!
    var companyTicker:String!
    var placeHolder:String!
    
    override func prepareForReuse() {
        resultImage?.removeFromSuperview()
        resultText?.removeFromSuperview()
    }
    
    func createDescriptionLabel(){
        resultText = UILabel()
        resultText.text = textString
        resultText.textColor = UIColor.black
        resultText.translatesAutoresizingMaskIntoConstraints = false
        resultText.font = UIFont.boldSystemFont(ofSize: 14)
        resultText.numberOfLines = 0
        resultText.tag = 1
        contentView.addSubview(resultText)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        resultText.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.85).isActive = true
        resultText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        resultText.leadingAnchor.constraintEqualToSystemSpacingAfter(margins.leadingAnchor, multiplier: 1.1).isActive = true
    }
    
    func setupViews(text: String){
        textString = text
        createDescriptionLabel()
        setConstraints()
    }
}
