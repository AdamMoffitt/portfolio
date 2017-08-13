//
//  CarouselViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 3/2/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class CarouselViewController: LoadingViewController, iCarouselDataSource, iCarouselDelegate {

    
    //-----------------------------------------------------------------------------------------
    let sharedRecipMeModel = RecipMeModel.shared
    var carousel = iCarousel()
    
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
        let imageView: UIImageView
        let infoView: UIView
        
        let recipe = sharedRecipMeModel.results[index] as NSDictionary
        let frame = self.carousel.frame
        
        if view != nil {
            print("view is not null")
            itemView = view! as UIView
        } else {
            print("view is null")
            itemView = UIView(frame: CGRect(x: 0, y: 100, width: frame.width-30, height: frame.height-30))
            print("blahblah")
        }
        itemView.backgroundColor = UIColor.red
        
        /*       ----- Image View -----        */
        imageView = UIImageView(frame: CGRect(x: itemView.frame.minX, y: itemView.frame.minY, width: itemView.frame.width, height: itemView.frame.height-100))

            
        //default image
        imageView.image = UIImage(named: "RecipMeIcon")
        
        //get image
        let url = URL(string: recipe["image"]! as! String)
        if(url != nil) {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                imageView.image = UIImage(data: data)
            }
        }
        
        
        /*       ----- Info View -----        */
            //Has Title, total time, servings yield, and ingredients
        infoView = UIView(frame: CGRect(x: itemView.frame.minX, y: itemView.frame.minY + imageView.frame.height, width: itemView.frame.width, height: 100))
        infoView.backgroundColor = UIColor.blue
        print("info view")
        var titleLabel: UILabel
        var ownedIngredientsLabel: UILabel
        var yieldLabel: UILabel
        var totalTimeLabel: UILabel
        var totalTimeAmountLabel: UILabel
        
        titleLabel = UILabel(frame: CGRect(x: infoView.bounds.maxX, y: infoView.bounds.maxY, width: infoView.frame.width, height: 50))
        titleLabel.text = recipe["title"] as! String
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        //label.font = label.font.withSize(50)
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.tag = 1
        infoView.addSubview(titleLabel)
        
        //CONSTRAINTS FOR TITLE LABEL
        let horizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: infoView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        print("constraints 1")
        let verticalConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: infoView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        print("constraints 2")
        let widthConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: infoView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        print("constraints 3")
        let heightConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: infoView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        print("constraints 4")
        
        infoView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        print("info view constraints")
        
        ownedIngredientsLabel = UILabel(frame: itemView.bounds)
        ownedIngredientsLabel.backgroundColor = .clear
        ownedIngredientsLabel.textAlignment = .center
        ownedIngredientsLabel.font = ownedIngredientsLabel.font.withSize(20)
        ownedIngredientsLabel.tag = 2
        ownedIngredientsLabel.isHidden = true
        //infoView.addSubview(ownedIngredientsLabel)
        
        yieldLabel = UILabel()
        totalTimeLabel = UILabel()
        totalTimeAmountLabel = UILabel()
        
        /*
        let gradientMask = CAGradientLayer()
        gradientMask.frame = imageView.bounds;
        gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        imageView.layer.mask = gradientMask;
        print(" gradient mask")*/
       
        itemView.addSubview(imageView)
        //CONSTRAINTS FOR image view
        let horizontalConstraintImageView = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let verticalConstraintImageView = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let widthConstraintImageView = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let heightConstraintImageView = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (itemView.frame.height-50))
        
        itemView.addConstraints([horizontalConstraintImageView, verticalConstraintImageView, widthConstraintImageView, heightConstraintImageView])
        
        print("image view constraints")
        
        itemView.addSubview(infoView)
        //CONSTRAINTS FOR Info view
        let horizontalConstraintInfoView = NSLayoutConstraint(item: infoView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let verticalConstraintInfoView = NSLayoutConstraint(item: infoView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let widthConstraintInfoView = NSLayoutConstraint(item: infoView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let heightConstraintInfoView = NSLayoutConstraint(item: infoView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50)
        
        itemView.addConstraints([horizontalConstraintInfoView, verticalConstraintInfoView, widthConstraintInfoView, heightConstraintInfoView])
        
        print("info view constraints")
        
        
        return itemView
}

    @IBAction func refreshButtonPressed(_ sender: Any) {
        print("carousel refresh button pressed")
        self.showLoadingScreen()
        if(sharedRecipMeModel.kitchenChanged == true) {
            sharedRecipMeModel.searchData(completionHandler: {_ in
                print("completion handler")
                self.carousel.reloadData()
                self.hideLoadingScreen()
            })
        } else {
            self.carousel.reloadData()
            self.hideLoadingScreen()
        }
    }
}

//-----------------------------------------------------------------------------------------

/*
    var refreshControl: UIRefreshControl?
    let sharedRecipMeModel = RecipMeModel.shared
    @IBOutlet var carousel: iCarousel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.carousel.delegate = self
        self.carousel.dataSource = self
         sharedRecipMeModel.searchData(completionHandler: {_ in
            print("completion handler")
            self.carousel.reloadData()
            self.hideLoadingScreen()
        })
        carousel.type = .rotary
        //carousel.centerItemWhenSelected = true
        carousel.scrollToItemBoundary = true
        //carousel.iCarouselOptionShowBackfaces = false
        carousel.clipsToBounds = true
        //carousel.autoscroll = 0.1
        
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        print("carousel results count : \(sharedRecipMeModel.results.count)")
        return sharedRecipMeModel.results.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        print("loading carousel!!!!!!!!!!!!!!")
        var label: UILabel
        var itemView: UIImageView
        var ownedIngredientsLabel: UILabel
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
            ownedIngredientsLabel = itemView.viewWithTag(2) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            itemView.image = UIImage(named: "RecipMeIcon")
            itemView.contentMode = UIViewContentMode.scaleAspectFit
            
            let gradientMask = CAGradientLayer()
            gradientMask.frame = itemView.bounds;
            gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
            itemView.layer.mask = gradientMask;
            
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            //label.font = label.font.withSize(50)
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            label.tag = 1
            itemView.addSubview(label)
            
            let leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal,
                                                   toItem: itemView, attribute: .leading,
                                                   multiplier: 1.0, constant: 0.0)
            let trailingConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal,
                                                   toItem: itemView, attribute: .trailing,
                                                   multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute,
                                                   multiplier: 1.0, constant: 300.0)
            let bottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal,
                                                   toItem: itemView, attribute: .bottom,
                                                   multiplier: 0.95, constant: 0.0)
            
            itemView.addConstraints([leadingConstraint, trailingConstraint, heightConstraint, bottomConstraint])
            
            ownedIngredientsLabel = UILabel(frame: itemView.bounds)
            ownedIngredientsLabel.backgroundColor = .clear
            ownedIngredientsLabel.textAlignment = .center
            ownedIngredientsLabel.font = ownedIngredientsLabel.font.withSize(20)
            ownedIngredientsLabel.tag = 2
            ownedIngredientsLabel.isHidden = true
            itemView.addSubview(ownedIngredientsLabel)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        
        let recipe = sharedRecipMeModel.results[index] as NSDictionary
        
        let title = recipe["title"]! as? String 
        label.text = "\(title!)"
        print("carousel Title: \(title!)")
        
        //Get Missing ingredient count
        let missed = recipe["missedIngredients"]! as! [NSDictionary]
    
        //Get user ingredient count
        let used = recipe["usedIngredientCount"]! as! Int
        
        if(missed.count == 0){
            ownedIngredientsLabel.text = "You have all the ingredients to make this recipe!"
            print("carousel owned ingredients: \((ownedIngredientsLabel.text)!)")
        }
        else{
            ownedIngredientsLabel.text = "You have \(used) / \((missed.count+used)) ingredients to make this recipe!"
            print("carousel owned ingredients: \((ownedIngredientsLabel.text)!)")
        }

        //get image
        let url = URL(string: recipe["image"]! as! String)
        if(url != nil) {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                itemView.image = UIImage(data: data)
            }
        }
        
        //add to view
        //recipeId = recipe["id"] as! Int
        
        /*
        //BACK VIEW
        var backView : UIView!
        var backImage : UIImageView!
        var backLabel : UILabel!
        var backTextView : UITextView!
        var singleTap : UITapGestureRecognizer?
        
        backView = UIView(frame: itemView.frame)
        
        backLabel = UILabel(frame: CGRect(x: backView.bounds.minX, y: backView.bounds.minY, width: itemView.frame.height, height: itemView.frame.height))
        backLabel.textAlignment = NSTextAlignment.center
        backLabel.text = "no recipe chosen"
        
        backImage = UIImageView(frame: CGRect(x: backView.bounds.minX, y: backView.bounds.minY, width: CARD_WIDTH, height: CARD_HEIGHT/4))
        backImage.addSubview(backLabel)
        backImage.alpha = 0.5
        backImage.contentMode = UIViewContentMode.scaleAspectFill
        backImage.clipsToBounds = true
        
        
        backTextView = UITextView()
        backTextView.isEditable = false
        backTextView = UITextView(frame: CGRect(x: backView.bounds.minX, y: backView.bounds.minY + CARD_HEIGHT/4, width: CARD_WIDTH, height: (3/4)*CARD_HEIGHT))
        backTextView.isScrollEnabled = true
        backTextView.text = "no recipe selected"
        
        singleTap = UITapGestureRecognizer()
        singleTap?.numberOfTapsRequired = 1
        singleTap?.addTarget(self, action: #selector(DraggableViewBackground.cardSingleTapped))
        
        backView.addSubview(backImage)
        backView.addSubview(backTextView)
        backView.isHidden = true
        backView.addGestureRecognizer(singleTap!)

        itemView.addSubview(backView)
 */
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        //show recipe
        
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
 }
    */



