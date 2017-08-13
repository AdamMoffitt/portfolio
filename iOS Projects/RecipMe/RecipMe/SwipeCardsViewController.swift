//
//  SwipeCardsViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/16/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class SwipeCardsViewController: LoadingViewController {
    
    let sharedRecipMeModel = RecipMeModel.shared
    var kitchen : [String: FoodItem]?
    var draggableBackground: DraggableViewBackground = DraggableViewBackground()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if kitchen is empty, show error message
        if(sharedRecipMeModel.getMyKitchen().isEmpty){
            showEmptyKitchenError()
        }
        else{
            searchRecipes()
        }
        self.view.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin, .flexibleTopMargin]
        
        let frame = self.view.frame
        self.draggableBackground = DraggableViewBackground(frame: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height-self.bottomLayoutGuide.length))
        self.draggableBackground.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin, .flexibleTopMargin]
        self.view.addSubview(self.draggableBackground)
        
    }
    
    func viewWillAppear() {
        //if kitchen is empty, show error message
        if(sharedRecipMeModel.getMyKitchen().isEmpty){
            showEmptyKitchenError()
        }
        else{
            searchRecipes()
        }
    }
    
    func showEmptyKitchenError() {
        let alert = UIAlertController(title: "Empty Kitchen!",
                                      message: "Looks like your kitchen is empty! Click the Add button on the top right to add items to your kitchen and get recipe suggestions!",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay",
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        searchRecipes()
    }
    
    func searchRecipes() {
        self.showLoadingScreen()
        if(!self.sharedRecipMeModel.isSearching && self.sharedRecipMeModel.kitchenChanged){
            self.sharedRecipMeModel.searchData(completionHandler: {_ in
                self.sharedRecipMeModel.isSearching = false
                DispatchQueue.main.async{                          // Update UI
                    self.draggableBackground.setupView()
                }
                self.hideLoadingScreen()
            })
        } else {
            //already searching
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.viewDidAppear(true)
    }
    
}
