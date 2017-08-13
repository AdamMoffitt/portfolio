//
//  TableTableViewCellDelegate.swift
//  RecipMe
//
//  Created by Adam Moffitt on 4/28/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
        func tableViewCell(singleTapActionDelegatedFrom cell: RecipMeTableViewCell)
        func tableViewCell(doubleTapActionDelegatedFrom cell: RecipMeTableViewCell)
}

