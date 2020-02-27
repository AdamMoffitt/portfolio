//
//  TeamStockTableViewCell.swift
//  fundü
//
//  Created by Jordan Coppert on 3/8/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class TeamStockTableViewCell: UITableViewCell {

    var resultImage:UIImageView!
    var tickerText: UILabel!
    var quantityLabel:UILabel!
    var priceLabel:UILabel!
    var valueLabel:UILabel!
    var imageString:String!
    var textString:String!
    var changeLabel:UILabel!
    var quantity:Int!
    var changeString:String!
    var change:String!
    var price:Float!
    let formatter = NumberFormatter()
    var statsStack = UIStackView()
    
    override func prepareForReuse() {
        tickerText?.removeFromSuperview()
        priceLabel?.removeFromSuperview()
        valueLabel?.removeFromSuperview()
        quantityLabel?.removeFromSuperview()
    }
    
    func createTickerLabel(){
        tickerText = UILabel()
        tickerText.text = textString
        tickerText.textColor = UIColor.black
        tickerText.translatesAutoresizingMaskIntoConstraints = false
        tickerText.font = UIFont.boldSystemFont(ofSize: 32)
        tickerText.numberOfLines = 0
        tickerText.tag = 1
        contentView.addSubview(tickerText)
    }
    
    func createChangeLabel(){
        changeLabel = UILabel()
        changeLabel.text = changeString
        changeLabel.textColor = UIColor.black
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.font = UIFont.boldSystemFont(ofSize: 10)
        changeLabel.numberOfLines = 0
        contentView.addSubview(changeLabel)
    }
    
    func createImage(){
        resultImage = UIImageView(image: UIImage(named: change))
        resultImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.2)
        resultImage.contentMode = UIViewContentMode.scaleAspectFit
        resultImage.layer.cornerRadius = 10
        resultImage.clipsToBounds = true
        resultImage.layer.masksToBounds = true
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        resultImage.layer.borderWidth = 1
        resultImage.layer.borderColor = UIColor.white.cgColor
        resultImage.backgroundColor = UIColor.white
        contentView.addSubview(resultImage)
    }
    
    func createQuantityLabel(){
        quantityLabel = UILabel()
        quantityLabel.text = "Qty - " + String(quantity)
        quantityLabel.textColor = UIColor.black
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.font = UIFont.boldSystemFont(ofSize: 10)
        quantityLabel.numberOfLines = 0
        quantityLabel.tag = 1
        statsStack.addArrangedSubview(quantityLabel)
        //contentView.addSubview(quantityLabel)
    }
    
    func createPriceLabel(){
        priceLabel = UILabel()
        priceLabel.text = "Price - " + formatter.string(from: NSNumber(value: price))!
        priceLabel.textColor = UIColor.black
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.boldSystemFont(ofSize: 10)
        priceLabel.numberOfLines = 0
        priceLabel.tag = 1
        statsStack.addArrangedSubview(priceLabel)
        //contentView.addSubview(priceLabel)
    }
    
    //Product of price and quantity
    func createValueLabel(){
        valueLabel = UILabel()
        valueLabel.text = "Value - " + formatter.string(from: NSNumber(value: price * Float(quantity)))!
        valueLabel.textColor = UIColor.black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 10)
        valueLabel.numberOfLines = 0
        valueLabel.tag = 1
        statsStack.addArrangedSubview(valueLabel)
        //contentView.addSubview(valueLabel)
    }
    
    //marketChangeOverTime    GET THIS FROM IEX
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        tickerText.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.3).isActive = true
        tickerText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        tickerText.leadingAnchor.constraintEqualToSystemSpacingAfter(margins.leadingAnchor, multiplier: 0.5).isActive = true
        
        statsStack.leadingAnchor.constraintEqualToSystemSpacingAfter(tickerText.trailingAnchor, multiplier: 1.5).isActive = true
        statsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        statsStack.heightAnchor.constraint(equalToConstant: contentView.bounds.height
         * 0.8).isActive = true
        statsStack.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.4).isActive = true
        
        resultImage.leadingAnchor.constraintEqualToSystemSpacingAfter(statsStack.trailingAnchor, multiplier: 0.2).isActive = true
        resultImage.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        resultImage.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.5).isActive = true
        resultImage.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.2).isActive = true
        
        //Might need to update this
        changeLabel.centerXAnchor.constraint(equalTo: resultImage.centerXAnchor).isActive = true
        changeLabel.topAnchor.constraintEqualToSystemSpacingBelow(resultImage.bottomAnchor, multiplier: 0.2).isActive = true
    }
    
    func setupViews(ticker: String, quantity: Int, price: Float, change: Float!){
        let stockChange = (change * 100) > 0 ? "positiveChange" : "negativeChange"
        changeString = String(change * 100) + "%"
        self.change = String(stockChange)
        textString = ticker.uppercased()
        self.quantity = quantity
        self.price = price
        statsStack.axis = .vertical
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.generatesDecimalNumbers = true
        formatter.locale = .current
        createTickerLabel()
        createPriceLabel()
        createQuantityLabel()
        createValueLabel()
        createImage()
        createChangeLabel()
        contentView.addSubview(statsStack)
        setConstraints()
    }


}
