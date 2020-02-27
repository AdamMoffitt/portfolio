//
//  LeagueCompetitionCollectionViewCell.swift
//  fundü
//
//  Created by Jordan Coppert on 3/8/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LeagueCompetitionCollectionViewCell: UICollectionViewCell {
    var nav:UINavigationController!
    var leagues = [League]()
    var numStocks:Int = 0
    var team:Team!
    var activityIndicatorView:NVActivityIndicatorView!
    
    var teamName:UILabel!
    var score:UILabel!
    var teamMembers:UIButton!
    var messaging:UIButton!
    var teamImage:UIImageView!
    var control:UISegmentedControl!
    var teamTableView:UITableView!
    var index = 0 {
        didSet {
            teamTableView.reloadData()
        }
    }
    
    override func prepareForReuse() {
        teamName?.removeFromSuperview()
        score?.removeFromSuperview()
        teamMembers?.removeFromSuperview()
        messaging?.removeFromSuperview()
        teamImage?.removeFromSuperview()
        control?.removeFromSuperview()
        teamTableView?.removeFromSuperview()
        activityIndicatorView?.removeFromSuperview()
    }
    
    func setupViews(team:Team) {
        self.team = team
        //numStocks = team.userStockPortfolio.count
        leagues = team.participatingLeagues
        createTeamLabel()
        createScoreLabel()
        createTeamMembersButton()
        createTeamImageView()
        createMessagingButton()
        createteamTableView()
        createControl()
        setConstraints()
    }
    
    func createTeamLabel(){
        teamName = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.1, height: contentView.bounds.height * 0.1))
        teamName.alpha = 1
        teamName.text = team.teamName
        teamName.textAlignment = .center
        teamName.textColor = .white
        teamName.font = UIFont(name: "DidactGothic-Regular", size: 18)
        teamName.translatesAutoresizingMaskIntoConstraints = false
        teamName.numberOfLines = 0
        self.contentView.addSubview(teamName)
    }
    
    func createScoreLabel(){
        score = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.05, height: contentView.bounds.height * 0.1))
        score.alpha = 1
        //score.text = "Score: " + String(team.teamScore)
        score.textAlignment = .center
        score.textColor = .white
        score.font = UIFont(name: "DidactGothic-Regular", size: 18)
        score.translatesAutoresizingMaskIntoConstraints = false
        score.numberOfLines = 0
        self.contentView.addSubview(score)
    }
    
    func createTeamMembersButton(){
        teamMembers = UIButton(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height * 0.1))
        let plural = team.members.count > 1 ? " team members" : " team member"
        teamMembers.setTitle(String(team.members.count) + plural, for: .normal)
        teamMembers.titleLabel?.font = UIFont(name: "DidactGothic-Regular", size: 14)
        teamMembers.addTarget(self, action: #selector(showMembers), for: .touchUpInside)
        teamMembers.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(teamMembers)
    }
    
    func createMessagingButton(){
        messaging = UIButton(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.1, height: contentView.bounds.height * 0.1))
        messaging.setImage(UIImage(named:"messages-1"), for: .normal)
        messaging.addTarget(self, action: #selector(showMessages), for: .touchUpInside)
        messaging.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(messaging)
    }
    
    @objc func showMessages(){
        print("chat")
//        let chatVC = FirebaseChatViewController()
//        chatVC.channelRef = FunduModel.shared.ref.child("teams").child(team.teamID)
//        chatVC.senderDisplayName = FunduModel.shared.myUser.username
//        chatVC.title = team.teamName
//        self.nav.pushViewController(chatVC, animated: true)
    }
    
    @objc func showMembers(){
        print("showMembers")
    }
    
    func createTeamImageView(){
        teamImage = UIImageView(image: UIImage(named: "default-team"))
        teamImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.2, height: contentView.bounds.height * 0.2)
        teamImage.contentMode = UIViewContentMode.scaleAspectFit
        teamImage.layer.cornerRadius = 10
        teamImage.clipsToBounds = true
        teamImage.layer.masksToBounds = true
        teamImage.translatesAutoresizingMaskIntoConstraints = false
        teamImage.layer.borderWidth = 1
        teamImage.layer.borderColor = UIColor.white.cgColor
        teamImage.backgroundColor = UIColor.white
        contentView.addSubview(teamImage)
    }
    
    func createteamTableView(){
        teamTableView = UITableView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.5, height: contentView.bounds.height * 0.5))
        teamTableView.layer.cornerRadius = 5
        teamTableView.register(TeamStockTableViewCell.self, forCellReuseIdentifier: "StockCell")
        teamTableView.register(TeamLeagueTableViewCell.self, forCellReuseIdentifier: "LeagueCell")
        teamTableView.rowHeight = UITableViewAutomaticDimension
        teamTableView.estimatedRowHeight = 100
        teamTableView.translatesAutoresizingMaskIntoConstraints = false
        teamTableView.dataSource = self
        teamTableView.delegate = self
        teamTableView.backgroundColor = UIColor.white
        teamTableView.alpha = 1
        self.contentView.addSubview(teamTableView)
    }
    
    func createControl(){
        control = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width * 0.6, height: contentView.bounds.height * 0.1))
        control.insertSegment(withTitle: "Portfolio", at: 0, animated: true)
        //control.insertSegment(withTitle: "Compete", at: 1, animated: true)
        control.selectedSegmentIndex = 0
        control.setEnabled(true, forSegmentAt: 0)
        control.tintColor = .white
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(updateView), for: .valueChanged)
        contentView.addSubview(control)
    }
    
    @objc func updateView() {
        print("update view")
        index = control.selectedSegmentIndex
    }
    
    func setConstraints(){
        let margins = safeAreaLayoutGuide
        
        contentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        teamImage.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 1).isActive = true
        teamImage.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        teamImage.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.2).isActive = true
        teamImage.widthAnchor.constraint(equalToConstant: contentView.bounds.height * 0.2).isActive = true
        
        teamName.topAnchor.constraintEqualToSystemSpacingBelow(teamImage.bottomAnchor, multiplier: 0.2).isActive = true
        teamName.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        teamName.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.05).isActive = true
        teamName.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        
        score.topAnchor.constraintEqualToSystemSpacingBelow(teamName.bottomAnchor, multiplier: 0.06).isActive = true
        score.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        score.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.05).isActive = true
        score.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        
        messaging.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 1).isActive = true
        messaging.trailingAnchor.constraintEqualToSystemSpacingAfter(teamImage.trailingAnchor, multiplier: 14).isActive = true
        messaging.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.05).isActive = true
        messaging.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.1).isActive = true
        
        teamMembers.topAnchor.constraintEqualToSystemSpacingBelow(score.bottomAnchor, multiplier: 0.1).isActive = true
        teamMembers.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        teamMembers.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.05).isActive = true
        teamMembers.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        
        control.topAnchor.constraintEqualToSystemSpacingBelow(teamMembers.bottomAnchor, multiplier: 0.3).isActive = true
        control.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        control.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.07).isActive = true
        control.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.7).isActive = true
        
        teamTableView.topAnchor.constraintEqualToSystemSpacingBelow(control.bottomAnchor, multiplier: 0.6).isActive = true
        teamTableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        teamTableView.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.5).isActive = true
        teamTableView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.95).isActive = true
                
    }
    
    func loadingAnimation() {
        self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width * 0.5, height: self.contentView.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.black, padding: 0)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.contentView.bounds.height * 0.5).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.contentView.bounds.width * 0.5).isActive = true
        self.activityIndicatorView.startAnimating()
    }
}

