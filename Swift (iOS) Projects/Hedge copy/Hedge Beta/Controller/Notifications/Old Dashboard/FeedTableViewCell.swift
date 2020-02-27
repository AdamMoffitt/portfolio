//
//  FeedTableViewCell.swift
//  fundü
//
//  Created by Jordan Coppert on 12/5/17.
//  Copyright © 2017 fundü. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    var event:FeedEvent!
    var eventImage:UIImageView!
    var time:UILabel!
    var eventDescription:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createImage(){
        eventImage = StatImageView(image: UIImage(named:event.image))
        eventImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.5)
        eventImage.contentMode = UIViewContentMode.scaleAspectFit
        eventImage.clipsToBounds = true
        eventImage.layer.masksToBounds = true
        eventImage.translatesAutoresizingMaskIntoConstraints = false
        eventImage.layer.borderWidth = 1
        eventImage.layer.borderColor = UIColor.white.cgColor
        eventImage.backgroundColor = UIColor.white
        contentView.addSubview(eventImage)
    }
    
    func createTimeLabel(){
        time = UILabel()
        time.text = event.time
        time.textColor = UIColor.white
        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.boldSystemFont(ofSize: 8)
        time.numberOfLines = 0
        contentView.addSubview(time)
    }
    
    func createDescriptionLabel(){
        eventDescription = UILabel()
        eventDescription.text = event.message
        eventDescription.textColor = UIColor.white
        eventDescription.translatesAutoresizingMaskIntoConstraints = false
        eventDescription.font = UIFont.boldSystemFont(ofSize: 14)
        eventDescription.numberOfLines = 0
        contentView.addSubview(eventDescription)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        eventImage.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        eventImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 1.2).isActive = true
        eventImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        eventImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        time.centerXAnchor.constraint(equalTo: eventImage.centerXAnchor).isActive = true
        time.topAnchor.constraintEqualToSystemSpacingBelow(eventImage.bottomAnchor, multiplier: 1.1).isActive = true
        eventDescription.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.85).isActive = true
        eventDescription.centerYAnchor.constraint(equalTo: eventImage.centerYAnchor).isActive = true
        eventDescription.leadingAnchor.constraintEqualToSystemSpacingAfter(eventImage.trailingAnchor, multiplier: 1.1).isActive = true
    }
    
    func setupViews(feedEvent:FeedEvent){
        event = feedEvent
        createTimeLabel()
        createDescriptionLabel()
        createImage()
        setConstraints()
    }

}
