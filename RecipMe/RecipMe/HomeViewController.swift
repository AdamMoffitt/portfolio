//
//  HomeViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var FeaturedItems : [FeaturedItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        FeaturedItems = [
//            FeaturedItem(title: "You have to try this lasagna!", description: "lasagna,lasagna,lasagna,lasagna,lasagna,lasagna,lasagna,lasagna,lasagna,", image: UIImage(named:"lasagna.png")!),
//            FeaturedItem(title:"This ice cream sandwitch is way too easy to be this GOOD", description:"yumyumyumyumyumyumyumyumyumyumyumyumyumyumyumyumyumyumyum", image: UIImage(named:"best-ice-cream-sandwich.png")!)
//        ]
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        
        if(indexPath.row % 2 == 0){
            //Create a cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeFeedTableViewCell1", for: indexPath) as! HomeFeedTableViewCell1
            let featuredItem = FeaturedItems[0]
            print("1")
            cell.titleLabel1.text = featuredItem.getTitle()
            print(featuredItem.getTitle())
            cell.descriptionLabel1.text = featuredItem.getDescription()
            print(featuredItem.getDescription())
            cell.imageLabel1.image = featuredItem.getImage()
            print(featuredItem.getImage())
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeFeedTableViewCell2", for: indexPath) as! HomeFeedTableViewCell2
            let featuredItem = FeaturedItems[1]
            print("2")
            cell.titleLabel2.text = featuredItem.getTitle()
            print(featuredItem.getTitle())
            cell.descriptionLabel2.text = featuredItem.getDescription()
            print(featuredItem.getDescription())
            cell.imageView2.image =  featuredItem.getImage()
            print(featuredItem.getImage())
            return cell
        }
       
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        // you need to implement this method too or you can't swipe to display the actions
//    }
//    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // the cells you would like the actions to appear needs to be editable
//        return true
//    }

}