extension LeagueCompetitionCollectionViewCell : UITableViewDelegate {
    
}

extension LeagueCompetitionCollectionViewCell : UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch index {
        case 0:
            tableView.deselectRow(at: indexPath, animated: true)
            let companyVC = CompanyPageViewController()
            companyVC.nav = nav
            let cell = tableView.cellForRow(at: indexPath) as! TeamStockTableViewCell!
            companyVC.ticker = cell?.textString
            self.loadingAnimation()
            FunduModel.shared.checkOwnership(ticker: (cell?.textString)!, completion: { (userTeams, isOwned) in
                companyVC.owned = isOwned
                companyVC.userTeams = userTeams
                self.activityIndicatorView.stopAnimating()
                self.nav.pushViewController(companyVC, animated: true)
            })
        case 1:
            print("to league page")
        default:
            print("satisfy compiler")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(index == 0) {
            return numStocks
        } else {
            return leagues.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stockCell:TeamStockTableViewCell
        let leagueCell:TeamLeagueTableViewCell
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
            stockCell = cell as! TeamStockTableViewCell
            //Make this dynamic, positive for now
//            stockCell.setupViews(ticker: team.userStockPortfolio[indexPath.row].ticker, quantity: team.userStockPortfolio[indexPath.row].quantity, price: team.userStockPortfolio[indexPath.row].price, change: team.userStockPortfolio[indexPath.row].percentChange)
            return stockCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeagueCell", for: indexPath)
            leagueCell = cell as! TeamLeagueTableViewCell
            leagueCell.setupViews(leagueName: leagues[indexPath.row].leagueName, challenge: "King of the hill - earn the largest percent returns to win", rank: leagues[indexPath.row].teamRank)
            return leagueCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if index == 0 {
            return contentView.bounds.height * 0.1
        } else {
            return contentView.bounds.height * 0.2
        }
    }
}
