//
//  LeagueTableViewCell.swift
//  Hedge Beta
//
//  Created by Jordan Coppert on 4/19/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit

class LeagueTableViewCell: UITableViewCell {

    var resultImage:UIImageView!
    var leagueLabel: UILabel!
    var challengeLabel:UILabel!
    var durationLabel:UILabel!
    var imageString:String!
    var textString:String!
    var changeLabel:UILabel!
    var change:String!
    var challenge:String!
    var duration:Int!
    var amount:Float!
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
        leagueLabel?.removeFromSuperview()
        durationLabel?.removeFromSuperview()
        changeLabel?.removeFromSuperview()
        challengeLabel?.removeFromSuperview()
        resultImage?.removeFromSuperview()
    }
    
    func createLeagueLabel(){
        leagueLabel = UILabel()
        leagueLabel.text = textString
        leagueLabel.textColor = UIColor.white
        leagueLabel.translatesAutoresizingMaskIntoConstraints = false
        leagueLabel.font = UIFont.boldSystemFont(ofSize: 18)
        leagueLabel.numberOfLines = 1
        leagueLabel.adjustsFontSizeToFitWidth = true
        leagueLabel.tag = 1
        contentView.addSubview(leagueLabel)
    }
    
    func createChangeLabel(){
        changeLabel = UILabel()
        changeLabel.text = formatter.string(from: NSNumber(value: amount))
        changeLabel.textColor = changeColor
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.font = UIFont.boldSystemFont(ofSize: 14)
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
        contentView.addSubview(resultImage)
    }
    
    func createChallengeLabel(){
        challengeLabel = UILabel()
        challengeLabel.text = challenge
        challengeLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        challengeLabel.translatesAutoresizingMaskIntoConstraints = false
        challengeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        challengeLabel.numberOfLines = 0
        challengeLabel.tag = 1
        contentView.addSubview(challengeLabel)
    }
    
    func createDurationLabel(){
        durationLabel = UILabel()
        durationLabel.text = "Rank: \(duration!)"
        durationLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.boldSystemFont(ofSize: 14)
        durationLabel.numberOfLines = 0
        durationLabel.tag = 1
        contentView.addSubview(durationLabel)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        
        resultImage.leadingAnchor.constraintEqualToSystemSpacingAfter(contentView.leadingAnchor, multiplier: 0.1).isActive = true
        resultImage.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        resultImage.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.5).isActive = true
        resultImage.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.2).isActive = true
        
        leagueLabel.topAnchor.constraint(equalTo: resultImage.topAnchor).isActive = true
        leagueLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(resultImage.trailingAnchor, multiplier: 0.4).isActive = true
        leagueLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -60).isActive = true

        challengeLabel.leadingAnchor.constraint(equalTo: leagueLabel.leadingAnchor).isActive = true
        challengeLabel.topAnchor.constraintEqualToSystemSpacingBelow(leagueLabel.bottomAnchor, multiplier: 0.7).isActive = true
        
        changeLabel.centerYAnchor.constraint(equalTo: leagueLabel.centerYAnchor).isActive = true
        changeLabel.trailingAnchor.constraintEqualToSystemSpacingAfter(margins.trailingAnchor, multiplier: -0.5).isActive = true
        
        durationLabel.trailingAnchor.constraint(equalTo: changeLabel.trailingAnchor).isActive = true
        durationLabel.topAnchor.constraint(equalTo: challengeLabel.topAnchor).isActive = true
    }
    
    func setupViews(leagueName: String, challenge: String, rank: Int, amount: Float, change: Float!){
        let stockChange = (change * 100) > 0 ? "upArrow" : "downArrow"
        changeColor = (change * 100) > 0 ? FunduModel.shared.hedgeGainColor : FunduModel.shared.hedgeLossColor
        self.change = String(stockChange)
        textString = leagueName
        self.challenge = challenge
        //This is really rank not duration
        self.duration = rank
        self.amount = amount
        
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.generatesDecimalNumbers = true
        formatter.locale = .current
        
        self.contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        self.backgroundColor = FunduModel.shared.hedgePrimaryColor
        
        createImage()
        createChangeLabel()
        createLeagueLabel()
        createDurationLabel()
        createChallengeLabel()
        setConstraints()
    }

}
