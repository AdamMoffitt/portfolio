//
//  RecipMeViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import Foundation
import DGElasticPullToRefresh
import SCLAlertView
import NVActivityIndicatorView

/*
 Not surprising due to the name of the view controller, this is where the main magic of RecipMe happens. On loading the view controller, the searchData() function in RecipMeModel is called, which performs the JSON requests to the spoonacular API based on the user's ingredients in their kitchen. While the data is being pulled from the internet, the Loading screen view is shown (hence RecipMeViewController inherits from LoadingViewController). Once the searchData() method is finished, the tableView is reloaded with the data on possible recipes that can be made with the user's kitchen ingredients. Tapping on a cell loads another view controller (RecipeViewController) with more detailed information about the recipe that it obtains by making another API call.
 */

class RecipMeViewController: LoadingViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    let sharedRecipMeModel = RecipMeModel.shared
    var kitchen : [String: FoodItem]?
    var refreshControl: UIRefreshControl?
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWillAppear(true)
        
        let loadingElasticView = DGElasticPullToRefreshLoadingViewCircle()
        loadingElasticView.tintColor = UIColor(red: 255/255.0, green: 133/255.0, blue: 85/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self?.searchRecipes()
                self?.tableView.dg_stopLoading()
            })
            }, loadingView: loadingElasticView)
        self.tableView.dg_setPullToRefreshFillColor(UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0))
        self.tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }
    
    deinit {
        self.tableView.dg_removePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        kitchen = sharedRecipMeModel.getMyKitchen()
        
        //if kitchen is empty, show error message
        if(kitchen?.isEmpty)!{
            let alert = SCLAlertView()
            alert.showInfo("Empty Kitchen!",
                           subTitle: "Looks like your kitchen is empty! Click the Add button on the top right to add items to your kitchen and get recipe suggestions!")
        }
        else {
            searchRecipes()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.viewDidAppear(true)
    }
    
    func searchRecipes() {
        refreshBarButton.isEnabled = false
        if(!sharedRecipMeModel.isSearching && sharedRecipMeModel.kitchenChanged==true){
            self.showLoadingScreen()
            sharedRecipMeModel.searchData(completionHandler: {_ in
                self.sharedRecipMeModel.isSearching = false
                self.refreshBarButton.isEnabled = true
                self.tableView.reloadData()
                self.hideLoadingScreen()
            })
        } else {//already searching
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe Cell", for: indexPath) as! RecipMeTableViewCell
        cell.delegate = self
        
        if (sharedRecipMeModel.recipeResults.isEmpty){
            //no recipes
        }
        else{
            let count = indexPath.row
            let recipe = sharedRecipMeModel.recipeResults[count] as Recipe
            cell.recipeName.text = recipe.title
            
            //Get Used Ingredients Count
            let used = recipe.usedIngredientsCount
            cell.usedIngredientsCountLabel.text = "Used: \(used)"
            
            let missed = recipe.missingIngredientsCount
            cell.missingIngredientsCountLabel.text = "missed: \(missed)"
            
            //get image
            let image = recipe.image
            cell.recipeImage.image = image
            
            cell.infoView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            gradientLayer.frame = cell.infoView.bounds
            gradientLayer.colors = [UIColor.darkGray, UIColor.clear]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
            cell.infoView.layer.addSublayer(gradientLayer)
            
            let recipeId = recipe.id
            cell.setRecipeId(id: recipeId)
        }
        
        //Return the cell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(sharedRecipMeModel.results.count < 1){
            return 0
        }
        else {
            return sharedRecipMeModel.results.count
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        if  segue.identifier! == "ShowRecipeSegue"
        {
            if let indexPath = tableView.indexPathForSelectedRow{
                let selectedRow = indexPath.row
                if let destination = segue.destination as? RecipeViewController {
                    if let recipeIndex = tableView.indexPathForSelectedRow?.row
                    {
                        destination.recipeId = sharedRecipMeModel.recipeResults[recipeIndex].id
                        destination.recipeIndex = recipeIndex
                    }
                }
            }
        }
        else {//unkown segue
        }
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        searchRecipes()
    }
}

extension RecipMeViewController:TableViewCellDelegate {
    
    func tableViewCell(singleTapActionDelegatedFrom cell: RecipMeTableViewCell) {
        
        let indexPath = tableView.indexPath(for: cell)
        
        let recipe = sharedRecipMeModel.recipeResults[(indexPath?.row)!] as Recipe
        
        let usedIngredients = recipe.usedIngredients as? [NSDictionary]
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
        let missingIngredients = recipe.missingIngredients as? [NSDictionary]
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
        
        DispatchQueue.main.sync {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        
        DispatchQueue.main.async {
            let alertView = SCLAlertView()
            
            // Create the subview
            let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 150))
            
            let x = (subview.frame.width - 180) / 2
            
            let usedLabel = UILabel(frame: CGRect(x: x, y: subview.frame.minY, width: 200, height: 20))
            usedLabel.text = "Used Ingredients: "
            
            subview.addSubview(usedLabel)
            let usedTextView = UITextView(frame: CGRect(x: x, y: subview.frame.minY+25, width: 200, height: 40))
            usedTextView.text = String(describing: usedIngredientsString)
            usedTextView.isEditable = false
            subview.addSubview(usedTextView)
            
            
            let missingLabel = UILabel(frame: CGRect(x: x, y: subview.frame.minY+70, width: 200, height: 20))
            missingLabel.text = "Missing Ingredients: "
            subview.addSubview(missingLabel)
            
            let missingTextView = UITextView(frame: CGRect(x: x, y: subview.frame.minY+95, width: 200, height: 40))
            missingTextView.text = String(describing: missingIngredientsString)
            missingTextView.isEditable = false
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
            
            alertView.addButton("Add to Favorites"){
                self.sharedRecipMeModel.addFavorite(recipe: recipe, index: (indexPath?.row)!)
            }
            
            alertView.addButton("View Recipe") {
                self.performSegue(withIdentifier: "ShowRecipeSegue", sender: nil)
            }
            var recipeImage = recipe.image
            alertView.showInfo("Recipe Details", subTitle: "", closeButtonTitle: "Close", circleIconImage: recipeImage)
        }
    }
    
    func tableViewCell(doubleTapActionDelegatedFrom cell: RecipMeTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        self.performSegue(withIdentifier: "ShowRecipeSegue", sender: tableView)
        /*guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RecipeViewController") as? RecipeViewController else {
         print("Could not instantiate view controller with identifier of type SecondViewController")
         return
         }
         self.navigationController?.pushViewController(vc, animated:true)*/
    }
}

