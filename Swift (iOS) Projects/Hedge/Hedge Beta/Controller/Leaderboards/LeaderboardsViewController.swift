//
//  LeaguesViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//
// Mail icon by Tommy Lau from Noun Project

import UIKit
import UIDropDown
import NVActivityIndicatorView
import SwiftyJSON
import SCLAlertView
import BBBadgeBarButtonItem
import AZDropdownMenu

class LeaderboardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, newLeagueDelegate {
    
    var drop: UIDropDown!
    let SharedFunduModel = FunduModel.shared
    var leagueMoneyLabel:UILabel!
    var leagueTableView:UITableView!
    var leagueTimeframeSegmentedControl:UISegmentedControl!
    var selectedLeagueIndex: Int!
    let timeframesArray = ["Overall", "Day", "Week", "Month", "Year"]
    var activityIndicatorView: NVActivityIndicatorView!
    var menu: AZDropdownMenu!
    let compliments = [
        "Looks like you’re killing the game. Nice!",
        "Great portfolio growth",
        "Looking good!",
        "Well done",
        "Congrats!",
        "Great investing decisions",
        "Are you a cowboy? Cause you're riding some serious bulls!",
        "Can I ride on your private jet?",
        "Are you actually Warren Buffett behind that username?",
        "Great gains. Can I ask what your invested in?"
    ]
    let insults = [
        "'No Bull' is Ford's Slogan, not a good investing strategy",
        "So, is this your first time investing?",
        "Ouch.",
        "Just landed on Boardwalk huh?",
        "FYI the red is bad",
        "Remember that the goal is to INCREASE your portfolio value",
        "Are you UCLA fan? Cause you seem to like bears",
        "Is red your favorite color?",
        "Want me to manage your portfolio for you?",
        "You should just go to Vegas if you are trying to lose money bud ;)"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        
        self.title = "Leaderboards"
        self.navigationController?.navigationBar.barTintColor = FunduModel.shared.hedgePrimaryColor
        let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(createNewLeague))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.view.backgroundColor = FunduModel.shared.hedgePrimaryColor
        
