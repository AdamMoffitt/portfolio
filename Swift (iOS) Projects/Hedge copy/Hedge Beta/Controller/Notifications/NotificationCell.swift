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

class NotificationCell: UITableViewCell {
    
    var messageLabel: UILabel!
    var dateLabel: UILabel!
    var teamID: String!
    var teamName: String!
    var notificationImageView: UIImageView!
    var isSeenCircle: UIImageView!
    var notification: UserNotification!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationImageView.removeFromSuperview()
        messageLabel.removeFromSuperview()
        dateLabel.removeFromSuperview()
        isSeenCircle.removeFromSuperview()
    }
    
    func createImage(){
        
        notificationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.8, height: contentView.bounds.height * 0.8))
        //        let radius: CGFloat = self.bounds.size.width / 2.0 TODO make round because rn image size doesnt work
        //        image.layer.cornerRadius = radius
        notificationImageView.contentMode = UIViewContentMode.scaleAspectFit
        notificationImageView.clipsToBounds = true
        notificationImageView.layer.masksToBounds = true
        notificationImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notificationImageView)
        if notification.type == "teamInvite" {
            notificationImageView.image = UIImage(named: "team")
            if String(notification.image.characters.prefix(4)) == "http" {
                print("google image invite")
                let url = URL(string: notification.image)
                if(url != nil) {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let data = try? Data(contentsOf: url!) {
                            DispatchQueue.main.async {
                                self.notificationImageView.image = UIImage(data: data)!
                            }
                        }
                    }
                }
            }
        } else if notification.type == "messageNotification" {
            notificationImageView.image = UIImage(named: "inbox")
        } else if notification.type == "leagueInvite" {
            notificationImageView.image = UIImage(named: "leaderboard")
        } else if notification.type == "stockNotification" {
            notificationImageView.image = UIImage(named: "wallet")
        } else {
            print("icon")
            notificationImageView.image = UIImage(named: "team")
            selectionStyle = UITableViewCellSelectionStyle.none
        }
    }
    
    func createIsSeenCircle() {
        isSeenCircle = UIImageView(frame: CGRect(x: contentView.frame.width-30, y: 30, width: contentView.bounds.height * 0.2, height: contentView.bounds.height * 0.2))
        isSeenCircle.image = circle(diameter: 5.0, color: FunduModel.shared.hedgeGainColor)
       self.toggleSeen()
        isSeenCircle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(isSeenCircle)
    }
    
    func toggleSeen() {
        if notification.seen {
            isSeenCircle.isHidden = true
        } else {
            isSeenCircle.isHidden = false
        }
    }
    
    func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    func createMessageLabel() {
        messageLabel = UILabel()
        messageLabel.text = notification.message
        messageLabel.textColor = UIColor.white
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(messageLabel)
    }
    
    func createDateLabel() {
        dateLabel = UILabel()
        if notification.date != nil { // TODO format date and display
            dateLabel.text = notification.date
        }
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.textAlignment = .left
        dateLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        self.contentView.addSubview(dateLabel)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        notificationImageView.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        notificationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        notificationImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8).isActive = true
        notificationImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8).isActive = true
        
        messageLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(notificationImageView.trailingAnchor, multiplier: 1.1).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: isSeenCircle.leadingAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: notificationImageView.topAnchor).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true

        dateLabel.trailingAnchor.constraint(equalTo: isSeenCircle.leadingAnchor).isActive = true
        dateLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(notificationImageView.trailingAnchor, multiplier: 1.1).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 20.0)
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        
        isSeenCircle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        isSeenCircle.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.15).isActive = true
        isSeenCircle.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.15).isActive = true
        isSeenCircle.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

    }
    
    func setupViews(data: UserNotification){
        self.contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        notification = data
        teamID = data.teamID
        teamName = data.teamName
        createImage()
        createIsSeenCircle()
        createMessageLabel()
        createDateLabel()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

}
