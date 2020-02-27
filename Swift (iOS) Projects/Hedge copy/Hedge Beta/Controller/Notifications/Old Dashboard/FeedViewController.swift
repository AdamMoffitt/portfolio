//
//  FeedViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 12/2/17.
//  Copyright © 2017 fundü. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import NVActivityIndicatorView

protocol FeedCollectionViewDelegate {
    func refreshTableView()
}

class FeedViewController: UICollectionViewCell, FeedCollectionViewDelegate {
    
    var username:String!
    var token:String!
    //var delegate: CenterViewControllerDelegate?
    var tableView: UITableView!
    var notifications: [UserNotification]!
    var activityIndicatorView:NVActivityIndicatorView!
    //var feedEvents: [FeedEvent]!
    var articles: [Article] = []
    var nav:UINavigationController!
    let SharedFunduModel = FunduModel.shared
    
    override func prepareForReuse() {
        tableView.removeFromSuperview()
        activityIndicatorView.removeFromSuperview()
    }
    
    func setupViews() {
        //delegate = (self.parent?.parent?.parent as! CenterViewControllerDelegate)
        self.contentView.backgroundColor = UIColor.clear
        notifications = []
        //feedEvents = getSummaryFeedEvents()
        setNavButtons()
        createTableView()
        createSearch()
        setConstraints()
        getNews()
        
        
        let notificationAddedObserver = self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("notifications").observe(.childAdded, with: { (snapshot) in
                print("notification observed")
            let json = JSON(snapshot.value)
            print("notification: \(json)")
            let message = json["message"].stringValue
            let type = json["type"].stringValue
            let imageString = json["imageURL"].stringValue
            let teamName = json["teamName"].stringValue
            let teamID = json["teamID"].stringValue
            let leagueID = json["leagueID"].stringValue
            let leagueName = json["leagueName"].stringValue
            let date = json["date"].stringValue
            let channelID = json["channelID"].stringValue
            let seen = json["seen"].boolValue
            let key = snapshot.key
            let fe = UserNotification(image: imageString, message: message, type: type, teamID: teamID, teamName: teamName, date: date, leagueID: leagueID, leagueName: leagueName, channelID: channelID, seen: seen )
            self.notifications.insert(fe, at: 0)
            self.tableView.reloadData() // TODO just reload cell 0
        })
    }
    
    //Load before dash
    func getNews(){
        loadingAnimation()
        let apiRequest = "https://api.iextrading.com/1.0/stock/market/news/last/10"
        Alamofire.request(apiRequest).validate().responseJSON { response in
            let json = JSON(response.value as Any)
            for index in 0...9 {
                guard let headline = json[index]["headline"].string, let author = json[index]["source"].string,let url = json[index]["url"].string else {
                    continue
                }
                self.articles.append(Article(headline: headline, author: author, url: url))
            }
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }}
    
    func loadingAnimation() {
        self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width * 0.5, height: self.contentView.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.contentView.bounds.height * 0.5).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.contentView.bounds.width * 0.5).isActive = true
        self.activityIndicatorView.startAnimating()
    }
    
    func createSearch() {
        
    }
    
    func getSummaryFeedEvents() -> [FeedEvent]{
        //Stubbing this for sake of the demo
        var events = [FeedEvent]()
        events = [FeedEvent(image: "user1", message: "Jordan Coppert just passed you on the leaderboards! Complete more challenges to catch back up.", time: "now", type: .other),
                  FeedEvent(image: "company1", message: "GOOGL announces acquisition of large augmented reality firm.", time: "3 hrs", type: .company("GOOGL")),
                  FeedEvent(image: "user2", message: "Myrl Marmarelis just joined your group RainMakers, send a message to welcome them!", time: "1 hr", type: .other),
                  FeedEvent(image: "user3", message: "Nick Kaimakis just purchased AAPL at $27.59 a share.", time: "Yesterday", type: .company("AAPL")),
                  FeedEvent(image: "company2", message: "TSLA stock up 7% after semi announcement, buy now!", time: "6 hrs", type: .company("TSLA"))]
        return events
    }
    
    func setNavButtons(){
        //let leftBarButton = UIBarButtonItem(image: UIImage(named: "menu") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(showMenu))
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "messages") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(showMessages))
        
        //self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        //self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        
    }
    
    func createTableView(){
        let barHeight = UIApplication.shared.statusBarFrame.size.height
        let displayWidth = self.contentView.frame.width
        let displayHeight = self.contentView.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(FeedCollectionTableViewCell.self, forCellReuseIdentifier: "FeedCollectionTableViewCell")
        tableView.register(NewsArticleCell.self, forCellReuseIdentifier: "NewsArticleCell")
        tableView.register(HedgeLogoTableViewCell.self, forCellReuseIdentifier: "HedgeLogoTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        self.contentView.addSubview(tableView)
    }
    
    func setConstraints(){
        tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    //    @objc func showMenu(){
    //        delegate?.toggleLeftPanel?()
    //    }
    
    @objc func showMessages(){
        //        let chatViewController = ChatViewController()
        //        chatViewController.username = (self.parent!.parent as! DashboardViewController).username
        //        let controller = UINavigationController(rootViewController: chatViewController)
        //        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        //        self.parent!.parent!.present(controller, animated: true, completion: nil) // todo make nicer
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
}

extension FeedViewController: UITableViewDelegate {
    //Prevent highlight of cell after tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.row > 0 {
            let articleVC = ArticleViewController()
            articleVC.url = articles[indexPath.row - 1].url
            nav.pushViewController(articleVC, animated: true)
        }
//        if let eventCell = cell as? FeedTableViewCell {
//            let event = eventCell.event!
//            switch event.type {
//            case .company(let ticker):
//                let companyView = CompanyViewController()
//                companyView.ticker = ticker
//                companyView.username = self.username
//                let controller = UINavigationController(rootViewController: companyView)
//            //self.present(controller, animated: true)
//            case .other:
//                break
//            }
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            if !notifications.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCollectionTableViewCell") as! FeedCollectionTableViewCell
                cell.delegate = self as! FeedCollectionViewDelegate
                cell.setupViews(stats:notifications)
                cell.backgroundColor = FunduModel.shared.hedgePrimaryColor
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HedgeLogoTableViewCell") as! HedgeLogoTableViewCell
                cell.setupViews()
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsArticleCell") as! NewsArticleCell
            cell.setupViews(article: articles[indexPath.row - 1], textColor: .white, backgroundColor: FunduModel.shared.hedgePrimaryColor)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            //make these percentages
            return 200
        }
        else {
            return 100
        }
    }
}

