//
//  FavoritesTableViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 2/23/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {

    let sharedRecipMeModel = RecipMeModel.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sharedRecipMeModel.favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell

        let recipe = sharedRecipMeModel.favorites[indexPath.row]
        cell.recipe = recipe
        cell.favoriteRecipeImageView.image = recipe.image
        let gradientMask = CAGradientLayer()
        gradientMask.frame = cell.favoriteRecipeImageView.bounds;
        gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        cell.favoriteRecipeImageView.layer.mask = gradientMask;
        
        
        cell.favoriteRecipeLabel.text = recipe.title

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        if  segue.identifier! == "ShowRecipeSegue"
        {
            if let indexPath = tableView.indexPathForSelectedRow{
                let selectedRow = indexPath.row
                if let destination = segue.destination as? RecipeViewController {
                    if let recipeIndex = tableView.indexPathForSelectedRow?.row
                    {
                        destination.recipeId = sharedRecipMeModel.favorites[recipeIndex].id
                        destination.recipeIndex = -1
                    }
                }
            }
        }
        else {
            //unkown segue
        }
    }    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let faveCell = tableView.cellForRow(at: indexPath) as! FavoritesTableViewCell
            // Delete the row from the data source
            
            sharedRecipMeModel.removeFavorite(index: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
