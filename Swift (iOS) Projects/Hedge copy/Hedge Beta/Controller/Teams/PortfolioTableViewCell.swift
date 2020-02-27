//
//  PortfolioTableViewCell.swift
//  Hedge Beta
//
//  Created by Jordan Coppert on 4/23/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {

//    var resultImage:UIImageView!
    var tickerLabel: UILabel!
    var companyLabel:UILabel!
    var sharesLabel:UILabel!
    var valueLabel:UILabel!
    
    var imageString:String!
    var textString:String!
    var companyName:String!
    var shares:Int!
    var value:Float!
    var changeColor:UIColor!
    
    let formatter = NumberFormatter()
    
    //ROUNDING AND SPACING
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        tickerLabel?.removeFromSuperview()
        sharesLabel?.removeFromSuperview()
        valueLabel?.removeFromSuperview()
        companyLabel?.removeFromSuperview()
    }
    
    func createTickerLabel(){
        tickerLabel = UILabel()
        tickerLabel.text = textString.uppercased()
        tickerLabel.textColor = UIColor.white
        tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        tickerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        tickerLabel.numberOfLines = 0
        tickerLabel.tag = 1
        contentView.addSubview(tickerLabel)
    }
    
    func createValueLabel(){
        valueLabel = UILabel()
        valueLabel.text = formatter.string(from: NSNumber(value: value))
        valueLabel.textColor = changeColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 14)
        valueLabel.numberOfLines = 0
        contentView.addSubview(valueLabel)
    }
    
//    func createImage(){
//        resultImage = UIImageView(image: UIImage(named: change))
//        resultImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.2)
//        resultImage.contentMode = UIViewContentMode.scaleAspectFit
//        resultImage.layer.cornerRadius = 10
//        resultImage.clipsToBounds = true
//        resultImage.layer.masksToBounds = true
//        resultImage.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(resultImage)
//    }
    
    func createCompanyLabel(){
        companyLabel = UILabel()
        companyLabel.text = companyName
        companyLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        companyLabel.font = UIFont.boldSystemFont(ofSize: 14)
        companyLabel.numberOfLines = 1
        companyLabel.tag = 1
        contentView.addSubview(companyLabel)
    }
    
    func createSharesLabel(){
        sharesLabel = UILabel()
        let numShares = (shares == -1) ? "Not owned" : "\(shares!) shares"
        sharesLabel.text = numShares
        sharesLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        sharesLabel.translatesAutoresizingMaskIntoConstraints = false
        sharesLabel.font = UIFont.boldSystemFont(ofSize: 14)
        sharesLabel.numberOfLines = 0
        sharesLabel.tag = 1
        contentView.addSubview(sharesLabel)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        
        tickerLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(margins.leadingAnchor, multiplier: 0.4).isActive = true
        tickerLabel.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 0.5).isActive = true
        
        companyLabel.leadingAnchor.constraint(equalTo: tickerLabel.leadingAnchor).isActive = true
        companyLabel.topAnchor.constraintEqualToSystemSpacingBelow(tickerLabel.bottomAnchor, multiplier: 0.7).isActive = true
        companyLabel.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width * 0.6).isActive = true
        
        valueLabel.topAnchor.constraint(equalTo: tickerLabel.topAnchor).isActive = true
        valueLabel.trailingAnchor.constraintEqualToSystemSpacingAfter(margins.trailingAnchor, multiplier: -0.5).isActive = true
        
        sharesLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor).isActive = true
        sharesLabel.topAnchor.constraint(equalTo: companyLabel.topAnchor).isActive = true
    }
    
    func setupViews(ticker: String, change: Float, companyName: String, value: Float, sharesOwned: Int){
//        let stockChange = (change * 100) > 0 ? "upArrow" : "downArrow"
        changeColor = (change * 100) > 0 ? FunduModel.shared.hedgeGainColor : FunduModel.shared.hedgeLossColor
        textString = ticker
        self.companyName = companyName.uppercased()
        self.shares = sharesOwned
        self.value = value
        
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.generatesDecimalNumbers = true
        formatter.locale = .current
        
        self.contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        self.backgroundColor = FunduModel.shared.hedgePrimaryColor
        
//        createImage()
        createTickerLabel()
        createValueLabel()
        createSharesLabel()
        createCompanyLabel()
        setConstraints()
    }
    
}
