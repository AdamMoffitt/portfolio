//
//  NewsArticleCell.swift
//  fundü
//
//  Created by Jordan Coppert on 3/2/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class NewsArticleCell: UITableViewCell {
    
    var url:String!
    var article:Article!
    var articleImage:UIImageView!
    var headline:UILabel!
    var authorLabel:UILabel!
    var imageString:String!
    var textString:String!
    var cellTextColor:UIColor!
    var cellBackgroundColor: UIColor!
    var images = ["news1", "news2", "news3"]
    
    //The demon!
    override func prepareForReuse() {
        articleImage.removeFromSuperview()
        headline.removeFromSuperview()
        authorLabel.removeFromSuperview()
        super.prepareForReuse()
    }
    
    func createImage(){
        articleImage = UIImageView(image: UIImage(named: imageString))
        articleImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.5)
        articleImage.contentMode = UIViewContentMode.scaleAspectFit
        articleImage.layer.cornerRadius = 5
        articleImage.clipsToBounds = true
        articleImage.layer.masksToBounds = true
        articleImage.translatesAutoresizingMaskIntoConstraints = false
        articleImage.layer.borderWidth = 1
        articleImage.layer.borderColor = UIColor.white.cgColor
        articleImage.backgroundColor = UIColor.white
        contentView.addSubview(articleImage)
    }
    
    func createDescriptionLabel(){
        headline = UILabel()
        headline.text = textString
        headline.textColor = cellTextColor
        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.font = UIFont.boldSystemFont(ofSize: 14)
        headline.numberOfLines = 2
        headline.tag = 1
        contentView.addSubview(headline)
    }
    
    func createAuthorLabel(){
        authorLabel = UILabel()
        authorLabel.text = article.author
        authorLabel.textColor = cellTextColor
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.boldSystemFont(ofSize: 10)
        authorLabel.numberOfLines = 1
        contentView.addSubview(authorLabel)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        articleImage.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        articleImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 1.2).isActive = true
        articleImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        articleImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        headline.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.85).isActive = true
        headline.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        headline.leadingAnchor.constraintEqualToSystemSpacingAfter(articleImage.trailingAnchor, multiplier: 1.1).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo: headline.leadingAnchor).isActive = true
        authorLabel.topAnchor.constraintEqualToSystemSpacingBelow(headline.bottomAnchor, multiplier: 0.7).isActive = true
    }
    
    func setupViews(article: Article, textColor: UIColor, backgroundColor: UIColor){
        self.article = article
        cellBackgroundColor = backgroundColor
        cellTextColor = textColor
        textString = article.headline
        url = article.url
        let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
        imageString = images[randomIndex]
        createImage()
        createDescriptionLabel()
        createAuthorLabel()
        setConstraints()
        self.backgroundColor = cellBackgroundColor
    }

}
