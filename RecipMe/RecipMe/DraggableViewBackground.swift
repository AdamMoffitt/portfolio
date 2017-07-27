//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import GTProgressBar
import SCLAlertView

class DraggableViewBackground: UIView, DraggableViewDelegate {
    var allCards: [DraggableView]!
    let sharedRecipMeModel = RecipMeModel.shared
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 290
    
    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    
    var backView : UIView!
    var backImage : UIImageView!
    var backLabel : UILabel!
    var backTextView : UITextView!
    
    var loadingView : UIView!
    var loadingImage : UIImage!
    var loadingImageView : UIImageView!
    var loadingLabel : UILabel!
    var progressBar : GTProgressBar!
    var singleTap : UITapGestureRecognizer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.layoutSubviews()
        self.setupView()
        
    }
    
    init() {
        //trash initializer just to make never user framein swiftcardviewcontroller
        super.init(frame: CGRect(x: 0 , y: 0, width: CARD_WIDTH, height: CARD_HEIGHT))
    }
    
    func setupView() -> Void {
        //self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        //let i = UIImage(named: "cuttingBoard.png")!
        //self.backgroundColor = UIColor(patternImage: i)
        self.addBackground()
        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 35, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        xButton.setImage(UIImage(named: "xButton"), for: UIControlState())
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)
        
        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 85, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        checkButton.setImage(UIImage(named: "checkButton"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        //BACK VIEW
        backView = UIView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        
        backLabel = UILabel(frame: CGRect(x: backView.bounds.minX, y: backView.bounds.minY + (3*CARD_HEIGHT/4), width: CARD_WIDTH, height: CARD_HEIGHT/4))
        backLabel.textAlignment = NSTextAlignment.center
        backLabel.text = "no recipe chosen"
        backLabel.textColor = UIColor.black
        
        backImage = UIImageView(frame: CGRect(x: backView.bounds.minX, y: backView.bounds.minY, width: CARD_WIDTH, height: CARD_HEIGHT/4))
        backImage.addSubview(backLabel)
        backImage.alpha = 1
        backImage.contentMode = UIViewContentMode.scaleAspectFill
        backImage.clipsToBounds = true
        let gradientMask = CAGradientLayer()
        gradientMask.frame = backImage.bounds;
        gradientMask.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        backImage.layer.mask = gradientMask;
        
        
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
        
        
        //****************** Loading View *************************
        self.loadingView = UIView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        
        self.loadingView.backgroundColor = UIColor.darkGray
        self.loadingView.alpha = 0.8
        
        //self.loadingImage = UIImage(named: "simpsons-1")
        self.loadingImage = UIImage.animatedImageNamed("simpsons-", duration: 1.0)!
        
        self.loadingImageView = UIImageView(frame: CGRect(x: loadingView.bounds.minX, y: loadingView.bounds.minY, width: (CARD_WIDTH), height: (3*CARD_HEIGHT/4)))
        self.loadingImageView.image = loadingImage
        self.loadingImageView.contentMode = UIViewContentMode.scaleToFill
        self.loadingImageView.clipsToBounds = true
        
        progressBar = GTProgressBar(frame: CGRect(x: loadingView.bounds.minX, y: (loadingView.bounds.minY + ((3/4)*CARD_HEIGHT)), width: CARD_WIDTH, height: CARD_HEIGHT/4))
        progressBar.progress = 0
        progressBar.barBorderColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.barFillColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.barBackgroundColor = UIColor(red:0.77, green:0.93, blue:0.78, alpha:1.0)
        progressBar.barBorderWidth = 1
        progressBar.barFillInset = 2
        progressBar.labelTextColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        progressBar.font = UIFont.boldSystemFont(ofSize: 18)
        progressBar.barMaxHeight = 12
        
        self.loadingLabel = UILabel(frame: CGRect(x: loadingView.bounds.minX, y: (loadingView.bounds.minY + ((3/4)*CARD_HEIGHT)), width: CARD_WIDTH, height: CARD_HEIGHT/4))
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.backgroundColor = UIColor.white
        self.loadingLabel.textAlignment = .center
        
        self.loadingView.addSubview(loadingImageView)
        self.loadingView.addSubview(progressBar)
        
        self.addSubview(loadingView)
        //self.addSubview(loadingImageView)
        
        
        //self.addSubview(xButton)
        //self.addSubview(checkButton)
        
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
        
        DispatchQueue.global(qos: .background).async {
            
            let cardsData = self.loadCardsData()
            
            DispatchQueue.main.async {
                self.loadCards(cardsData: cardsData)
                self.loadingView.isHidden = true
                self.loadingImageView.isHidden = true
                self.progressBar.progress = 0
            }
        }
        
        self.addSubview(backView)
    }
    
    //get data to make a new draggable view, without making a new view so that you can run  it on background thread and speed up program
    func getNewDraggableViewDataAtIndex(_ index: NSInteger) -> DraggableViewData {
        
        let recipe = sharedRecipMeModel.results[index] as NSDictionary
        
        let title = (recipe["title"]! as? String)!
        
        //Get Missed recipe count
        let missed = (recipe["missedIngredients"]! as! [NSDictionary])
        _ = (recipe["usedIngredientCount"]! as! Int)
        
        var info : String?
        
        if(missed.count == 0){
            info = "You have all the ingredients to make this recipe!"
        }
        else{
            info = "You only need \(missed.count) more ingredients to make this recipe!"
        }
        
        //get image
        var image = UIImage(named: "RecipMeIcon")
        let id = recipe["id"] as! Int
        let urlString =  "https://spoonacular.com/recipeImages/\(String(describing: id))-636x393.jpg"
        let url = URL(string: urlString)
        
        if(url != nil) {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                image = UIImage(data: data)
            }
        }
        
        DispatchQueue.main.async {
            let progress = (round(100*(self.progressBar.progress + CGFloat(1.0/50.0)))/100)
            self.progressBar.barFillColor = UIColor(red:progress, green:0.80, blue:0.36, alpha:1.0)
            self.progressBar.progress = progress
            //progressBar.animateTo(progress: round(100*CGFloat(Double(progress) / Double(50)))/100)
        }
        
        if(image != nil) {
            let draggableViewData = DraggableViewData(title: title, info: info!, id: id, image: image!, imageURL: urlString, index: index)
            return draggableViewData
        }
        else {
            image = UIImage(named: "RecipMeIcon")
            let draggableViewData = DraggableViewData(title: title, info: info!, id: id, image: image!, imageURL: urlString, index: index)
            return draggableViewData
        }
        
    }
    
    class DraggableViewData: NSObject {
        
        var title: String
        var image : UIImage
        var info : String
        var imageURL : String
        var id : Int
        var index : Int
        
        init(title: String, info: String, id: Int, image: UIImage, imageURL: String, index: Int){
            self.title = title
            self.info = info
            self.id = id
            self.image = image
            self.imageURL = imageURL
            self.index = index
        }
        
    }
    
    //not used anymore, use getDraggableDataAtIndex
    func createDraggableViewWithDataAtIndex(_ index: NSInteger) -> DraggableView {
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        
        let recipe = sharedRecipMeModel.results[index] as NSDictionary
        
        let title = (recipe["title"]! as? String)!
        
        //Get Missed recipe count
        let missed = (recipe["missedIngredients"]! as! [NSDictionary])
        _ = (recipe["usedIngredientCount"]! as! Int)
        
        var info : String?
        
        if(missed.count == 0){
            info = "You have all the ingredients to make this recipe!"
        }
        else{
            info = "You only need \(missed.count) more ingredients to make this recipe!"
        }
        
        //get image
        var image = UIImage(named: "RecipMeIcon")
        let imageURL = recipe["image"]! as! String
        let url = URL(string: imageURL)
        
        if(url != nil) {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                image = UIImage(data: data)
            }
        }
        let id = (recipe["id"]! as! Int)
        
        draggableView.set(title: title, info: info!, image: image!, imageURL: imageURL, id: id, index: index)
        
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCardsData() -> [DraggableViewData] {
        var cardsData : [DraggableViewData] = []
        if sharedRecipMeModel.results.count > 0 {
            for i in 0 ..< sharedRecipMeModel.results.count {
                cardsData.append(self.getNewDraggableViewDataAtIndex(i))
            }
        }
        return cardsData
    }
    
    func loadCards(cardsData: [DraggableViewData]) -> Void {
        if cardsData.count > 0 {
            let numLoadedCardsCap = sharedRecipMeModel.results.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : sharedRecipMeModel.results.count
            for i in 0 ..< cardsData.count {
                //make new card
                let newCard: DraggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
                newCard.set(title: cardsData[i].title, info: cardsData[i].info, image: cardsData[i].image, imageURL: cardsData[i].imageURL, id: cardsData[i].id, index: cardsData[i].index)
                newCard.delegate = self
                
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }
    
    //DO SWIPE LEFT FUNCTIONALITY HERE
    func cardSwipedLeft(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    //DO SWIPE RIGHT FUNCTIONALITY HERE
    func cardSwipedRight(_ card: UIView) -> Void {
        
        let card = card as! DraggableView
        
        //Add the item to favorites
        if let title = card.recipeTitle, let image = card.recipeImage, let info = card.recipeInfo, let id = card.recipeId{
            sharedRecipMeModel.addFavorite(recipe: Recipe(title: title, image: image, info: info, id: id), index: cardsLoadedIndex)
        }
        
        //remove the card from the loaded cards array and load a new card
        loadedCards.remove(at: 0)
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    //DO SWIPE UP FUNCTIONALITY HERE
    func cardSwipedUp(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    //DO SWIPE DOWN FUNCTIONALITY HERE
    func cardSwipedDown(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    //if double tapped, show back view with full recipe information
    func cardDoubleTapped(_ card: UIView) -> Void {
        showFullRecipeCard(card: card)
    }
    
    //if single tapped
    func cardSingleTapped(_ card: UIView) -> Void {
        showRecipeDetails(recipeId: cardsLoadedIndex, card: card)
    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }
    
    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
    
    func getRecipe(recipeId: Int){
        
        if(recipeId != nil){
            let headers = [
                "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
                "Accept": "application/json"
            ]
            let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(recipeId)/information?includeNutrition=false")
            let request = NSMutableURLRequest(
                url: url! as URL,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main
            )
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                            completionHandler: { (dataOrNil, response, error) in
                                                                if let data = dataOrNil {
                                                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                        with: data, options:[]) as? NSDictionary {
                                                                        
                                                                        let recipe = (responseDictionary)
                                                                        
                                                                        
                                                                        
                                                                        if recipe["title"] != nil {
                                                                            if self.backLabel != nil {
                                                                                self.backLabel.text = recipe["title"] as? String
                                                                                self.backLabel.numberOfLines = 0
                                                                            }
                                                                        }
                                                                        //get image
                                                                        if recipe["image"] != nil {
                                                                            if self.backImage != nil {
                                                                                let imageUrl = URL(string: recipe["image"] as! String)
                                                                                let data = try? Data(contentsOf: imageUrl!)
                                                                                self.backImage.image = UIImage(data: data!)
                                                                            }
                                                                        }
                                                                        
                                                                        if recipe["instructions"] != nil {
                                                                            var textString = ""
                                                                            if(recipe["cookingMinutes"] != nil){
                                                                                textString.append("Cooking Minutes: \((String)(recipe["cookingMinutes"] as! Int))\n")
                                                                            }
                                                                            if(recipe["preparationMinutes"] != nil){
                                                                                textString.append("Preparation Minutes: \((String)(recipe["preparationMinutes"] as! Int))\n")
                                                                            }
                                                                            if(recipe["readyInMinutes"] != nil){
                                                                                textString.append("Ready in \((String)(recipe["readyInMinutes"] as! Int)) minutes!\n")
                                                                            }
                                                                            if(recipe["readyInMinutes"] != nil){
                                                                                textString.append("\nIngredients:\n")
                                                                                let ingr = recipe["extendedIngredients"] as! [NSDictionary]
                                                                                for (index, _) in ingr.enumerated() {
                                                                                    textString.append("\(index+1): \((ingr[index] )["originalString"]!)\n")
                                                                                }
                                                                            }
                                                                            if(recipe["instructions"] is NSNull){
                                                                                textString.append("\n\nVisit: \((recipe["sourceUrl"])!) for recipe instructions!")
                                                                            }else {
                                                                                textString.append("\nInstructions:\n \(recipe["instructions"] as! String))")
                                                                            }
                                                                            
                                                                            if self.backTextView != nil{
                                                                                self.backTextView.text = textString
                                                                                self.backTextView.isEditable = false
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
            });
            
            task.resume()
        }
        else{
            //recipe id is null
        }
    }
    
    func showFullRecipeCard(card: UIView) {
        getRecipe(recipeId: (loadedCards.first?.recipeId)!)
        self.backLabel.text = loadedCards[0].recipeTitleLabel.text
        self.backImage.image = loadedCards[0].recipeImageView.image
        self.backTextView.text = "Loading recipe..."
        
        UIView.transition(with: self.backView, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromRight, animations: {
            self.backView.isHidden = false
            self.bringSubview(toFront: self.backView)
        })
        
        UIView.transition(with: (loadedCards.first)!, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromRight, animations: {
            self.loadedCards.first!.isHidden = true
        })
        
        checkButton.isEnabled = false
        xButton.isEnabled = false
    }
    func showRecipeDetails (recipeId: Int, card: UIView){
        
        let recipe = sharedRecipMeModel.results[cardsLoadedIndex] as NSDictionary
        
        let usedIngredients = recipe["usedIngredients"] as? [NSDictionary]
        var usedIngredientsString = ""
        for i in usedIngredients! {
            var string = ""
            if(String(describing: i["unit"]!) != ""){
                string = String(describing: i["amount"]!) + " " +  String(describing: i["unit"]!) + " of " + String(describing: i["name"]!)
            } else {
                string = String(describing: i["amount"]!) + " " + String(describing: i["name"]!)
            }
            usedIngredientsString += string + "\n"
        }
        
        let missingIngredients = recipe["missedIngredients"] as? [NSDictionary]
        var missingIngredientsString = ""
        for i in missingIngredients! {
            var string = ""
            if(String(describing:i["unit"]!) != ""){
                string = String(describing: i["amount"]!) + " " + String(describing: i["unit"]!) + " of " + String(describing: i["name"]!)
            } else {
                string = String(describing: i["amount"]!) + " " + String(describing: i["name"]!)
            }
            missingIngredientsString += string + "\n"
        }
        
        DispatchQueue.main.async {
            let alertView = SCLAlertView()
            // Creat the subview
            let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 150))
            let x = (subview.frame.width - 180) / 2
            
            let usedLabel = UILabel(frame: CGRect(x: x, y: subview.frame.minY, width: 200, height: 20))
            usedLabel.text = "Used Ingredients: "
            subview.addSubview(usedLabel)
            let usedTextView = UITextView(frame: CGRect(x: x, y: subview.frame.minY+25, width: 200, height: 40))
            usedTextView.text = String(describing: usedIngredientsString)
            subview.addSubview(usedTextView)
            
            let missingLabel = UILabel(frame: CGRect(x: x, y: subview.frame.minY+70, width: 200, height: 20))
            missingLabel.text = "Missing Ingredients: "
            subview.addSubview(missingLabel)
            
            let missingTextView = UITextView(frame: CGRect(x: x, y: subview.frame.minY+95, width: 200, height: 40))
            missingTextView.text = String(describing: missingIngredientsString)
            subview.addSubview(missingTextView)
            
            // Add the subview to the alert's UI property
            alertView.customSubview = subview
            
            alertView.addButton("Add Missing to Shopping List"){
                for element in missingIngredients! {
                    //TODO add elements to shopping list
                }
            }
            
            //TODO: implement to allow purchase from amazon fresh!
            /*alertView.addButton("Order Missing Ingredients Now") {
             print("order ingredients with amazon fresh!")
             }*/
            
            alertView.addButton("View Recipe") {
               self.showFullRecipeCard(card: card)
            }
            //get image for icon
            let recipeID = recipe["id"] as? Int
            var recipeImage = UIImage(named: "RecipMeIcon")
            let url = URL(string: "https://spoonacular.com/recipeImages/\(String(describing: recipeID!))-90x90.jpg")
            if(url != nil) {
                if let data = try? Data(contentsOf: url!) {
                    recipeImage = UIImage(data: data)
                }
            }
            alertView.showInfo("Recipe Details", subTitle: "", closeButtonTitle: "Close", circleIconImage: recipeImage)
        }
    }
}

    extension UIView {
        func addBackground() {            // screen width and height:
            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height
            let imageViewBackground = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: width, height: height)))
            imageViewBackground.image = UIImage(named: "cuttingBoard.png")
            
            // you can change the content mode:
            imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
            
            self.addSubview(imageViewBackground)
            self.sendSubview(toBack: imageViewBackground)
        }
}

