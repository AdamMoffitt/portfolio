//
//  TeamLeagueTableViewCell.swift
//  fundü
//
//  Created by Jordan Coppert on 3/8/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class TeamLeagueTableViewCell: UITableViewCell {

    var resultImage:UIImageView!
    var leagueLabel: UILabel!
    var challengeLabel:UILabel!
    var rankLabel:UILabel!
    var imageString:String!
    var league:String!
    var challenge:String!
    var rank:Int!
    
    override func prepareForReuse() {
        resultImage?.removeFromSuperview()
        rankLabel?.removeFromSuperview()
        leagueLabel?.removeFromSuperview()
        challengeLabel?.removeFromSuperview()
    }
    
    func createLeagueLabel(){
        leagueLabel = UILabel()
        leagueLabel.text = league
        leagueLabel.textColor = UIColor.black
        leagueLabel.translatesAutoresizingMaskIntoConstraints = false
        leagueLabel.font = UIFont.boldSystemFont(ofSize: 28)
        leagueLabel.numberOfLines = 0
        leagueLabel.tag = 1
        contentView.addSubview(leagueLabel)
    }
    
    func createChallengeLabel(){
        challengeLabel = UILabel()
        challengeLabel.text = challenge
        challengeLabel.textColor = UIColor.black
        challengeLabel.translatesAutoresizingMaskIntoConstraints = false
        challengeLabel.font = UIFont.boldSystemFont(ofSize: 8)
        challengeLabel.numberOfLines = 0
        challengeLabel.tag = 1
        contentView.addSubview(challengeLabel)
    }
    
    func createRankLabel(){
        rankLabel = UILabel()
        rankLabel.text = "Rank: " + String(rank)
        rankLabel.textColor = UIColor.black
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.font = UIFont.boldSystemFont(ofSize: 18)
        rankLabel.numberOfLines = 0
        rankLabel.tag = 1
        contentView.addSubview(rankLabel)
    }
    
    func createImage(){
        resultImage = UIImageView(image: UIImage(named: "default-league"))
        resultImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.2, height: contentView.bounds.height * 0.5)
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
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        
        resultImage.leadingAnchor.constraint(equalTo: leagueLabel.leadingAnchor).isActive = true
        resultImage.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 0.2).isActive = true
        resultImage.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.5).isActive = true
        resultImage.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.2).isActive = true
        
        leagueLabel.topAnchor.constraintEqualToSystemSpacingBelow(resultImage.bottomAnchor, multiplier: 0.1).isActive = true
        leagueLabel.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.85).isActive = true
        leagueLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(margins.leadingAnchor, multiplier: 1.1).isActive = true
        leagueLabel.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.25).isActive = true
        
        challengeLabel.topAnchor.constraintEqualToSystemSpacingBelow(leagueLabel.bottomAnchor, multiplier: 0.2).isActive = true
        challengeLabel.leadingAnchor.constraint(equalTo: leagueLabel.leadingAnchor).isActive = true
        challengeLabel.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.2).isActive = true
        challengeLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.8).isActive = true
        
        rankLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        rankLabel.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 0.2).isActive = true
        rankLabel.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.3).isActive = true
        
    }
    
    func setupViews(leagueName:String, challenge: String, rank: Int){
        league = leagueName
        self.challenge = challenge
        self.rank = rank
        createImage()
        createLeagueLabel()
        createChallengeLabel()
        createRankLabel()
        setConstraints()
    }
}
