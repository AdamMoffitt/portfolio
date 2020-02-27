//
//  FirstViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit
import UIDropDown
import Firebase
import SwiftyJSON
import SCLAlertView
import NVActivityIndicatorView
import Crashlytics
import InstantSearch
import AZDropdownMenu

class TeamsViewController: UIViewController, newLeagueDelegate, newTeamDelegate {
    var username: String!
    var drop: UIDropDown!
    let SharedFunduModel = FunduModel.shared
    var tableView: UITableView!
    var teamLabel: UILabel!
    var activeIndex: Int = 0
    var activityIndicatorView: NVActivityIndicatorView!
    var valueToDropConstraint: NSLayoutConstraint!
    var team:Team!
    var menu:AZDropdownMenu!
    var notLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teams"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backgroundColor = SharedFunduModel.hedgePrimaryColor
        self.navigationController?.navigationBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        self.edgesForExtendedLayout = []

        let titles = ["Logout"]
        menu = AZDropdownMenu(titles: titles)
//        let menuButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(TeamsViewController.openMenu))
        navigationItem.leftBarButtonItem = menuButton
        menu.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
            self?.logout()
        }

        self.view.backgroundColor = SharedFunduModel.hedgePrimaryColor
        let btnCreateTeam = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(createNewTeam))
        self.navigationItem.rightBarButtonItem = btnCreateTeam
        self.navigationItem.rightBarButtonItem?.tintColor = .white

        loadingAnimation()

    SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("team_balances").observeSingleEvent(of: .value, with: {
            (snapshot) in
            print("child added: \(String(describing: snapshot.value!))")
            let json = JSON(snapshot.value!)
            for(key, subJson):(String, JSON) in json{
                let value = subJson.doubleValue
                self.SharedFunduModel.myUser.teamBalances[key] = (value).rounded(toPlaces: 2)
            }
        })
        

        let notificationAddedObserver = self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("teamIDs").observe(.childAdded, with: { (snapshot) in
//            self.loadTeam()
        })
        self.loadTeam()
    }


    func createTableView(){
        let barHeight = UIApplication.shared.statusBarFrame.size.height
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height

        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(PortfolioTableViewCell.self, forCellReuseIdentifier: "PortfolioTableViewCell")
        tableView.register(LeagueTableViewCell.self, forCellReuseIdentifier: "LeagueCell")
        tableView.register(TeammateStockTableViewCell.self, forCellReuseIdentifier: "TeammateCell")
        tableView.backgroundColor = SharedFunduModel.hedgePrimaryColor
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = FunduModel.shared.funduColor
        tableView.separatorStyle = .none

        //Account for tab
        if self.tabBarController!.tabBar != nil {
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
            //Where tableview is the IBOutlet for your storyboard tableview.
            self.tableView.contentInset = adjustForTabbarInsets
            self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        }
        self.view.addSubview(tableView)
    }

    func createDropdown(){
        drop = UIDropDown(frame: CGRect(x: 0, y: 0, width: 0.3 * self.view.frame.width, height: 0.05 * self.view.frame.height))
        drop.placeholder = "Select team..."
        drop.tint = .white
        drop.options = self.SharedFunduModel.myUser.teamNames
        drop.textColor = self.SharedFunduModel.hedgeMinorTextColor
        drop.textAlignment = .left
        drop.borderColor = self.SharedFunduModel.hedgeSecondaryColor
        drop.translatesAutoresizingMaskIntoConstraints = false
        drop.optionsTextColor = SharedFunduModel.hedgeSecondaryColor
        drop.hideOptionsWhenSelect = true

        //Populate Drop options
        var results = [String]()
        for teamName in SharedFunduModel.myUser.teamNames {
            results.append(teamName)
        }
        self.drop.options = results;
        self.drop.setActiveIndex(index: 0)


        drop.didSelect { (option, index) in
            if(self.notLoading){
            self.activityIndicatorView.startAnimating()
            self.view.bringSubview(toFront: self.activityIndicatorView)
            self.activeIndex = index
            self.loadTeam()
            }
        }
        self.view.addSubview(drop)
        self.view.bringSubview(toFront: drop)
    }

    func createTeamLabel() {
        teamLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/10))
        teamLabel.adjustsFontSizeToFitWidth = true
        teamLabel.textAlignment = .center
        teamLabel.textColor = SharedFunduModel.hedgeMainTextColor
        if self.SharedFunduModel.myUser.teamIDs.count != 0 {
        let teamCash = 500.27

//            let teamCash = self.SharedFunduModel.myUser.teamBalances[self.SharedFunduModel.myUser.teamIDs[activeIndex]]!
            let userPortfolio = team.myUserStockPortfolio
            var shareValue = 0.0
            for stock in userPortfolio {
                shareValue = Double(Float(shareValue) + (Float(stock.price) * Float(stock.quantity)))
            }
            teamLabel.text = "$" + String(teamCash + shareValue)
        } else {
            teamLabel.text = ""
        }
        teamLabel.font = UIFont(name: "DamascusBold", size: 48)
        teamLabel.translatesAutoresizingMaskIntoConstraints = false
        teamLabel.layer.zPosition = -1
        self.view.addSubview(teamLabel)
    }

    func loadTeam(){
        notLoading = false
        FunduModel.shared.loadTeam(teamID: SharedFunduModel.myUser.teamIDs[activeIndex], completion: { (userTeam) in
            self.team = userTeam
            UIView.animate(withDuration: 1, animations: { () in
                self.setConstraints()
                if(self.drop == nil){
                    self.createDropdown()
                }
                if(self.teamLabel == nil){
                    self.createTeamLabel()
                }
                //Label stuff, needs to happen on return because it uses the teamsArray
                var teamCash = 0.0
                if(self.activeIndex < self.SharedFunduModel.myUser.teamIDs.count) {
                    if self.SharedFunduModel.myUser.teamBalances[self.team.teamID] != nil {
                        teamCash = self.SharedFunduModel.myUser.teamBalances[self.team.teamID]!
                    }
                }
                let userPortfolio = self.team.myUserStockPortfolio
                var shareValue = 0.0
                for stock in userPortfolio {
                    shareValue = Double(Float(shareValue) + (Float(stock.price) * Float(stock.quantity)))
                }
                var currencyFormatter = NumberFormatter()
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                formatter.groupingSeparator = "."
                formatter.generatesDecimalNumbers = true
                formatter.locale = .current
                if(self.tableView == nil){
                    self.createTableView()
                } else {
                    self.tableView.reloadData()
                }
                self.setConstraints()
                self.view.bringSubview(toFront: self.drop)

                self.teamLabel.text = "Total value: " + formatter.string(from: NSNumber(value: teamCash + shareValue))!
                self.activityIndicatorView.stopAnimating()
                var options = self.SharedFunduModel.myUser.teamIDs
                self.notLoading = true
                print("hi")
            })
        })
    }
    @objc func logout() {
        try! Auth.auth().signOut()
        
        //create new instance of view controller
        let loginViewController = AuthViewController()
        
       let appdel = UIApplication.shared.delegate as! AppDelegate
        appdel.window?.rootViewController = loginViewController
        appdel.window?.makeKeyAndVisible()

    }

    override func viewWillAppear(_ animated: Bool) {
//        loadTeam()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if(self.drop != nil){
            self.drop.options = self.SharedFunduModel.myUser.teamNames
        }
    }

    @objc func openMenu(){
        if (self.menu?.isDescendant(of: self.view) == true) {
            self.menu?.hideMenu()
        } else {
            self.menu?.showMenuFromView(self.view)
        }
    }

    @objc func goToMessages() {
        let mVC = InboxTableViewController()
        self.navigationController?.pushViewController(mVC, animated: true)
    }
    
    func contactPermissionHandler(result:Bool){
        var s = InviteFriendsViewController()
        s.modalPresentationStyle = .overCurrentContext
        var data = [String]()
        let boundsW = self.view.bounds.width * 0.95
        let boundsH = self.view.bounds.height * 0.4
        s.boundsW = boundsW
        s.boundsH = boundsH
        var results = [String:String]()
        self.SharedFunduModel.ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            let json = JSON(snapshot.value)
            for (key, subJson) in json {
                let name = subJson["username"].stringValue
                let id = subJson["userID"].stringValue
                results.updateValue(id, forKey: name)
                data.append(name)
        }
        let sortedData = data.sorted(by: <)
        s.lookup = results
        s.data = sortedData
        s.parentVC = self
        s.startUp()
        self.present(s, animated: true, completion: nil)
        })
    }

    @objc func createNewTeam(){
        contactPermissionHandler(result: true)
    }

    func setConstraints(){
        let guide = self.view.safeAreaLayoutGuide
        drop?.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.1).isActive = true
        drop?.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        drop?.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.05).isActive = true
        drop?.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.3).isActive = true

        valueToDropConstraint = teamLabel?.topAnchor.constraintEqualToSystemSpacingBelow(drop.bottomAnchor, multiplier: 2)
        valueToDropConstraint?.isActive = true
        valueToDropConstraint?.priority = UILayoutPriority(1000)

        teamLabel?.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier:0.8).isActive = true
        teamLabel?.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.1).isActive = true
        teamLabel?.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true

        tableView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView?.topAnchor.constraintEqualToSystemSpacingBelow(teamLabel.bottomAnchor, multiplier: 0.3).isActive = true
        tableView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

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
        self.view.bringSubview(toFront: self.activityIndicatorView)
    }
    
    // MODEL DELEGATE METHODs
    func leagueAdded() {
        self.tableView.reloadData()
    }
    
    func teamAdded() {
        self.tableView.reloadData()
    }
}

