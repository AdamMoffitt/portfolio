//
//  MessagesTableViewCell.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit
import MIBadgeButton_Swift

class MessagesTableViewCell: UITableViewCell {

    var senderImage: UIImage = UIImage(named: "team")! {
        didSet {
            self.resultImageButton.setBackgroundImage(senderImage, for: .normal)
            self.isImageSet = true
        }
    }
    
    var resultImageButton:MIBadgeButton!
    var titleLabel: UILabel!
    var dateLabel:UILabel!
    var messageLabel:UILabel!
    var isImageSet:Bool!
    var message:String!
    var date:String!
    var title:String!
    let SharedFunduModel = FunduModel.shared
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.clear
        isImageSet = false
        resultImageButton = MIBadgeButton(type:.custom)
        resultImageButton.frame = CGRect(x: 10, y: 20, width: 60, height: 60)
//        resultImageButton.badgeEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.contentView.addSubview(resultImageButton)
        resultImageButton.layer.cornerRadius = resultImageButton.frame.width/2
        resultImageButton.layer.masksToBounds = true
        resultImageButton.setBackgroundImage(nil, for: .normal)
        resultImageButton.clipsToBounds = true
        resultImageButton.isEnabled = false
        
        titleLabel = UILabel(frame: CGRect(x: 80, y: 10, width: 5*self.contentView.frame.width/8, height: self.contentView.frame.height/3))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        titleLabel.textColor = FunduModel.shared.hedgeMainTextColor
        self.contentView.addSubview(titleLabel)
        
        dateLabel = UILabel(frame: CGRect(x: 6*self.contentView.frame.width/8, y: 10, width: self.contentView.frame.width/4-10, height: self.contentView.frame.height/3))
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.text = date
        dateLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        self.contentView.addSubview(dateLabel)
        
        messageLabel = UILabel(frame: CGRect(x: 80, y: self.contentView.frame.height/3, width: self.contentView.frame.width-90, height: 2*self.contentView.frame.height/3))
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        messageLabel.numberOfLines = 0
        self.contentView.addSubview(messageLabel)
        setConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        resultImageButton?.removeFromSuperview()
        titleLabel?.removeFromSuperview()
        messageLabel?.removeFromSuperview()
        dateLabel?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.backgroundColor = UIColor.clear

        resultImageButton = MIBadgeButton(type:.custom)
        resultImageButton.frame = CGRect(x: 10, y: 20, width: 60, height: 60)
            self.contentView.addSubview(resultImageButton)
        resultImageButton.layer.cornerRadius = resultImageButton.frame.width/2
        resultImageButton.layer.masksToBounds = true
        resultImageButton.clipsToBounds = true
        resultImageButton.alpha = 1
        resultImageButton.bringSubview(toFront: resultImageButton.badgeLabel)

        titleLabel = UILabel(frame: CGRect(x: 80, y: 10, width: 5*self.contentView.frame.width/8, height: self.contentView.frame.height/3))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        titleLabel.textColor = FunduModel.shared.hedgeMainTextColor
        self.contentView.addSubview(titleLabel)

        dateLabel = UILabel(frame: CGRect(x: 6*self.contentView.frame.width/8, y: 10, width: self.contentView.frame.width/4 - 10, height: self.contentView.frame.height/3))
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.text = date
        dateLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        self.contentView.addSubview(dateLabel)

        messageLabel = UILabel(frame: CGRect(x: 80, y: self.contentView.frame.height/3, width: 7*self.contentView.frame.width-90, height: 2*self.contentView.frame.height/3))
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.text = message
        messageLabel.textColor = FunduModel.shared.hedgeMinorTextColor
        self.contentView.addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        setConstraints()
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        resultImageButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        resultImageButton.center = CGPoint(x: 40, y: contentView.bounds.size.height/2)
        resultImageButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: resultImageButton.trailingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: resultImageButton.trailingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

//        resultImageButton.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
//        resultImageButton.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        
//        titleLabel.leadingAnchor.constraint(equalTo: resultImageButton.trailingAnchor, constant: 1.0).isActive = true
//        messageLabel.leadingAnchor.constraint(equalTo: resultImageButton.trailingAnchor, constant: 1.0).isActive = true
    }

}
