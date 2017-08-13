//
//  RecipMeTableViewCell.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/3/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class RecipMeTableViewCell: UITableViewCell {
    
    @IBOutlet var recipeName: UILabel!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var usedIngredientsCountLabel: UILabel!
   
    @IBOutlet var missingIngredientsCountLabel: UILabel!
    
    @IBOutlet var infoView: UIView!
    var recipeId: Int?
    
    private var tapCounter = 0
    var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getRecipeId() -> Int {
        return self.recipeId!
    }
    
    func setRecipeId(id:Int) {
        self.recipeId = id
    }
    
    func tapAction() {
        
        if tapCounter == 0 {
            DispatchQueue.global(qos: .background).async {
                usleep(250000)
                if self.tapCounter > 1 {
                    self.doubleTapAction()
                } else {
                    self.singleTapAction()
                }
                self.tapCounter = 0
            }
        }
        tapCounter += 1
    }
    
    func singleTapAction() {
        delegate?.tableViewCell(singleTapActionDelegatedFrom: self)
    }
    
    func doubleTapAction() {
        delegate?.tableViewCell(doubleTapActionDelegatedFrom: self)
    }
    
}
