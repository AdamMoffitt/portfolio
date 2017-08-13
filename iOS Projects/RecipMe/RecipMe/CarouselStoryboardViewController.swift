//
//  CarouselViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 3/2/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class CarouselStoryboardViewController: LoadingViewController, iCarouselDataSource, iCarouselDelegate {
    
    
    //-----------------------------------------------------------------------------------------
    let sharedRecipMeModel = RecipMeModel.shared
    
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = self.view.frame
        
        carousel = iCarousel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        carousel.dataSource = self
        carousel.type = .coverFlow
        view.addSubview(carousel)
        
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return sharedRecipMeModel.results.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let itemView: UIView
        
        if (sharedRecipMeModel.results.isEmpty){
            if view != nil {
                print("Set 1")
                let itemView = view as! CarouselView
                return itemView
            } else {
                print("MAKE 1")
                itemView = CarouselView(title: "", image: UIImage(named:"RecipMeIcon")!, totalTime: 0, yield: "", ownedIngredients: "")
            }
        }
        else {
        let recipe = sharedRecipMeModel.results[index] as NSDictionary
        let frame = self.carousel.frame
        
        
       
        let title = (recipe["title"]! as? String)!
        print(title)
        print("*********************************************")
        
        //Get Missed recipe count
        let missed = (recipe["missedIngredients"]! as! [NSDictionary])
        let used = (recipe["usedIngredientCount"]! as! Int)
        
        var ownedIngredients : String?
        
        //owned ingredients
        if(missed.count == 0){
            ownedIngredients = "You have all the ingredients to make this recipe!"
        }
        else{
            ownedIngredients = "You have \(missed.count / missed.count+used) more ingredients to make this recipe!"
        }

        //default image
        var image = UIImage(named: "RecipMeIcon")
        
        //get image
        let url = URL(string: recipe["image"]! as! String)
        if(url != nil) {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                image = UIImage(data: data)
            }
        }
        
        //get yield
        let yield = "0 servings"
        
        //get total time
        let time = 0
        
        if view != nil {
            let itemView = view as! CarouselView
            print("SET")
            itemView.set(title: title, image: image!, totalTime: time, yield: yield, ownedIngredients: ownedIngredients!)
            return itemView
        } else {
            print("MAKE")
            itemView = CarouselView(title: title, image: image!, totalTime: time, yield: yield, ownedIngredients: ownedIngredients!)
        }
        }
        return itemView
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        //self.showLoadingScreen()
        if(sharedRecipMeModel.kitchenChanged == true) {
            sharedRecipMeModel.searchData(completionHandler: {_ in
                print("carousel completion handler")
                self.carousel.reloadData()
                self.hideLoadingScreen()
            })
        } else {
            self.hideLoadingScreen()
        }
    }
}

