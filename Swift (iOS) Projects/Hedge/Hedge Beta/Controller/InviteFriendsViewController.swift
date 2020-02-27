//
//  InviteFriendsViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 3/8/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import SCLAlertView

class InviteFriendsViewController: UIViewController {

    var parentVC : UIViewController!
    var lookup = [String:String]()
    var data = [String]() {
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
    var teamName:String!
    var selectedFriends = Set<IndexPath>()
    var mode: String! // To indicate if leagues
    var leagueColor: String! // to pass back to league to create team
    var leagueName: String! // to pass back to league to create team
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUp()
    }
    
    func startUp(){
        self.definesPresentationContext = true
        self.view.clipsToBounds = true
        self.view.backgroundColor = .clear
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
        complete.addTarget(self, action: #selector(inviteFriends), for: .touchUpInside)
        popup.addSubview(complete)
    }
    
    func createBack(){
        back = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.2, height: boundsH * 0.1))
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
        totalLabel.text = ""
        totalLabel.textAlignment = .center
        totalLabel.textColor = .white
        totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 36)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.numberOfLines = 0
        popup.addSubview(totalLabel)
    }
    
    func createNextButton(){
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: boundsW * 0.1, height: boundsH * 0.1))
        nextButton.setTitle("Invite friends", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(showContacts), for: .touchUpInside)
        popup.addSubview(nextButton)
    }
    
    //Team name
    @objc func showContacts(){
        let value:String! = entry.text!
        if value != ""{
            loadingAnimation()
            nameIsUnique(teamName: value, completion: { (isUnique) in
                if(isUnique) {
                    self.teamName = value
                    self.transitionOptions()
                } else {
                    self.totalLabel.text = "That team name is already taken"
                    self.totalLabel.textColor = .red
                    self.totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 18)
                }
            })
        } else {
            self.totalLabel.text = "You must name your team"
            self.totalLabel.textColor = .red
            self.totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 18)
        }
    }
    
    func loadingAnimation() {
        self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.5).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.5).isActive = true
        self.activityIndicatorView.startAnimating()
    }
    
    func nameIsUnique(teamName: String, completion: @escaping (Bool) -> Void) {
        var urlString = "https://us-central1-hedge-beta.cloudfunctions.net/isNameUnique?teamName=\(FunduModel.shared.encodeForFirebaseKey(string: teamName))"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(urlString).validate().responseString { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeFromSuperview()
                    completion(Bool(value)!)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func inviteFriends(){
        //Make API call and start loading
        self.waitResponse()
        let id = NSUUID().uuidString
        let members = [FunduModel.shared.myUser.userID : FunduModel.shared.myUser.username]
        var pending = [String:String]()
        
        let newTeam = Team(newTeamName: teamName, members: members, teamManager: FunduModel.shared.myUser.userID, pending: pending, id: id)
        
        FunduModel.shared.newTeam(team: newTeam)
        
        sleep(1) // TODO add completion handlers to these functions, dont want to try and post to a team that doesnt exist yet
        FunduModel.shared.addteamIDToUser(userID: FunduModel.shared.myUser.userID, teamID: newTeam.teamID, teamName: newTeam.teamName)
        FunduModel.shared.addUserToTeam(userID: FunduModel.shared.myUser.userID, teamID: newTeam.teamID)

        FunduModel.shared.addTeamToHedgeLeague(newTeam: newTeam)
        
        for index in selectedFriends {
            
            FunduModel.shared.inviteUserToTeam(invitedID: lookup[data[index.row]]!, teamID: id)
            
            pending.updateValue(data[index.row], forKey: lookup[data[index.row]]!)
        }
        
        self.success(teamID: id)
    }
    
    func createPopup(){
        popup = UIView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        popup.layer.cornerRadius = 5
        popup.alpha = 0.95
        self.view.addSubview(popup)
    }
    
    func createPrompt(){
        prompt = UILabel(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.5))
        prompt.text = "Create a new team!"
        prompt.textAlignment = .center
        prompt.textColor = .white
        prompt.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        prompt.font = UIFont(name: "DidactGothic-Regular", size: 24)
        prompt.translatesAutoresizingMaskIntoConstraints = false
        prompt.numberOfLines = 0
        popup.addSubview(prompt)
    }
    
    func createEntry(){
        entry = UITextField(frame: CGRect(x: 0, y: 0, width: boundsW * 0.5, height: boundsH * 0.2))
        entry.translatesAutoresizingMaskIntoConstraints = false
        //Add something here to toggle between buy and sell
        entry.placeholder = "Team Name"
        entry.textAlignment = .center
        entry.layer.cornerRadius = 5
        entry.keyboardType = .default
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
            var currencyFormatter = NumberFormatter()
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = "."
            formatter.generatesDecimalNumbers = true
            formatter.locale = .current
            self.prompt.text = "Select users to invite!"
            self.entry.alpha = 0
        })
    }
        
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
            self.deselectAll()
            self.totalLabel.alpha = 1
            self.prompt.text = "Create a new team!"
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
    
    func deselectAll(){
        for index in selectedFriends {
            let cell = teamsSelection.cellForRow(at: index)
            cell?.accessoryType = .none
            selectedFriends.remove(index)
        }
    }
    
    func success(teamID: String){
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
            FunduModel.shared.loadUserTeams()
//            if self.parentVC is TeamsViewController {
//                (self.parentVC as! TeamsViewController).
//            }()
//            else if self.parentVC is UserLeaguesViewController {
//                (self.parentVC as! UserLeaguesViewController).createLeague(teamID: teamID, teamName: self.teamName, leagueName: self.leagueName, leagueColor: self.leagueColor)
//            }
//            else if self.parentVC is LeaguesBrowseViewController {
//                (self.parentVC as! UserLeaguesViewController).createLeague(teamID: teamID, teamName: self.teamName, leagueName: self.leagueName, leagueColor: self.leagueColor)
//            }
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func fail(){
        
    }
    
}

extension InviteFriendsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //See what we picked, if it was the selected cell reset things
        if let cell = tableView.cellForRow(at: indexPath) {
            if !selectedFriends.contains(indexPath) {
                cell.accessoryType = .checkmark
                selectedFriends.insert(indexPath)
            } else {
                cell.accessoryType = .none
                selectedFriends.remove(indexPath)
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


extension InviteFriendsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionToggleCell", for: indexPath) as! SelectionToggleCell
        cell.setupViews(text: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension InviteFriendsViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
//            total = (Float(textField.text!)! * price)
//            var currencyFormatter = NumberFormatter()
//            let formatter = NumberFormatter()
//            formatter.numberStyle = .currency
//            formatter.minimumFractionDigits = 2
//            formatter.maximumFractionDigits = 2
//            formatter.groupingSeparator = "."
//            formatter.generatesDecimalNumbers = true
//            formatter.locale = .current
//            totalLabel.text = formatter.string(from: NSNumber(value: total))
//            totalLabel.textColor = .white
//            totalLabel.font = UIFont(name: "DidactGothic-Regular", size: 36)
//            totalLabel.setNeedsLayout()
        }
    }
}

