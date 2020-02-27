//
//  HedgeLogoTableViewCell.swift
//  fundü
//
//  Created by Adam Moffitt on 3/11/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class HedgeLogoTableViewCell: UITableViewCell {

    var hedgeLogoImageView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        hedgeLogoImageView.removeFromSuperview()
    }
    
    func setupViews() {
        hedgeLogoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height))
        hedgeLogoImageView.image = UIImage(named: "hedgeLogo")
        hedgeLogoImageView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        hedgeLogoImageView.contentMode = UIViewContentMode.scaleAspectFit
        hedgeLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(hedgeLogoImageView)
        setConstraints()
    }
    
    func setupDrawerView(width: CGFloat) {
        hedgeLogoImageView = UIImageView(frame: CGRect(x: 37.5, y: 0, width: 75, height: self.contentView.frame.height))
        hedgeLogoImageView.image = UIImage(named: "hedgeLogo")
        hedgeLogoImageView.backgroundColor = UIColor.darkGray
        hedgeLogoImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.contentView.addSubview(hedgeLogoImageView)
        setConstraints()
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        hedgeLogoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        hedgeLogoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        hedgeLogoImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        hedgeLogoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        hedgeLogoImageView.heightAnchor.constraint(equalToConstant: margins.layoutFrame.height).isActive = true
        hedgeLogoImageView.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width).isActive = true
    }
}