extension TeamsViewController: UITableViewDelegate {
    //Prevent highlight of cell after tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(notLoading){
        if(indexPath.section == 0){
            self.tabBarController?.selectedIndex = 4
        } else if indexPath.section == 1{
            loadingAnimation()
            let userPortfolio = team.myUserStockPortfolio
            let companyVC = CompanyPageViewController()
            companyVC.nav = self.navigationController
            companyVC.ticker = userPortfolio[indexPath.row].ticker
            FunduModel.shared.checkOwnership(ticker: userPortfolio[indexPath.row].ticker, completion: { (userTeams, isOwned) in
                companyVC.owned = isOwned
                companyVC.userTeams = userTeams
                var numShares = 0
                if isOwned {
                    var numShares = 0
                    for team in userTeams {
                        numShares = numShares + team.stockQuantity
                    }
                    companyVC.sharesOwned = numShares
                }
                self.activityIndicatorView.stopAnimating()
                self.navigationController?.pushViewController(companyVC, animated: true)
                self.dismiss(animated: true, completion: nil)
            })
            }}
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
}

extension TeamsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if(activeIndex == nil){
                return 0
            }
            return team.participatingLeagues.count
        } else if section == 1 {
            if(activeIndex == nil){
                return 0
            }
            return team.myUserStockPortfolio.count
        } else {
            var count = 0
            for teamMember in team.teamUsers {
                if(teamMember.userID != SharedFunduModel.myUser.userID){
                    count = teamMember.userStockPortfolio.count + count
                }
            }
          return count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.03))
        if SharedFunduModel.myUser.teamIDs.count == 0{
            let view = UIView()
            view.backgroundColor = SharedFunduModel.funduColor
            return view
        }

        label.textColor = UIColor.white
        switch section {
        case 0 :
            label.text = "Leagues"
        case 1 :
            label.text = "My Portfolio"
        case 2 :
            label.text = "Team Portfolio"
        default :
            label.text = ""
        }

        let view = UIView()
        view.addSubview(label)
        label.leadingAnchor.constraintEqualToSystemSpacingAfter(view.leadingAnchor, multiplier: 1.1).isActive = true
        label.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.03).isActive = true
        label.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        view.backgroundColor = SharedFunduModel.funduColor
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        var headerHeight: CGFloat = 20.0
        if(activeIndex != nil && activeIndex < SharedFunduModel.myUser.teamIDs.count){
            switch section {
            case 0:
                if(team.participatingLeagues.count == 0){
                    headerHeight = CGFloat.leastNonzeroMagnitude
                }
            case 1:
                if(team.myUserStockPortfolio.count == 0){
                    headerHeight = CGFloat.leastNonzeroMagnitude
                }
            case 2:
                if(team.overallStocks.count == 0){
                    headerHeight = CGFloat.leastNonzeroMagnitude
                }
            default:
                headerHeight = 12
            }
        }

        return headerHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "LeagueCell", for: indexPath) as! LeagueTableViewCell
            defaultCell.setupViews(leagueName: team.participatingLeagues[indexPath.row].leagueName, challenge: "Most overall gains wins!", rank: team.participatingLeagues[indexPath.row].teamRank, amount: 177.65, change: team.participatingLeagues[indexPath.row].teamPercentChange)

            defaultCell.selectionStyle = .none
            return defaultCell
        } else if (indexPath.section == 1){
            let userPortfolio = team.myUserStockPortfolio
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "PortfolioTableViewCell", for: indexPath) as! PortfolioTableViewCell

            //Fix company name and ticker
            let name = userPortfolio[indexPath.row].companyName
            let value = userPortfolio[indexPath.row].price * Float(userPortfolio[indexPath.row].quantity)

            defaultCell.setupViews(ticker: userPortfolio[indexPath.row].ticker, change: userPortfolio[indexPath.row].percentChange, companyName: name, value: value, sharesOwned: userPortfolio[indexPath.row].quantity)

            defaultCell.selectionStyle = .none
            return defaultCell
        } else {
            let userPortfolio = team.overallStocks
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "TeammateCell", for: indexPath) as! TeammateStockTableViewCell
            let name = userPortfolio[indexPath.row].companyName
            defaultCell.setupViews(ticker: userPortfolio[indexPath.row].ticker, change: userPortfolio[indexPath.row].percentChange, companyName: name, username: userPortfolio[indexPath.row].username)

            defaultCell.selectionStyle = .none
            return defaultCell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return self.view.frame.width * 0.28
    }
}
