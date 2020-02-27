//
//  UserLeaguesViewController
//  fundü
//
//  Created by Adam Moffitt on 3/4/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import SwiftyJSON
import NVActivityIndicatorView

class UserLeaguesViewController: UIViewController //, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    
//    var leaderboards = [UITableView]()
//    var timeframeSegmentedControls = [UISegmentedControl]()
//    let SharedFunduModel = FunduModel.shared
//    let timeframesArray = ["Overall", "Day", "Week", "Month", "Year"]
//    var leagues : [League] = []
//    var leagueViews : [String:UIView] = [:]
//    var teams = [[LeagueTeam]()]
//    let views : [UIView] = []
//    var numberOfLeagues = 0
//    var activityIndicatorView : NVActivityIndicatorView!
//    var colors = ["red", "green", "blue", "purple", "brown", "cyan", "magenta", "orange", "yellow"]
//    var firebaseTeamHandles = [DatabaseHandle]()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.darkGray
//        self.edgesForExtendedLayout = []
//
//
//        let btnAddLeagues = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(createNewLeague))
//        self.navigationItem.rightBarButtonItem = btnAddLeagues
//        // let refreshButton =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: "actionRefresh:")
//        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), type: .ballClipRotateMultiple, color: UIColor.black, padding: 100.0)
//        self.view.addSubview(activityIndicatorView)
//        activityIndicatorView.startAnimating()
//        getUserLeagues()
//
////        carousel = iCarousel(frame: CGRect(x:0,y:0, width: self.view.frame.width, height: self.view.frame.height))
////        carousel.stopAtItemBoundary = true
////        carousel.scrollToItemBoundary = true
////        carousel.clipsToBounds = true
////        carousel.dataSource = self
////        carousel.type = .rotary
////        self.view.addSubview(carousel)
//    }
//
////    func numberOfItems(in carousel: iCarousel) -> Int {
////        return leagues.count
////    }
////
////    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
////        if index < leagues.count {
////            if let lView = leagueViews[self.leagues[index].leagueName] {
////                return lView
////            }
////        } else {
////            print("poop \(index)")
////            var v = UIView(frame: CGRect(x:10, y:100, width: self.view.frame.width-200, height: self.view.frame.height-200))
////            return v
////        }
////        return UIView()
////    }
//
////    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
////        if (option == .spacing) {
////            return value * 1.1
////        }
////        return value
////    }
//
//    func createLeagueViews(completion: @escaping ()->()) {
//        if !leagues.isEmpty {
//            DispatchQueue.main.async {
//                for league in self.leagues {
//                    self.leagueViews[league.leagueName] = self.createNewLeagueView(newLeague: league)
//                }
//                completion()
//            }
//        }
//    }
//
//
//    func getUserLeagues() {
//        print("get user leagues")
//
//        leagues = self.SharedFunduModel.userLeagues
//        var counter = 0
//        for (index, league) in leagues.enumerated() {
//            self.teams.append([LeagueTeam]())
//            self.getTeams(leagueNumber: index, completionHandler: {
//                counter = counter + 1
//                print(counter)
//                if counter >= self.leagues.count {
//                    self.createLeagueViews(completion: {
//                        print("completion get user leagues")
////                        self.carousel.reloadData()
//                        self.animatedSortAllTableviews()
//                        self.activityIndicatorView.stopAnimating()
//                    })
//                }
//            })
//        }
//    }
//
//    func createNewLeagueView(newLeague: League) -> UIView {
//        let leagueView = UIView(frame: CGRect(x: 10, y: 10, width: self.carousel.frame.width-20, height: self.view.frame.height-60))
//        leagueView.backgroundColor = newLeague.getColor()
//        leagueView.layer.borderColor = UIColor.black.cgColor
//        leagueView.layer.borderWidth = 2.0
//        leagueView.clipsToBounds = true
//
//        let leagueNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: leagueView.bounds.width, height: leagueView.bounds.height/12))
//        print("create vew \(newLeague.leagueName)")
//        leagueNameLabel.text = newLeague.leagueName
//        leagueNameLabel.numberOfLines = 0
//        leagueNameLabel.adjustsFontSizeToFitWidth = true
//        leagueNameLabel.textAlignment = .center
//        leagueView.addSubview(leagueNameLabel)
//
//        let leagueMoneyLabel = UILabel(frame: CGRect(x: 0, y: (leagueView.bounds.height/18)-10, width: leagueView.bounds.width, height: (2*leagueView.bounds.height/12)-10))
//        var s = "$----------"
//        let teamID = self.SharedFunduModel.getUserTeamForLeague(leagueID: newLeague.leagueID)
//            let moneyValue = self.SharedFunduModel.getUserTeamPortfolioValue(teamID: teamID)
//            s = "$\(NumberFormatter.localizedString(from: NSNumber(value: moneyValue.rounded(toPlaces: 2)), number: NumberFormatter.Style.decimal))" // TODO make leagueBalances endpoint
//
//        let myMutableString = NSMutableAttributedString(string: s, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 40.0)!])
//        myMutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Georgia", size: 25.0) ?? "", range: NSRange(location:0, length:1))
//        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: NSRange(location:0,length:1))
//        leagueMoneyLabel.attributedText = myMutableString
//        leagueMoneyLabel.adjustsFontSizeToFitWidth = true
//        leagueMoneyLabel.textAlignment = .center
//        leagueView.addSubview(leagueMoneyLabel)
//
//        let yPosition = 3*leagueView.bounds.height/12 - 35
//        let inviteToLeagueButton = UIButton(frame: CGRect(x: 10, y: yPosition, width: 30, height: 30))
//        inviteToLeagueButton.setBackgroundImage(UIImage(named: "invite"), for: .normal)
//        inviteToLeagueButton.addTarget(self, action: #selector(inviteToLeagueButtonPressed), for: .touchUpInside)
//        leagueView.addSubview(inviteToLeagueButton)
//
//        let viewLeagueTeamInvestingProfileButton = UIButton(frame: CGRect(x: (leagueView.bounds.width/2)-15, y: yPosition, width: 30, height: 30))
//        viewLeagueTeamInvestingProfileButton.setBackgroundImage(UIImage(named: "portfolio"), for: .normal)
//        viewLeagueTeamInvestingProfileButton.addTarget(self, action: #selector(viewLeagueTeamInvestingProfileButtonPressed), for: .touchUpInside)
//        leagueView.addSubview(viewLeagueTeamInvestingProfileButton)
//
//        let leagueChatButton = MIBadgeButton(frame: CGRect(x: leagueView.bounds.width-50, y: yPosition, width: 30, height: 30))
//        leagueChatButton.setBackgroundImage(UIImage(named: "messages"), for: .normal)
//        //leagueChatButton.badgeString = "5"
//        leagueChatButton.addTarget(self, action: #selector(leagueChatButtonPressed), for: .touchUpInside)
//        leagueView.addSubview(leagueChatButton)
//
//        let timeframeSegmentedControl = UISegmentedControl(items: self.timeframesArray)
//        timeframeSegmentedControl.frame = CGRect(x: 0, y: 3*leagueView.bounds.height/12, width: leagueView.bounds.width, height: leagueView.bounds.height/12)
//        timeframeSegmentedControl.selectedSegmentIndex = 0
//        timeframeSegmentedControl.backgroundColor = UIColor.lightGray
//        timeframeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.black], for: .selected)
//        timeframeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.black], for: .normal)
//
//        timeframeSegmentedControl.addTarget(self, action: #selector(self.changeTimeFrame(sender:)), for: .valueChanged)
//        self.timeframeSegmentedControls.append(timeframeSegmentedControl)
//        leagueView.addSubview(timeframeSegmentedControl)
//        self.sortTableViews(index: 0)
//        let tableView = UITableView(frame: CGRect(x: 0, y: leagueView.frame.height/3, width: leagueView.bounds.width, height: ((2*leagueView.frame.height)/3)), style: .plain)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.backgroundColor = self.SharedFunduModel.funduColor
//        tableView.layer.borderWidth = 5.0
//        tableView.layer.borderColor = self.SharedFunduModel.funduColor.cgColor
//        tableView.clipsToBounds = true
//        tableView.tableFooterView = UIView()
//        tableView.register(LeaguesTableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.alpha = 1
//        self.leaderboards.append(tableView)
//        leagueView.addSubview(tableView)
//        return leagueView
//    }
//
//    @objc func changeTimeFrame(sender: UISegmentedControl) {
//        let page = self.carousel.currentItemIndex
//        switch sender.selectedSegmentIndex {
//        case 0:
//            animatedSortTableView(index: 0, page: page)
//        //sortTableViews(index: 0)
//        case 1:
//            animatedSortTableView(index: 1, page: page)
//        //sortTableViews(index: 1)
//        case 2:
//            animatedSortTableView(index: 2, page: page)
//        //sortTableViews(index: 2)
//        case 3:
//            animatedSortTableView(index: 3, page: page)
//        //sortTableViews(index: 3)
//        case 4:
//            animatedSortTableView(index: 4, page: page)
//        //sortTableViews(index: 4)
//        default:
//            animatedSortTableView(index: 5, page: page)
//            //sortTableViews(index: 0)
//        }
//        //refreshTableViews()
//    }
//
//    // JUST FOR TESTING
//    func getRandomColor() -> UIColor{
//        //Generate between 0 to 1
//        let red:CGFloat = CGFloat(drand48())
//        let green:CGFloat = CGFloat(drand48())
//        let blue:CGFloat = CGFloat(drand48())
//
//        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
//    }
//
//    func loadLeagueFromFirebase(leagueID: String, completion: @escaping ()->()) {
//        print("load leagues from firebase \(leagueID)")
//        SharedFunduModel.ref.child("leagues").child(leagueID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//            if !snapshot.exists() {
//                return
//            }
//            if let childLeagueSnapshot = snapshot as? DataSnapshot {
//                let league = League(snapshot: childLeagueSnapshot )
//                if !self.leagues.contains(where: {
//                    $0.leagueID == league.leagueID
//                }) {
//                    print("load league: \(league.leagueName)")
//                    self.leagues.append(league)
//                    self.SharedFunduModel.userLeagues.append(league)
//                    let index = self.leagues.count
//                    self.teams.append([LeagueTeam]())
//                    self.getTeams(leagueNumber: index-1, completionHandler: {
//                        completion()
//                    })
//                } else {
//                    print("league already in view")}
//            }
//        })
//    }
//
//    deinit {
//        for element in firebaseTeamHandles {
//            SharedFunduModel.ref.child("leagues").removeObserver(withHandle: element)
//        }
//    }
//
//    func getTeams(leagueNumber: Int, completionHandler: @escaping ()->Void) {
//        if leagueNumber < self.SharedFunduModel.userLeagues.count {
//        let leagueID = self.SharedFunduModel.userLeagues[leagueNumber].leagueID
//        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/leagueValues?leagueID=\(leagueID)"
//        let url = URL(string: (urlString))
//        print("get teams url: \(urlString)")
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            if error != nil {
//                print(error!)
//            }
//            else {
//                if let urlContent = data {
//                    print(urlContent)
//                    let json = JSON(urlContent)
//
//                    for (index,subJson):(String, JSON) in json {
//                        for (key,subJson1):(String, JSON) in subJson {
//                            let leagueTeam = LeagueTeam(dictionary: subJson1.dictionaryObject! as NSDictionary)
//                            print("League team: \(leagueTeam.teamName)")
//                            self.teams[leagueNumber].append(leagueTeam)
//                        }
//                    }
//                    completionHandler()
//                }
//            }
//        }
//        task.resume()
//        }
//    }
//
//    /*****************************************************************************/
//    func numberOfSections(in tableView: UITableView) -> Int {
//        var count = 0
//
//        for i in 0..<self.leaderboards.count {
//            if tableView == self.leaderboards[i] {
//                if (i < self.teams.count) { // got index out of range, unsure why leaderboards and leagues length isnt the same
//                    count = self.teams[i].count
//                    return count
//                }
//            }
//        }
//        return count
//    }
//    /*****************************************************************************/
//    // Set the spacing between sections
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
//
//    // Make the background color show through
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
//    /*****************************************************************************/
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    /*****************************************************************************/
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var cell:LeaguesTableViewCell?
//
//        for i in 0..<self.leaderboards.count {
//            if tableView == self.leaderboards[i] {
//                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LeaguesTableViewCell
//                if indexPath.section < teams[i].count {
//                    let team = teams[i][indexPath.section]
//                    if SharedFunduModel.myUser.teamNames.contains(team.teamName) {// highlight if the user is member of that team
//                        cell?.setHighlighted(true, animated: false) // TODO WHY DOESNT THIS WORK?
//                        cell?.backgroundColor = UIColor.lightGray
//                    } else {
//                        cell?.backgroundColor = UIColor.white
//                    }
//                    //let position = String(describing: indexPath.section+1)
//                    let sortedTeams = self.teams[i].sorted(by: {
//                        return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
//                    })
//
//                    let overallPosition = sortedTeams.index(where: { $0.teamID == team.teamID })
//                    let position = String(describing: overallPosition!+1)
//
//                    let lastDigit = String(describing: position.last!)
//                    print("lastDigit \(lastDigit)")
//                    var rank = ""
//                    switch lastDigit {
//                    case "1" :
//                        rank = "st"
//                    case "2" :
//                        rank = "nd"
//                    case "3" :
//                        rank = "rd"
//                    default :
//                        rank = "th"
//                    }
//                    let positionString = position.appending(rank)
//                    let font:UIFont? = UIFont(name: "Helvetica", size:20)
//                    let fontSuper:UIFont? = UIFont(name: "Helvetica", size:10)
//                    let attString:NSMutableAttributedString = NSMutableAttributedString(string: positionString, attributes: [.font:font!])
//                    attString.setAttributes([.font:fontSuper!,.baselineOffset:10], range: NSRange(location:positionString.characters.count-2,length:2))
//                    cell?.rankingLabel!.attributedText = attString
//
//
//                    cell?.titleLabel!.text = team.teamName.capitalizeFirst()
//                    cell?.titleLabel!.adjustsFontSizeToFitWidth = true
//
//                    cell?.titleLabel!.textColor = team.color
//                    /* TODO: color text fields based on rank? issue is that animatedSort makes reloading cells hard
//                     if indexPath.section == 0 { // gold
//                     cell?.titleLabel!.textColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
//                     } else if indexPath.section == 1 { // silver
//                     cell?.titleLabel!.textColor = UIColor(red: 0.8392, green: 0.8392, blue: 0.8392, alpha: 1.0)
//                     } else if indexPath.section == 2 { // bronze
//                     cell?.titleLabel!.textColor = UIColor(red: 0.804, green: 0.498, blue: 0.196, alpha: 1.0)
//                     } */
//                    let index = self.timeframeSegmentedControls[i].selectedSegmentIndex
//                    let selectedTimeFrame = self.timeframesArray[index]
//                    // let teamTimeFrames = team[team.keys.first!]! as! NSDictionary
//                    var value = Float()
//                    switch String(describing: selectedTimeFrame) {
//                    case "Overall" :
//                        value = team.overallChange
//                    case "Day" :
//                        value = team.dayChange
//                    case "Week" :
//                        value = team.weekChange
//                    case "Month" :
//                        value = team.monthChange
//                    case "Year":
//                        value = team.yearChange
//                    default:
//                        value = team.overallChange
//                    }
//                    var percentage = value*100
//                    if percentage < 0 { // if percentage is negative
//                        cell?.stockLabel?.textColor = UIColor.red
//                        percentage = fabs(percentage)
//                    } else {
//                        cell?.stockLabel?.textColor = UIColor.green
//                    }
//                    cell?.stockLabel?.text = "\(String(format: "%.2f",percentage))%"
//                    if SharedFunduModel.myUser.teamIDs.contains(team.teamID) {
//                        cell?.isSelected = true
//                    }
//                    cell?.isUserInteractionEnabled = false
//                    return cell!
//                }
//            }
//        }
//        return cell!
//    }
//
//
//    func sortAllLeagues() {
//        for i in 0..<SharedFunduModel.userLeagues.count {
//            for j in 0..<self.timeframesArray.count {
//                let selectedTimeFrame = timeframesArray[j]
//                //                self.SharedFunduModel.leagues[i].teams.sort(by: {
//                //                    let teamTimeFrames1 = $0[$0.keys.first!]! as! NSDictionary
//                //                    let value1 = ((teamTimeFrames1.value(forKey: String(describing: selectedTimeFrame)) as! NSNumber).floatValue)
//                //                    let teamTimeFrames2 = $1[$1.keys.first!]! as! NSDictionary
//                //                    let value2 = ((teamTimeFrames2.value(forKey: String(describing: selectedTimeFrame)) as! NSNumber).floatValue)
//                //                    return value1 > value2
//                //                }) TODO
//            }
//        }
//        refreshTableViews()
//    }
//
//    func sortTableViews(index: Int) {
//        print("sort table views")
//        let selectedTimeFrame = timeframesArray[index]
//        let page = self.carousel.currentItemIndex
//        if page < self.teams.count {
//            self.teams[page].sort(by: {
//                switch String(describing: selectedTimeFrame) {
//                case "Overall" :
//                    return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
//                case "Day" :
//                    return ($0 as LeagueTeam).dayChange > ($1 as LeagueTeam).dayChange
//                case "Week" :
//                    return ($0 as LeagueTeam).weekChange > ($1 as LeagueTeam).weekChange
//                case "Month" :
//                    return ($0 as LeagueTeam).monthChange > ($1 as LeagueTeam).monthChange
//                case "Year":
//                    return ($0 as LeagueTeam).yearChange > ($1 as LeagueTeam).yearChange
//                default:
//                    return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
//                }
//            })
//        }
//    }
//
//    func animatedSortTableView(index: Int, page: Int) {
//        let selectedTimeFrame = timeframesArray[index]
//        if page >= 0 && page < self.leaderboards.count {
//            print("page: \(page), selectedTimeFrame: \(selectedTimeFrame)")
//            let sortedTeams = self.teams[page].sorted(by: {
//                switch String(describing: selectedTimeFrame) {
//                case "Overall" :
//                    return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
//                case "Day" :
//                    return ($0 as LeagueTeam).dayChange > ($1 as LeagueTeam).dayChange
//                case "Week" :
//                    return ($0 as LeagueTeam).weekChange > ($1 as LeagueTeam).weekChange
//                case "Month" :
//                    return ($0 as LeagueTeam).monthChange > ($1 as LeagueTeam).monthChange
//                case "Year":
//                    return ($0 as LeagueTeam).yearChange > ($1 as LeagueTeam).yearChange
//                default:
//                    return ($0 as LeagueTeam).overallChange > ($1 as LeagueTeam).overallChange
//                }
//            })
//            self.leaderboards[page].reloadData()
//            for (toIndex, team) in sortedTeams.enumerated() {
//                let fromIndex = self.teams[page].index(where: { $0.teamName == team.teamName }) // TODO should be team ID but not getting sent that by Hunter in get league values call
//                if fromIndex != toIndex {
//                    self.leaderboards[page].beginUpdates()
//                    self.leaderboards[page].moveSection(fromIndex!, toSection: toIndex)
//                    self.teams[page].rearrange(from: fromIndex!, to: toIndex)
//                    self.leaderboards[page].endUpdates()
//                }
//            }
//        }
//    }
//
//    func animatedSortAllTableviews() {
//        for page in 0..<self.carousel.numberOfItems {
//            self.animatedSortTableView(index: 0, page: page)
//        }
//    }
//
//    func refreshTableViews() {
//        for i in 0..<self.leaderboards.count {
//            self.leaderboards[i].reloadData()
//        }
//    }
//
//    @objc func createNewLeague() {
//
//        let pickerFrame: CGRect = CGRect(x:0, y:0, width: 200, height: 100); // CGRectMake(left), top, width, height) - left and top are like margins
//        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
//        //set the pickers datasource and delegate
//        picker.delegate = self
//        picker.dataSource = self
//        picker.selectRow(0, inComponent: 0, animated: true)
//        picker.layer.borderColor = SharedFunduModel.funduColor.cgColor
//        picker.layer.borderWidth = 1         //Add the picker to the alert controller
//
//        let labelWidth = picker.frame.width
//        let label: UILabel = UILabel.init(frame: CGRect(x:0,y: 0, width: labelWidth, height: 20))
//        label.text = "Choose League Color"
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//        picker.addSubview(label)
//
//        let appearance = SCLAlertView.SCLAppearance(
//            kWindowWidth: picker.frame.size.width + 28.0,
//            showCloseButton: true
//        )
//        let alert = SCLAlertView(appearance: appearance)
//        let leagueName = alert.addTextField("League Name: ")
//
//        alert.customSubview = picker
//
//        alert.addButton("Join as Existing Team") {
//            if(leagueName.text != "") {
//                self.joinLeagueWithTeam(leagueName: leagueName.text!, leagueColor: self.colors[picker.selectedRow(inComponent: 0)])
//            } else {
//                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
//            }
//        }
//        alert.addButton("Join as New Team") {
//            if(leagueName.text != "") {
//                self.formNewTeamThenJoinLeague(teamName: "", members: [], leagueName: leagueName.text!, leagueColor: self.colors[picker.selectedRow(inComponent: 0)])
//            } else {
//                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
//            }
//        }
//        alert.addButton("Join Solo") {
//            if(leagueName.text != "") {
//                let newLeague = League(name: leagueName.text!)
//                newLeague.leagueManagerID = self.SharedFunduModel.myUser.userID
//                newLeague.color = self.colors[picker.selectedRow(inComponent: 0)]
//                self.SharedFunduModel.newLeague(league: newLeague)
//                self.SharedFunduModel.addTeamToLeague(newTeamID: self.SharedFunduModel.myUser.userID, newTeamName: self.SharedFunduModel.myUser.username, leagueID: newLeague.leagueID)
//                self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
//                self.loadLeagueFromFirebase(leagueID: newLeague.leagueID, completion: {})
//            } else {
//                SCLAlertView().showError("Make sure to specify a League name", subTitle: "", closeButtonTitle: "Cancel")
//            }
//        }
//        alert.showInfo("Create New League", subTitle: "", closeButtonTitle: "Cancel")
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return colors.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return colors[row]
//    }
//
//    func joinLeagueWithTeam(leagueName: String, leagueColor: String) {
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: true
//        )
//        let alert = SCLAlertView(appearance: appearance)
//        let name = alert.addTextField("Enter Team name: ")
//        alert.addButton("Join League \(leagueName)") {
//            if name.text != "" {
//                if let index = self.SharedFunduModel.myUser.teamNames.index(where: {
//                    $0 == name.text!
//                }) {
//                    let newLeague = League(name: leagueName)
//                    newLeague.leagueManagerID = self.SharedFunduModel.myUser.userID
//                    newLeague.color = leagueColor
//                    self.SharedFunduModel.newLeague(league: newLeague)
//                    self.SharedFunduModel.addTeamToLeague(newTeamID: self.SharedFunduModel.myUser.teamIDs[index], newTeamName: self.SharedFunduModel.myUser.teamNames[index], leagueID: newLeague.leagueID)
//                    self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
//                    //TODO: for each user in team, add leagueIDs to themselves and add leagueID to team database
//                } else {
//                    alert.showError("You do not belong to a team with that name", subTitle: "Make sure you belong to the team and the team already has been formed", closeButtonTitle: "Okay")
//                }
//            }
//        }
//        alert.showInfo("Join League", subTitle: "", closeButtonTitle: "Cancel")
//    }
//
//    func formNewTeamThenJoinLeague(teamName: String, members: [String], leagueName: String, leagueColor: String) {
//        var s = InviteFriendsViewController()
//        s.modalPresentationStyle = .overCurrentContext
//        var data = [String]()
//        let boundsW = self.view.bounds.width * 0.95
//        let boundsH = self.view.bounds.height * 0.4
//        s.boundsW = boundsW
//        s.boundsH = boundsH
//        var results = [String:String]()
//        self.SharedFunduModel.ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
//            let json = JSON(snapshot.value)
//            for (key, subJson) in json {
//                let name = subJson["username"].stringValue
//                let id = subJson["userID"].stringValue
//                results.updateValue(id, forKey: name)
//                data.append(name)
//            }
//            let sortedData = data.sorted(by: <)
//            s.lookup = results
//            s.data = sortedData
//            s.parentVC = self
//            s.mode = "League"
//            s.leagueColor = leagueColor
//            s.leagueName = leagueName
//            s.startUp()
//            self.present(s, animated: true, completion: nil)
//        })
//
////        let appearance = SCLAlertView.SCLAppearance(
////            showCloseButton: true
////        )
////        let alert = SCLAlertView(appearance: appearance)
////
////        let view = UIView(frame : CGRect(x: 0, y: 0, width: 100, height: 20*members.count))
////
////        let teamNameTF = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
////        teamNameTF.text = teamName
////        teamNameTF.placeholder = "Enter Team Name"
////        view.addSubview(teamNameTF)
////
////        var counter = 1
////        for name in members {
////            let tf = UILabel(frame: CGRect(x: 0, y: 20*counter, width: 100, height: 20))
////            tf.text = members[counter]
////            //newMembers.append(tf)
////            view.addSubview(tf)
////            counter = counter+1
////        }
////
////        let newMemberTF = UITextField(frame: CGRect(x: 0, y: 20*counter, width: 100, height: 20))
////        newMemberTF.text = teamName
////        newMemberTF.placeholder = "Enter new member username"
////        view.addSubview(newMemberTF)
////
////        alert.customSubview = view
////
////        var newMemberArray = members
////        alert.addButton("Add Member") {
////            if newMemberTF.text != "" {
////                // TODO!!!!!!!!!!!!!!!! check if username exists (need hunter api call to verify username exists)
////                if true {
////                    newMemberArray.append(newMemberTF.text!)
////                    self.formNewTeamThenJoinLeague(teamName: teamNameTF.text!, members: newMemberArray, leagueName: leagueName, leagueColor: leagueColor)
////                } else {
////                    alert.showError("User does not exist", subTitle: "Make sure you entered the correct user name, or invite them to join ", closeButtonTitle: "Okay")
////                }
////            }
////        }
////
////        alert.addButton("Form Team") {
//////            /* TODO CREATE LEAGUE FUNCTIONALITY BY JORDAN
//////             self.SharedFunduModel.createTeam() */
//////
//        ////            let newLeague = League(name: leagueName)
//        ////            newLeague.leagueManagerID = self.SharedFunduModel.myUser.userID
//        ////            newLeague.color = leagueColor
//        ////            self.SharedFunduModel.newLeague(league: newLeague)
//
//
//////            // TODO ADD NEW MEMBERS TO PENDING INVITATION WHEN JORDAN PUSHES
//////            let newTeam = Team(newTeamName: teamNameTF.text!, members: [self.SharedFunduModel.myUser.userID:self.SharedFunduModel.myUser.username], teamManager: self.SharedFunduModel.myUser.username, pending: [])
//////            self.SharedFunduModel.addTeamToLeague(newTeamID: newTeam.teamID, newTeamName: newTeam.teamName, leagueID: newLeague.leagueID)
//////            self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
//////            self.SharedFunduModel.addteamIDToUser(userID: self.SharedFunduModel.myUser.userID, teamID: newTeam.teamID, teamName: newTeam.teamName)
//////            for user in newMemberArray {
////////                let userID = self.SharedFunduModel.getUserIDFromName(username: user.username)
//////    //          self.SharedFunduModel.inviteUserToTeam(invitedID: userID, teamID: newTeam.teamID)
//////
//////                self.SharedFunduModel.ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
//////                    let json = JSON(snapshot.value)
//////                    for (key, subJson) in json {
//////                        let name = subJson["username"].stringValue
//////                        if name == user {
//////                            let id = subJson["userID"].stringValue
//////                            self.SharedFunduModel.inviteUserToTeam(invitedID: id, teamID: newTeam.teamID)
//////                        }
//////                    }
//////                })
//////            }
//////
//////            // TODO: as members accept invites, put them into team
//////            // TODO JORDAN
//////            self.loadLeagueFromFirebase(leagueID: newLeague.leagueID, completion:{})
////        }
////
////        alert.showInfo("Join League", subTitle: "", closeButtonTitle: "Cancel")
//    }
//
//    func createLeague(teamID: String, teamName: String, leagueName: String, leagueColor: String) {
//        let newLeague = League(name: leagueName)
//        newLeague.leagueManagerID = self.SharedFunduModel.myUser.userID
//        newLeague.color = leagueColor
//        self.SharedFunduModel.newLeague(league: newLeague)
//        self.SharedFunduModel.addTeamToLeague(newTeamID: teamID, newTeamName: teamName, leagueID: newLeague.leagueID)
//        self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: newLeague.leagueID, leagueName: newLeague.leagueName)
//        self.SharedFunduModel.addteamIDToUser(userID: self.SharedFunduModel.myUser.userID, teamID: teamID, teamName: teamName)
//        self.loadLeagueFromFirebase(leagueID: newLeague.leagueID, completion:{})
//    }
//
//    @objc func backAction(_ sender: UIButton) {
//        print("backaction")
//        self.openMenu()
//    }
//
//    func openMenu() {
//        let appDel = UIApplication.shared.delegate as! AppDelegate
//        appDel.drawerController.setDrawerState(.opened, animated: true)
//    }
//
//    // TODO (eventually) allow invite to users not in the app, send Dynamic link in google invite
//    // right now this function searches teams to check if there is a valid team with this name, and if not found in teams, searches in users for valid user with this name
//    @objc func inviteToLeagueButtonPressed() {
//        let page = self.carousel.currentItemIndex
//        let currentLeague = SharedFunduModel.userLeagues[page]
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: true
//        )
//        let alert = SCLAlertView(appearance: appearance)
//        let teamName = alert.addTextField("Team / Member Name: ")
//        alert.addButton("Invite") {
//            //if textfields are both not empty, create new user (in firebase and model) and segway to parties
//            if(teamName.text != "") {
//                // SEARCH TEAMS ON FIREBASE TO CHECK IF EXISTS
//                self.SharedFunduModel.ref.child("teams").observeSingleEvent(of: .value, with: { (snapshot) in
//                    let teamNameEntered = teamName.text!
//                    if snapshot.hasChild(teamNameEntered){
//                        let snapshotValue = snapshot.value as! [String: AnyObject]
//                        let team = Team(dictionary: snapshotValue["\(teamNameEntered)"] as! NSDictionary)
//                        // TODO JORDAN: At this point, send invite to this TEAM, when they accept they are added to team
//                        // send to whole team, but only allow Team Manager to initiate join
//                    } else{
//                        // TODO handle team doesn't exist, check individual members
//                        self.SharedFunduModel.ref.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
//                            if snapshot.hasChild(teamNameEntered) { // Found member with this team name, send invite
//                                let snapshotValue = snapshot.value as! [String: AnyObject]
//                                print("snapshot: \(snapshotValue)")
//                                let member = User(dictionary: snapshotValue["\(teamNameEntered)"] as! NSDictionary )
//                                let t = Team(member: member)
//                                // TODO JORDAN: At this point, send invite to this USER, when they accept they are added to team
//                            } else {
//                                // TODO neither team or member exists, invalid entry. Handle
//                                SCLAlertView().showError("Team / User doesn't exist", subTitle: "Please enter another team / user name", closeButtonTitle: "Cancel")
//                            }
//                        })
//                    }
//                })
//            }
//        }
//        alert.showInfo("Invite team to \(currentLeague.leagueName)", subTitle: "", closeButtonTitle: "Cancel")
//    }
//
//    @objc func leagueChatButtonPressed() {
//        print("chat")
//        let chatVC = FirebaseChatViewController()
//        let page = self.carousel.currentItemIndex
//        let currentLeague = SharedFunduModel.userLeagues[page]
//        chatVC.channelRef = SharedFunduModel.ref.child("leagues").child(currentLeague.leagueID)
//        chatVC.senderDisplayName = SharedFunduModel.myUser.username
//        chatVC.title = "\(currentLeague.leagueName) chat"
//        self.navigationController?.pushViewController(chatVC, animated: true)
//    }
//
//    @objc func handleSwipeLeftOpenMenu(gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == UISwipeGestureRecognizerDirection.left {
//            let page = self.carousel.currentItemIndex
//            if page == 0 {
//                self.openMenu()
//            }
//        }
//    }
//
//    @objc func viewLeagueTeamInvestingProfileButtonPressed() {
//        print("view league team investing profile")
////        let profileVC = NewProfileViewController()
////        self.navigationController?.pushViewController(profileVC, animated: true)
//
//        let portfolioVC = PortfolioTableViewController()
//        for team in teams[self.carousel.currentItemIndex] {
//            if let index = SharedFunduModel.myUser.teamNames.index(where: {
//                $0 == team.teamName
//            }) {
//                portfolioVC.teamID = SharedFunduModel.myUser.teamIDs[index]
//                portfolioVC.teamsPortfolios = [:]
//                self.navigationController?.pushViewController(portfolioVC, animated: true)
//                break
//            }
//        }
//    }
//
//    func scrollToLeague(leagueID: String) {
//        var page = self.carousel.currentItemIndex
//        while self.SharedFunduModel.userLeagues[page].leagueID != leagueID && page < self.leaderboards.count {
//            page = page + 1
//            self.carousel.scrollToItem(at: page, animated: true)
//        }
//    }
    
}



