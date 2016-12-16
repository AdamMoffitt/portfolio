//
//  FeaturedItem.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class FeaturedItem: NSObject {

    var title : String
    var descriptionString : String
    var image : UIImage
    
    init(title: String, description: String, image: UIImage){
        self.title = title
        self.descriptionString = description
        self.image = image
    }
    
    func set(title: String){
        self.title = title
    }
    func getTitle() -> String{
        return title
    }
    func set(description: String){
        self.descriptionString = description
    }
    func getDescription() -> String{
        return description
    }
    func set(image: UIImage){
        self.image = image
    }
    func getImage() -> UIImage{
        return image;
    }
}