        let titles = ["Invite to League"]
        menu = AZDropdownMenu(titles: titles)
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: Selector("showDropdown"))
        navigationItem.leftBarButtonItem = menuButton
        menu.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
            self?.inviteToLeagueButtonPressed()
        }
        
        selectedLeagueIndex = 0
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), type: .ballClipRotateMultiple, color: UIColor.white, padding: 100.0)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        createLeagueView()
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        self.leagueTableView.contentInset = adjustForTabbarInsets
        self.leagueTableView.scrollIndicatorInsets = adjustForTabbarInsets
        setConstraints()
        
        showLeague(index: self.selectedLeagueIndex!)
        self.view.bringSubview(toFront: activityIndicatorView)
    }
    
    func viewWillAppear() {
        //        let rightBarButtons = self.navigationItem.rightBarButtonItems
        //
        //        let lastBarButton = rightBarButtons?.last
        //
        //        lastBarButton?.updateBadge(number: 4)
        
        //        let barButton = self.navigationItem.leftBarButtonItem;
        //        barButton.badgeValue = [NSString stringWithFormat:@"%d", [barButton.badgeValue intValue] + 1];
        
    }
    
    @objc func showDropdown() {
        if (self.menu?.isDescendant(of: self.view) == true) {
            self.menu?.hideMenu()
        } else {
            self.menu?.showMenuFromView(self.view)
        }
    }
    
    func showLeague(index: Int) {
        if index < self.SharedFunduModel.userLeagues.count {
            let newLeague = self.SharedFunduModel.userLeagues[index]
            self.selectedLeagueIndex = index
            self.leagueTableView.reloadData()
            let teamID = self.SharedFunduModel.getUserTeamForLeague(leagueID: newLeague.leagueID)
            self.animatedSortTableView(index: leagueTimeframeSegmentedControl.selectedSegmentIndex)
            //            self.setUserPlaceValue(placeValue: self.SharedFunduModel.userLeagues[index].teams.count)
            self.observeNewJoiningLeague(index: index)
        }
    }
    
    func observeNewJoiningLeague(index: Int) {
        let leagueID = self.SharedFunduModel.userLeagues[index].leagueID as! String

        FunduModel.shared.ref.child("leagues").child(leagueID).child("teams").observe(.childAdded, with: { snapshot in
            let teamID = snapshot.key
            let teamName = snapshot.value!
            print(teamID)
            if !self.SharedFunduModel.leaderboardTeams[self.selectedLeagueIndex].contains(where:
                {$0.teamID == teamID}) {
                FunduModel.shared.getLeaderboardTeams {
                    DispatchQueue.main.async {
                        self.leagueTableView.reloadData()
                    }
                }
            }
        })
    }
    
    func createLeagueView() {
        self.view.backgroundColor = SharedFunduModel.funduColor
        self.view.layer.borderColor = UIColor.black.cgColor
        
        leagueMoneyLabel = UILabel(frame: CGRect(x: 0, y: (self.view.bounds.height/18)-10, width: self.view.bounds.width, height: (2*self.view.bounds.height/12)-10))
        leagueMoneyLabel.adjustsFontSizeToFitWidth = true
        leagueMoneyLabel.textAlignment = .center
        leagueMoneyLabel.textColor = SharedFunduModel.hedgeMainTextColor
        leagueMoneyLabel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(leagueMoneyLabel)
        
        leagueTimeframeSegmentedControl = UISegmentedControl(items: self.timeframesArray)
        leagueTimeframeSegmentedControl.frame = CGRect(x: 0, y: 3*self.view.bounds.height/12, width: self.view.bounds.width, height: self.view.bounds.height/12)
        leagueTimeframeSegmentedControl.selectedSegmentIndex = 0
        leagueTimeframeSegmentedControl.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        leagueTimeframeSegmentedControl.tintColor = FunduModel.shared.hedgeHighlightColor
        leagueTimeframeSegmentedControl.layer.cornerRadius = 0.0
        leagueTimeframeSegmentedControl.layer.borderColor = FunduModel.shared.hedgeMinorTextColor.cgColor
        leagueTimeframeSegmentedControl.layer.borderWidth = 1.5
        leagueTimeframeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:FunduModel.shared.hedgeMainTextColor, NSAttributedStringKey.font: UIFont(name: "Georgia", size: 15.0)!], for: .selected)
        leagueTimeframeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:FunduModel.shared.hedgeMainTextColor, NSAttributedStringKey.font: UIFont(name: "Georgia", size: 10.0)!], for: .normal)
        leagueTimeframeSegmentedControl.addTarget(self, action: #selector(self.changeTimeFrame(sender:)), for: .valueChanged)
        leagueTimeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(leagueTimeframeSegmentedControl)
        
        leagueTableView = UITableView(frame: CGRect(x: 0, y: self.view.frame.height/3, width: self.view.bounds.width, height: ((2*self.view.frame.height)/3)-(self.tabBarController!.tabBar.frame.height+10)), style: .plain)
        leagueTableView.dataSource = self
        leagueTableView.delegate = self
        leagueTableView.backgroundColor = self.SharedFunduModel.funduColor
        leagueTableView.layer.borderWidth = 5.0
        leagueTableView.layer.borderColor = self.SharedFunduModel.funduColor.cgColor
        leagueTableView.translatesAutoresizingMaskIntoConstraints = false
        leagueTableView.register(LeaguesTableViewCell.self, forCellReuseIdentifier: "cell")
        leagueTableView.tableFooterView = UIView()
        self.view.addSubview(leagueTableView)
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        leagueTableView.contentInsetAdjustmentBehavior = .automatic
        self.leagueTableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        leagueTableView.clipsToBounds = true
        self.animatedSortTableView(index: 0)
        
        drop = UIDropDown(frame: CGRect(x: 0, y: 0, width: 0.3 * self.view.frame.width, height: 0.05 * self.view.frame.height))
        drop.center = CGPoint(x: self.view.frame.midX, y: 20)
        drop.placeholder = "Select league..."
        drop.textColor = self.SharedFunduModel.hedgeMinorTextColor
        drop.borderColor = self.SharedFunduModel.hedgeMinorTextColor
        drop.translatesAutoresizingMaskIntoConstraints = false
        drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
        drop.hideOptionsWhenSelect = true
        drop.tint = .white
        drop.setActiveIndex(index: 0)
        drop.optionsTextColor = SharedFunduModel.hedgeSecondaryColor
        drop.didSelect { (option, index) in
            self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
            self.selectedLeagueIndex = index
            self.showLeague(index: index)
            print("You just select: \(option) at index: \(index)")
        }
        self.view.addSubview(drop)
        if drop.options.count > 0 {
            drop.selectOption(index: 0)
        }
        self.view.bringSubview(toFront: drop)
        activityIndicatorView.stopAnimating()
    }
    
    func setConstraints() {
        let guide = self.view.safeAreaLayoutGuide
        drop.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.1).isActive = true
        drop.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        drop.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.06).isActive = true
        drop.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.4).isActive = true
        drop.bottomAnchor.constraint(equalTo: self.leagueMoneyLabel.topAnchor).isActive = true

        leagueMoneyLabel.topAnchor.constraint(equalTo: drop.bottomAnchor).isActive = true
        leagueMoneyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        leagueMoneyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        leagueMoneyLabel.bottomAnchor.constraint(equalTo: self.leagueTimeframeSegmentedControl.topAnchor, constant: -6.0).isActive = true

        leagueTimeframeSegmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        leagueTimeframeSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        leagueTimeframeSegmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        leagueTableView.topAnchor.constraint(equalTo: self.leagueTimeframeSegmentedControl.bottomAnchor, constant: 6.0).isActive = true
        leagueTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        leagueTableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        leagueTableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        
    }
    
    func setUserPlaceValue(placeValue: Int) {
        
        let num = NumberFormatter.localizedString(from: NSNumber(value: placeValue), number: NumberFormatter.Style.decimal)
        let lastDigit = String(describing: num.last!)
        print("lastDigit \(lastDigit)")
        var rank = ""
        switch lastDigit {
        case "1" :
            if String(describing: num.suffix(2)) != "11" {
                rank = "st"
            } else {
                 rank = "th"
            }
        case "2" :
            if String(describing: num.suffix(2)) != "12" {
                rank = "nd"
            } else {
                 rank = "th"
            }
        case "3" :
            if String(describing: num.suffix(2)) != "13" {
                rank = "rd"
            } else {
                 rank = "th"
            }
        default :
            rank = "th"
        }
        
        let s = "you are in \(num)\(rank) place" // TODO make leagueBalances endpoint
        
        let myMutableString = NSMutableAttributedString(string: s, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 40.0)!])
        myMutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Georgia", size: 25.0) ?? "", range: NSRange(location:0, length:11))
        myMutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Georgia", size: 25.0) ?? "", range: NSRange(location:myMutableString.length-8, length:8))
        //        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: NSRange(location:0,length:1))
        leagueMoneyLabel.attributedText = myMutableString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex][indexPath.section]
        if team.teamID != FunduModel.shared.myUser.userID {
            writeNewMessage(team: team, selectedIndex: indexPath)
        }
    }
    
    @objc func changeTimeFrame(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            animatedSortTableView(index: 0)
        case 1:
            animatedSortTableView(index: 1)
        case 2:
            animatedSortTableView(index: 2)
        case 3:
            animatedSortTableView(index: 3)
        case 4:
            animatedSortTableView(index: 4)
        default:
            animatedSortTableView(index: 5)
        }
    }
    
    func animatedSortTableView(index: Int) {
        let selectedTimeFrame = timeframesArray[index]
        let sortedTeams = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].sorted(by: {
            switch String(describing: selectedTimeFrame) {
            case "Overall" :
                return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
            case "Day" :
                return ($0 as LeagueTeam).dayChange > ($1 as LeagueTeam).dayChange
            case "Week" :
                return ($0 as LeagueTeam).weekChange > ($1 as LeagueTeam).weekChange
            case "Month" :
                return ($0 as LeagueTeam).monthChange > ($1 as LeagueTeam).monthChange
            case "Year":
                return ($0 as LeagueTeam).yearChange > ($1 as LeagueTeam).yearChange
            default:
                return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
            }
        })
        self.leagueTableView.reloadData()
        for (toIndex, team) in sortedTeams.enumerated() {
            let fromIndex = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].index(where: { $0.teamName == team.teamName }) // TODO should be team ID but not getting sent that by Hunter in get league values call
            if fromIndex != toIndex {
                self.leagueTableView.beginUpdates()
                self.leagueTableView.moveSection(fromIndex!, toSection: toIndex)
                self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].rearrange(from: fromIndex!, to: toIndex)
                self.leagueTableView.endUpdates()
            }
