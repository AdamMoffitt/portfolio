//
//  LoadingView.swift
//  RecipMe
//
//  Created by Adam Moffitt on 1/19/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//


// This class is NOT BEING USED!!!!!!!!!!!

import UIKit


class LoadingView: UIView {

    var loadingImage : UIImage!
    var loadingImageView : UIImageView!
    var loadingLabel : UILabel!
    
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.darkGray
        
        self.loadingImage = UIImage.animatedImageNamed("simpsons-", duration: 1.0)!
        self.loadingImageView.image = loadingImage
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
