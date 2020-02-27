//
//  MessagesTableViewCell.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit
import MIBadgeButton_Swift

class jordansWayMessagesTableViewCell: UITableViewCell {
    
    var senderImage: UIImage = UIImage(named: "team")! {
        didSet {
//            self.resultImageButton.setBackgroundImage(senderImage, for: .normal)
            self.resultImageButton.image = senderImage
            self.isImageSet = true
        }
    }
    var titleString:String!
    var messageString:String!
    var dateString:String!
    
//    var resultImageButton:MIBadgeButton!
    var resultImageButton:UIImageView!
    var titleLabel: UILabel!
    var dateLabel:UILabel!
    var messageLabel:UILabel!
    var isImageSet:Bool!
    var message:String!
    var date:String!
    var title:String!
    let SharedFunduModel = FunduModel.shared
    
    func createResultImage() {
//        resultImageButton = MIBadgeButton(type:.custom)
//        //Frame height and width need to be equal for autoconstraints
//        resultImageButton.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.5)
//        resultImageButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 15)
//        resultImageButton.layer.cornerRadius = resultImageButton.frame.size.width/2
//        resultImageButton.layer.masksToBounds = true
//        resultImageButton.setBackgroundImage(nil, for: .normal)
//        resultImageButton.clipsToBounds = true
//        resultImageButton.isEnabled = false
//        resultImageButton.translatesAutoresizingMaskIntoConstraints = false
//        resultImageButton.badgeBackgroundColor = UIColor.red
//        resultImageButton.alpha = 1
//        self.contentView.addSubview(resultImageButton)
        resultImageButton = UIImageView()
        resultImageButton.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.6, height: contentView.bounds.height * 0.6)
        resultImageButton.layer.cornerRadius = resultImageButton.frame.size.width/2
        resultImageButton.layer.masksToBounds = true
        resultImageButton.image = nil
        resultImageButton.clipsToBounds = true
        resultImageButton.translatesAutoresizingMaskIntoConstraints = false
        resultImageButton.alpha = 1
        self.contentView.addSubview(resultImageButton)
        
    }
    
    func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //frame: CGRect(x: 80, y: 10, width: 5*self.contentView.frame.width/8, height: self.contentView.frame.height/3)
        titleLabel.text = self.titleString
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        titleLabel.textColor = FunduModel.shared.hedgeMainTextColor
        self.contentView.addSubview(titleLabel)
    }
    
    func createDateLabel() {
        dateLabel = UILabel()
        //frame: CGRect(x: 6*self.contentView.frame.width/8, y: 10, width: self.contentView.frame.width/4-10, height: self.contentView.frame.height/3)
        dateLabel.text = dateString
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.text = date
        dateLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        self.contentView.addSubview(dateLabel)
    }
    
    func createMessageLabel() {
        messageLabel = UILabel()
        //frame: CGRect(x: 80, y: self.contentView.frame.height/3, width: self.contentView.frame.width-90, height: 2*self.contentView.frame.height/3)
        messageLabel.text = messageString
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.text = message
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        messageLabel.numberOfLines = 0
        self.contentView.addSubview(messageLabel)
    }
    
    func setupViews(title: String, message: String, date: String) {
        self.contentView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        isImageSet = false
        self.titleString = title
        self.messageString = title
        self.dateString = date
        
        createResultImage()
        createTitleLabel()
        createDateLabel()
        createMessageLabel()
        setConstraints()
    }
    
    override func prepareForReuse() {
        //        resultImageButton!.removeFromSuperview()
        titleLabel?.removeFromSuperview()
        messageLabel?.removeFromSuperview()
        dateLabel?.removeFromSuperview()
        resultImageButton?.removeFromSuperview()
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        resultImageButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        resultImageButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        resultImageButton.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6).isActive = true
        resultImageButton.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6).isActive = true
        
        titleLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(resultImageButton.trailingAnchor, multiplier: 1).isActive = true
        titleLabel.topAnchor.constraint(equalTo: resultImageButton.topAnchor).isActive = true
        
        messageLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(resultImageButton.trailingAnchor, multiplier: 1).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        messageLabel.topAnchor.constraintEqualToSystemSpacingBelow(titleLabel.bottomAnchor, multiplier: 1.4).isActive = true
        
        dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
    }
    
}