//            if SharedFunduModel.myUser.teamNames.contains(team.teamName) { // highlight if the user is member of that team
//                let userPosition = toIndex
//                setUserPlaceValue(placeValue: userPosition+1)
//            }
            if SharedFunduModel.myUser.userID == team.teamID { // highlight if the user is member of that team
                let userPosition = toIndex
                setUserPlaceValue(placeValue: userPosition+1)
            }

        }
    }
    
    /*****************************************************************************/
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if selectedLeagueIndex < self.SharedFunduModel.leaderboardTeams.count {
            count = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].count
        }
        return count
    }
    /*****************************************************************************/
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    //    {
    //        return 40.0
    //    }
    
    //    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    /*****************************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    /*****************************************************************************/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:LeaguesTableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LeaguesTableViewCell
        if indexPath.section < self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].count {
            let team = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex][indexPath.section]
            cell?.backgroundColor = SharedFunduModel.hedgeSecondaryColor
            
            let sortedTeams = self.SharedFunduModel.leaderboardTeams[selectedLeagueIndex].sorted(by: {
                return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
            })
            
            let overallPosition = sortedTeams.index(where: { $0.teamID == team.teamID })
            let position = String(describing: overallPosition!+1)
            
            let lastDigit = String(describing: position.last!)
            print("lastDigit \(lastDigit)")
            var rank = ""
            switch lastDigit {
            case "1" :
                if String(describing: position.suffix(2)) != "11" {
                    rank = "st"
                } else {
                    rank = "th"
                }
            case "2" :
                if String(describing: position.suffix(2)) != "12" {
                    rank = "nd"
                } else {
                    rank = "th"
                }
            case "3" :
                if String(describing: position.suffix(2)) != "13" {
                    rank = "rd"
                } else {
                    rank = "th"
                }
            default :
                rank = "th"
            }
            let positionString = position.appending(rank)
            let font:UIFont? = UIFont(name: "Helvetica", size:20)
            let fontSuper:UIFont? = UIFont(name: "Helvetica", size:10)
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: positionString, attributes: [.font:font!])
            attString.setAttributes([.font:fontSuper!,.baselineOffset:10], range: NSRange(location:positionString.characters.count-2,length:2))
            cell?.rankingLabel!.attributedText = attString
            
            cell?.titleLabel!.text = team.teamName.capitalized
            cell?.titleLabel!.adjustsFontSizeToFitWidth = true
            
            cell?.titleLabel!.textColor = FunduModel.shared.hedgeMainTextColor
            /* TODO: color text fields based on rank? issue is that animatedSort makes reloading cells hard
             if indexPath.section == 0 { // gold
             cell?.titleLabel!.textColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
             } else if indexPath.section == 1 { // silver
             cell?.titleLabel!.textColor = UIColor(red: 0.8392, green: 0.8392, blue: 0.8392, alpha: 1.0)
             } else if indexPath.section == 2 { // bronze
             cell?.titleLabel!.textColor = UIColor(red: 0.804, green: 0.498, blue: 0.196, alpha: 1.0)
             } */
            let index = self.leagueTimeframeSegmentedControl.selectedSegmentIndex
            let selectedTimeFrame = self.timeframesArray[index]
            // let teamTimeFrames = team[team.keys.first!]! as! NSDictionary
            var value = Float()
            switch String(describing: selectedTimeFrame) {
            case "Overall" :
                value = team.overallChange
            case "Day" :
                value = team.dayChange
            case "Week" :
                value = team.weekChange
            case "Month" :
                value = team.monthChange
            case "Year":
                value = team.yearChange
            default:
                value = team.overallChange
            }
            var percentage = value*100
            if percentage < 0 { // if percentage is negative
                cell?.stockLabel?.textColor = FunduModel.shared.hedgeLossColor
                percentage = fabs(percentage)
                if SharedFunduModel.myUser.teamNames.contains(team.teamName) {// highlight if the user is member of that team
                    cell?.contentView.layer.borderWidth = 2.0
                    cell?.contentView.layer.borderColor = FunduModel.shared.hedgeLossColor.cgColor
                } else {
                    cell?.contentView.layer.borderWidth = 2.0
                    cell?.contentView.layer.borderColor = FunduModel.shared.hedgeSecondaryColor.cgColor
                }
            } else {
                cell?.stockLabel?.textColor = FunduModel.shared.hedgeGainColor
                if SharedFunduModel.myUser.teamNames.contains(team.teamName) {// highlight if the user is member of that team
                    cell?.contentView.layer.borderWidth = 2.0
                    cell?.contentView.layer.borderColor = FunduModel.shared.hedgeGainColor.cgColor
                } else {
                    cell?.contentView.layer.borderWidth = 2.0
                    cell?.contentView.layer.borderColor = FunduModel.shared.hedgeSecondaryColor.cgColor
                }
            }
            cell?.stockLabel?.text = "\(String(format: "%.2f",percentage))%"
            cell?.isUserInteractionEnabled = true
            let backgroundView = UIView()
            backgroundView.backgroundColor = FunduModel.shared.hedgeHighlightColor
            cell?.selectedBackgroundView = backgroundView
            
            return cell!
        }
        return cell!
    }
    
    // TODO (eventually) allow invite to users not in the app, send Dynamic link in google invite
    // right now this function searches teams to check if there is a valid team with this name, and if not found in teams, searches in users for valid user with this name
    @objc func inviteToLeagueButtonPressed() {
        let currentLeague = SharedFunduModel.userLeagues[selectedLeagueIndex]
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        let teamName = alert.addTextField("Team / Member Name: ")
        alert.addButton("Invite", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            //if textfields are both not empty, create new user (in firebase and model) and segway to parties
            if(teamName.text != "") {

                let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/getTeamObjectFromName?teamName=\(teamName.text!)"
                let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

                print("get team url: \(urlString)")
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print(error!)
                    }
                    else if data != nil {
                        let json = JSON(data!)
                        if json["error"].exists() {
                            SCLAlertView().showError("Team / User doesn't exist", subTitle: "Please enter another team / user name", closeButtonTitle: "Cancel")
                        } else {
                            let teamID = json["teamID"].stringValue
                            let teamName = json["teamName"].stringValue
                            let members = json["members"].dictionaryObject
                            let dict = ["teamID": teamID, "teamName": teamName, "members": members] as [String : Any]
                            print(dict)
                            let team = Team(dictionary: dict as NSDictionary)
                            // TODO JORDAN: At this point, send invite to this TEAM, when they accept they are added to team
                            // send to whole team, but only allow Team Manager to initiate join
                            FunduModel.shared.inviteTeamToLeague(invitedTeamID: team.teamID, leagueID: currentLeague.leagueID, leagueName: currentLeague.leagueName)
                        }
                    }
                }
                task.resume()
            }
        }
        alert.showInfo("Invite team to \(currentLeague.leagueName) League", subTitle: "", closeButtonTitle: "Cancel", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    @objc func createNewLeague() {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let leagueName = alert.addTextField("League Name: ")
        
        
        alert.addButton("Join as Existing Team", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            if(leagueName.text != "") {
                self.joinLeagueWithTeam(leagueName: leagueName.text!)
            } else {
                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
            }
        }
//        alert.addButton("Join as New Team", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
//            if(leagueName.text != "") {
//                self.formNewTeamThenJoinLeague(teamName: "", members: [], leagueName: leagueName.text!)
//            } else {
//                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
//            }
//        }
        alert.addButton("Join Solo", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            if(leagueName.text != "") {
                let newLeague = League(name: leagueName.text!)
                newLeague.leagueManagerID = self.SharedFunduModel.myUser.userID
                self.activityIndicatorView.startAnimating()
                self.SharedFunduModel.newLeague(league: newLeague)
                self.SharedFunduModel.addTeamToLeague(newTeamID: self.SharedFunduModel.myUser.userID, newTeamName: self.SharedFunduModel.myUser.username, leagueID: newLeague.leagueID)
                self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
                FunduModel.shared.loadUserLeaguesFromFirebase(completion: {
                    self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
                    FunduModel.shared.getLeaderboardTeams(completion: {
                        self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
                        DispatchQueue.main.async {

                            self.activityIndicatorView.stopAnimating()
                        }
                        return
                    })
                })
            } else {
                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
            }
        }
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        alert.showInfo("Create New League", subTitle: "", closeButtonTitle: "Cancel", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    func joinLeagueWithTeam(leagueName: String) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let teamNameTF = alert.addTextField("Enter team name: ")
        
        alert.addButton("Join as Existing Team", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            let teamName = teamNameTF.text!
            if(teamName != "") {
                let index = FunduModel.shared.myUser.teamNames.index(where: { (tn) -> Bool in
                    tn == teamName
                })
                if index != nil {
                    let teamID = FunduModel.shared.myUser.teamIDs[index!]
                    let newLeague = League(name: leagueName)
                    self.activityIndicatorView.startAnimating()
                    FunduModel.shared.newLeague(league: newLeague)
                    // TODO join league and dismiss
                    
                    FunduModel.shared.addTeamToLeague(newTeamID: teamID, newTeamName: teamName, leagueID: newLeague.leagueID)
                    self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
//                    self.loadLeagueFromFirebase(leagueID: newLeague.leagueID, completion: {
//                        self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
//                    })
                    FunduModel.shared.loadUserLeaguesFromFirebase(completion: {
                        self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
                        FunduModel.shared.getLeaderboardTeams(completion: {
                            self.drop.options = self.SharedFunduModel.userLeagues.map{ $0.leagueName }
                            DispatchQueue.main.async {
                                self.activityIndicatorView.stopAnimating()
                            }
                        })
                    })
                } else {
                    SCLAlertView().showError("You do not belong to a team called \(teamName)", subTitle: "", closeButtonTitle: "Cancel")
                }
            }
        }
        
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        alert.showInfo("Join \(leagueName) league with Team", subTitle: "", closeButtonTitle: "Cancel", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    func formNewTeamThenJoinLeague(teamName: String, members: [String], leagueName: String) {
        
    }
    
    func loadLeagueFromFirebase(leagueID: String, completion:()->(Void)) {
        
    }
    
    @objc func viewLeagueTeamInvestingProfileButtonPressed() {
        
    }
    
    
    @objc func writeNewMessage(team: LeagueTeam, selectedIndex: IndexPath) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            shouldAutoDismiss: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        let messageTV = alert.addTextView()
        // get usernames for message
        //        var usernames: [String] = []
        //        usernames.append(FunduModel.shared.myUser.username)
        //        var usernamesString = "usernames="
        //        var allUsersString = "&" + usernamesString + FunduModel.shared.myUser.username
        //        for user in team.members {
        //            print(user)
        //            let username = user.value
        //            usernames.append(username)
        //            allUsersString.append("&" + usernamesString + username)
        //        }
        //
        //        print(allUsersString)
        alert.addButton("Send Taunt", backgroundColor: SharedFunduModel.hedgeSecondaryColor,textColor: SharedFunduModel.hedgeLossColor) {
            let randomIndex = Int(arc4random_uniform(UInt32(self.insults.count)))
            let message = self.insults[randomIndex]
            messageTV.text = message
        }
        alert.addButton("Send Compliment", backgroundColor: SharedFunduModel.hedgeSecondaryColor, textColor: SharedFunduModel.hedgeGainColor) {
            let randomIndex = Int(arc4random_uniform(UInt32(self.compliments.count)))
            let message = self.compliments[randomIndex]
            messageTV.text = message
        }
        alert.addButton("Send Message", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            //if textfields are both not empty, create new user (in firebase and model) and segway to parties
            if messageTV.text != "" {
                let messageText = messageTV.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                
                let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/sendTaunt?senderID=\(FunduModel.shared.myUser.userID)&senderName=\(FunduModel.shared.myUser.username)&messageText=\(messageText)&teamID=\(team.teamID)"
                let url = URL(string: urlString)
                print("send messages url: \(urlString)")
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        print("done send message")
                        DispatchQueue.main.async {
                            alert.hideView()
                        }
                    }
                }
                task.resume()
            }
        }
        
        alert.addButton("Cancel", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            self.leagueTableView.cellForRow(at: selectedIndex)?.setSelected(false, animated: true)
            alert.hideView()
        }
        
        alert.showInfo("Send Message", subTitle: "to \(team.teamName)", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    @objc func goToMessages() {
        let mVC = InboxTableViewController()
        self.navigationController?.pushViewController(mVC, animated: true)
    }
    
    
    // MODEL DELEGATE METHOD
    func leagueAdded() {
        self.leagueTableView.reloadData()
    }
}
