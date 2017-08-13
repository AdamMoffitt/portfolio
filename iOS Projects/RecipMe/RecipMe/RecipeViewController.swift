//
//  RecipeViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/5/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class RecipeViewController: LoadingViewController {
    
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var details: UITextView!
    var recipe = Recipe()
    var recipeId = 0
    var recipeIndex = 0
    var newRecipe = Recipe()
    var sharedRecipMeModel = RecipMeModel.shared
    
    @IBOutlet var favoriteBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        getRecipe()
    }
    
    func setRecipe(recipe: Recipe){
        self.recipe = recipe
        DispatchQueue.global(qos: .userInitiated).async { // 1
            var image = UIImage(named: "RecipMeIcon")
            if(recipe.image != nil){
                    image = recipe.image
            }
            else if(recipe.imageURL != nil) {
                if let data = try? Data(contentsOf: NSURL(string: recipe.imageURL)! as URL) {
                    image = UIImage(data: data)
                }
            }
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.recipeImage.bounds
            gradientLayer.colors = [UIColor.darkGray, UIColor.clear]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
            DispatchQueue.main.async {
                self.recipeImage.image = image
                self.recipeImage.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                
                self.recipeImage.layer.addSublayer(gradientLayer)
                self.name.text = recipe.title
                self.details.text = recipe.extendedInstructions
                if (recipe.isFavorite) {
                    self.favoriteBarButton.tintColor = UIColor.yellow
                }
            }
        }
        //HERE GOING TO MAKE MISSING INGREDIENTS SHOW UP IN RED, INCLUDED INGREDIENTS SHOW UP IN BLUE
       // let missingIngr = NSMutableAttributedString(string: recipe., attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
        
        //myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:2,length:4))

        
    }
    
    func getRecipe() {
        self.showLoadingScreen()
        sharedRecipMeModel.getRecipe(recipeId: recipeId, completionHandler: {
            recipe -> Void in
                //update RecipeResults recipe with extended information
                if let rIndex = self.sharedRecipMeModel.recipeResults.index(where: {$0.id==recipe.id}){
                    self.sharedRecipMeModel.recipeResults[rIndex] = recipe
                }
                self.setRecipe(recipe: recipe)
                self.hideLoadingScreen()
        })
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        self.favoriteBarButton.tintColor = UIColor.yellow
        sharedRecipMeModel.addFavorite(recipe: self.recipe, index: self.recipeIndex)
    }
}
