//
//  SelectOptionsViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 3/5/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SelectOptionsViewController: UIViewController {
    var parentVC:CompanyPageViewController!
    var data = [AnyObject]() {
        didSet {
            teamsSelection?.reloadData()
        }
    }
    var action:String!
    var boundsW:CGFloat = 0.0
    var boundsH:CGFloat = 0.0
    var promptString:String!
    var prompt:UILabel!
    var entry:UITextField!
    var popup:UIView!
    var cancel:UIButton!
    var orderTotal = 0.0
    var totalLabel:UILabel!
    var nextButton:UIButton!
    var buying:Bool!
    var price:Float!
    var teamsSelection:UITableView!
    var popupHeight:NSLayoutConstraint!
    var total:Float!
    var complete:UIButton!
    var back:UIButton!
    var errorLabel:UILabel!
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUp()
    }
    
    func startUp(){
        self.definesPresentationContext = true
        self.view.clipsToBounds = true
        self.view.backgroundColor = .clear
        self.total = 0.0
        createPopup()
        createCancel()
        createPrompt()
        createEntry()
        createTotalLabel()
        createTeamsSelection()
        createNextButton()
        createComplete()
        createBack()
        createErrorLabel()
        setConstraints()
    }
    
    func createComplete(){
        complete = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.1, height: boundsH * 0.1))
        complete.alpha = 0
        complete.setTitle("Complete", for: .normal)
        complete.translatesAutoresizingMaskIntoConstraints = false
        self.setTotal()
        complete.addTarget(self, action: #selector(completeStockTransfer), for: .touchUpInside)
        popup.addSubview(complete)
    }
    
    func createBack(){
        back = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.15, height: boundsH * 0.15))
        back.alpha = 0
        back.setTitle("Back", for: .normal)
        back.titleLabel?.font = UIFont(name: "DidactGothic-Regular", size: 14)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addTarget(self, action: #selector(backToTransaction), for: .touchUpInside)
        popup.addSubview(back)
    }
    
    func createTeamsSelection(){
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height
        teamsSelection = UITableView(frame: CGRect(x: 0, y: 0, width: boundsW * 0.9, height: boundsH * 0.9))
        teamsSelection.register(SelectionToggleCell.self, forCellReuseIdentifier: "SelectionToggleCell")
        teamsSelection.rowHeight = UITableViewAutomaticDimension
        teamsSelection.estimatedRowHeight = 100
        teamsSelection.translatesAutoresizingMaskIntoConstraints = false
        teamsSelection.dataSource = self
        teamsSelection.delegate = self
        teamsSelection.backgroundColor = UIColor.white
        teamsSelection.alpha = 0
        popup.addSubview(teamsSelection)
    }
    
    func createErrorLabel(){
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.5))
        errorLabel.alpha = 0
        errorLabel.text = ""
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.font = UIFont(name: "DidactGothic-Regular", size: 18)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.numberOfLines = 0
        popup.addSubview(errorLabel)
    }
    
    func createTotalLabel(){
        totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.5))
        totalLabel.text = "$0.00"
        totalLabel.textAlignment = .center
        totalLabel.textColor = .white
        totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 36)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.numberOfLines = 0
        popup.addSubview(totalLabel)
    }
    
    func createNextButton(){
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.1, height: boundsH * 0.1))
        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(confirmQuantity), for: .touchUpInside)
        popup.addSubview(nextButton)
    }
    
    @objc func confirmQuantity(){
        let value:String! = entry.text!
        if value != "" && Float(value!) != 0 {
            parentVC.quantity = Int(value)!
            transitionOptions()
        } else {
            totalLabel.text = "Quantity cannot be zero"
            totalLabel.textColor = .red
            totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 18)
        }
    }
    
    @objc func completeStockTransfer(){
        if(parentVC.selectedTeam.row == -1) {
            errorLabel.text = "Please select a team"
            return
        }
        let selectedTeam = data[parentVC.selectedTeam.row] as! Team
        
        if(action == "purchase" && total != nil && total > selectedTeam.userBalance){ // TODO got fatal error unwrapping nil here because total was nill. FIX, total should never be nil. Adding function setStock because i think the error was happening because total was set in textfieldDidEndEditing, and so if the user didnt click out of the textbox before hitting complete, total would be nil
            errorLabel.text = "You don't have enough money"
        }
        else if (action == "sale" && parentVC.quantity > selectedTeam.stockQuantity) {
            errorLabel.text = "You can't sell that many stocks"
        }
        else {
            if(action == "purchase") {
                parentVC.isPurchase = true
            } else {
                parentVC.isPurchase = false
            }
            parentVC.completeStockTransfer()
        }
    }
    
    func createPopup(){
        popup = UIView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.backgroundColor = FunduModel.shared.funduColor
        popup.layer.cornerRadius = 5
        popup.alpha = 0.95
        self.view.addSubview(popup)
    }
    
    func createPrompt(){
        prompt = UILabel(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.5))
        prompt.text = promptString
        prompt.textAlignment = .center
        prompt.textColor = .white
        prompt.font = UIFont(name: "DidactGothic-Regular", size: 24)
        prompt.translatesAutoresizingMaskIntoConstraints = false
        prompt.numberOfLines = 0
        popup.addSubview(prompt)
    }
    
    func createEntry(){
        entry = UITextField(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.2))
        entry.translatesAutoresizingMaskIntoConstraints = false
        //Add something here to toggle between buy and sell
        entry.placeholder = "Number of shares"
        entry.textAlignment = .center
        entry.layer.cornerRadius = 5
        entry.keyboardType = .numberPad
        entry.delegate = self
        entry.clearsOnBeginEditing = true
        entry.backgroundColor = .white
        popup.addSubview(entry)
    }
    
    func createCancel(){
        cancel = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.1, height: boundsH * 0.1))
        cancel.setImage(UIImage(named: "close"), for: .normal)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(cancelMenu), for: .touchUpInside)
        popup.addSubview(cancel)
    }
    
    @objc func cancelMenu() {
        cleanUp()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cleanUp(){
        prompt.removeFromSuperview()
        entry.removeFromSuperview()
        popup.removeFromSuperview()
        cancel.removeFromSuperview()
        totalLabel.removeFromSuperview()
        nextButton.removeFromSuperview()
        teamsSelection.removeFromSuperview()
        complete.removeFromSuperview()
        back.removeFromSuperview()
        errorLabel.removeFromSuperview()
    }
    
    func transitionOptions(){
        UIView.animate(withDuration: 0.5, animations: {
            self.teamsSelection.alpha = 1
            self.complete.alpha = 1
            self.back.alpha = 1
            self.errorLabel.alpha = 1
            self.popup.bounds = CGRect(x: 0, y: 0, width: self.popup.bounds.width, height: self.popup.bounds.height * 1.6)
            self.popupHeight.isActive = false
            self.popupHeight = self.popup.heightAnchor.constraint(equalToConstant: self.popup.bounds.height * 1.1)
            self.popupHeight.isActive = true
            self.popup.setNeedsDisplay()
            self.popup.updateConstraints()
            self.totalLabel.alpha = 0
            self.nextButton.alpha = 0
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = "."
            formatter.generatesDecimalNumbers = true
            formatter.locale = .current
            if self.total != nil {
                self.prompt.text = "Select a team to apply the \(self.action!) of \(self.parentVC.quantity) shares for \(formatter.string(from: NSNumber(value: self.total!))!) to"
            }
            self.entry.alpha = 0
        })
    }
    
    /*
 
     var currencyFormatter = NSNumberFormatter()
     currencyFormatter.usesGroupingSeparator = true
     currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
     // localize to your grouping and decimal separator
     currencyFormatter.locale = NSLocale.currentLocale()
     var priceString = currencyFormatter.stringFromNumber(9999.99)
     print(priceString) // Displays $9,999.99 in the US locale
     
    */
    
    @objc func backToTransaction(){
        UIView.animate(withDuration: 0.5, animations: {
            self.complete.alpha = 0
            self.back.alpha = 0
            self.errorLabel.alpha = 0
            self.teamsSelection.alpha = 0
            self.popup.bounds = CGRect(x: 0, y: 0, width: self.boundsW, height: self.boundsH)
            self.popupHeight.isActive = false
            self.popupHeight = self.popup.heightAnchor.constraint(equalToConstant: self.boundsH)
            self.popupHeight.isActive = true
            self.popup.setNeedsDisplay()
            self.popup.updateConstraints()
            let cell = self.teamsSelection.cellForRow(at: self.parentVC.selectedTeam)
            cell?.accessoryType = .none
            self.parentVC.selectedTeam = IndexPath(row: -1, section: 0)
            self.totalLabel.alpha = 1
            self.prompt.text = self.promptString
            self.nextButton.alpha = 1
            self.errorLabel.text = ""
            self.entry.alpha = 1
        })
    }
    
    func setConstraints(){
        popupHeight = popup.heightAnchor.constraint(equalToConstant: boundsH)
        popupHeight.isActive = true
        popup.widthAnchor.constraint(equalToConstant: boundsW).isActive = true
        popup.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        popup.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: boundsW * 0.1).isActive = true
        cancel.topAnchor.constraintEqualToSystemSpacingBelow(popup.topAnchor, multiplier: 0.6).isActive = true
        cancel.trailingAnchor.constraint(equalTo: popup.trailingAnchor).isActive = true
        back.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        back.widthAnchor.constraint(equalToConstant: boundsW * 0.2).isActive = true
        back.topAnchor.constraintEqualToSystemSpacingBelow(popup.topAnchor, multiplier: 0.6).isActive = true
        back.leadingAnchor.constraintEqualToSystemSpacingAfter(popup.leadingAnchor, multiplier: 0.3).isActive = true
        prompt.heightAnchor.constraint(equalToConstant: boundsH * 0.5).isActive = true
        prompt.widthAnchor.constraint(equalToConstant: boundsW * 0.8).isActive = true
        prompt.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        prompt.topAnchor.constraintEqualToSystemSpacingBelow(popup.topAnchor, multiplier: 0.2).isActive = true
        entry.topAnchor.constraintEqualToSystemSpacingBelow(prompt.bottomAnchor, multiplier: 0.1).isActive = true
        entry.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        entry.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        entry.widthAnchor.constraint(equalToConstant: boundsW * 0.5).isActive = true
        totalLabel.topAnchor.constraintEqualToSystemSpacingBelow(entry.bottomAnchor, multiplier: 4).isActive = true
        totalLabel.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        totalLabel.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        totalLabel.widthAnchor.constraint(equalToConstant: boundsW).isActive = true
        nextButton.topAnchor.constraintEqualToSystemSpacingBelow(totalLabel.bottomAnchor, multiplier: 1).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: boundsW * 0.5).isActive = true
        teamsSelection.widthAnchor.constraint(equalToConstant: boundsW * 0.9).isActive = true
        teamsSelection.heightAnchor.constraint(equalToConstant: boundsH * 0.9).isActive = true
        teamsSelection.topAnchor.constraintEqualToSystemSpacingBelow(prompt.bottomAnchor, multiplier: 0.3).isActive = true
        teamsSelection.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        errorLabel.topAnchor.constraintEqualToSystemSpacingBelow(teamsSelection.bottomAnchor, multiplier: 0.5).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        errorLabel.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: boundsW).isActive = true
        complete.topAnchor.constraintEqualToSystemSpacingBelow(errorLabel.bottomAnchor, multiplier: 2).isActive = true
        complete.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        complete.heightAnchor.constraint(equalToConstant: boundsH * 0.1).isActive = true
        complete.widthAnchor.constraint(equalToConstant: boundsW * 0.5).isActive = true
    }
    
    func waitResponse(){
        UIView.animate(withDuration: 0.5, animations: {
            self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.boundsW * 0.5, height: self.boundsH * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
            self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            self.popup.bounds = CGRect(x: 0, y: 0, width: self.boundsW, height: self.boundsH)
            self.popupHeight.isActive = false
            self.popupHeight = self.popup.heightAnchor.constraint(equalToConstant: self.boundsH)
            self.popupHeight.isActive = true
            self.popup.setNeedsDisplay()
            self.popup.updateConstraints()
            self.entry.removeFromSuperview()
            self.prompt.removeFromSuperview()
            self.cancel.removeFromSuperview()
            self.totalLabel.removeFromSuperview()
            self.nextButton.removeFromSuperview()
            self.teamsSelection.removeFromSuperview()
            self.complete.removeFromSuperview()
            self.back.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.popup.addSubview(self.activityIndicatorView)
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.popup.centerXAnchor).isActive = true
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.popup.centerYAnchor).isActive = true
            self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.boundsH * 0.5).isActive = true
            self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.boundsW * 0.5).isActive = true
            self.activityIndicatorView.startAnimating()
        })
    }
    
    func success(){
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.5))
        label.alpha = 1
        label.text = "Success!"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "DidactGothic-Regular", size: 44)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        popup.addSubview(label)
        label.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: popup.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: popup.heightAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: popup.widthAnchor).isActive = true
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
            self.cleanUp()
            self.parentVC.etGoHome()
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func fail(){
        
    }

}

extension SelectOptionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Reset the currently selected cell, whenever something else is pressed deselect
        let alreadySelected = tableView.cellForRow(at: parentVC.selectedTeam)
        alreadySelected?.accessoryType = .none
        
        //See what we picked, if it was the selected cell reset things
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell != alreadySelected {
                cell.accessoryType = .checkmark
                parentVC.selectedTeam = indexPath
            } else {
                parentVC.selectedTeam = IndexPath(row: -1, section: 0)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//        parentVC.selectedTeam = IndexPath(row: -1, section: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


extension SelectOptionsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionToggleCell", for: indexPath) as! SelectionToggleCell
        let team = data[indexPath.row] as! Team
        cell.setupViews(text: team.teamName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func setTotal() {
        if entry.text != nil && Float(entry.text!) != nil {
            self.total = (Float(entry.text!)! * price)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.generatesDecimalNumbers = true
        formatter.locale = .current
        totalLabel.text = formatter.string(from: NSNumber(value: total))
        totalLabel.textColor = .white
        totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 36)
        totalLabel.setNeedsLayout()
    }
}

extension SelectOptionsViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            setTotal()
        }
    }
}
