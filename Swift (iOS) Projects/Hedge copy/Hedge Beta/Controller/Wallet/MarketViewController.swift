//
//  MarketViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 4/9/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit

//
//  LeaguesViewController.swift
//  fundü
//
//  Created by Adam Moffitt on 2/1/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SCLAlertView
import NVActivityIndicatorView
import Crashlytics
import InstantSearch
import UIDropDown
import Alamofire

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StockBoughtDelegate {
    
    var stocks: [Stock] = []
    var stocksData: [Stock?]? //This needs to be optional for the tableview expandable cell implementation where some cells can be nil
    var tableView = UITableView()
    var chosenStockSymbol = "MSFT"
    var chosenStock = Stock()
    var buyTeam = ""
    var sellTeam = ""
    var stockNameLabel: UILabel!
    let SharedFunduModel = FunduModel.shared
    var activityIndicatorView : NVActivityIndicatorView!
    var walletActivityIndicatorView : NVActivityIndicatorView!
    var teamBalance: Double!
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    var marketWatchAddedHandle : DatabaseHandle?
    var marketWatchRemovedHandle : DatabaseHandle?
    var searchController: UISearchController!
    var searchResults: SearchResultsViewController!
    var walletLabel: UILabel!
    var availableLabel: UILabel!
    var drop: UIDropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        let btnAddToMarketWatch = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(addStockToMarketWatch))
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.rightBarButtonItem = btnAddToMarketWatch
        self.navigationController?.navigationBar.barTintColor = FunduModel.shared.hedgePrimaryColor
        self.edgesForExtendedLayout = []
        view.backgroundColor = FunduModel.shared.funduColor
        
        teamBalance = 0
        buyTeam = SharedFunduModel.myUser.teamIDs[0]
        createWalletValueLabel()
        getUserWatchList()
        
        self.SharedFunduModel.getUserTeamPortfolios()
        
        tableView = UITableView(frame: CGRect(x: 0, y: (view.frame.height/4), width: view.frame.width, height: (2*view.bounds.height/3)), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(PortfolioTableViewCell.self, forCellReuseIdentifier: "PortfolioTableViewCell")
        tableView.backgroundColor = SharedFunduModel.funduColor
        view.addSubview(tableView)
        loadingAnimation()
        createSearch()
        
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        self.tableView.contentInset = adjustForTabbarInsets
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        
        for name in UIFont.familyNames {
            print(name)
            if let nameString = name as? String
            {
                print(UIFont.fontNames(forFamilyName: nameString))
            }
        }
        
        drop = UIDropDown(frame: CGRect(x: 0, y: 0, width: 0.3 * self.view.frame.width, height: 0.05 * self.view.frame.height))
        drop.center = CGPoint(x: self.view.frame.midX, y: 20)
        drop.placeholder = "Select team..."
        drop.tint = .white
        drop.textColor = self.SharedFunduModel.hedgeMinorTextColor
        drop.options = self.SharedFunduModel.myUser.teamNames
        drop.borderColor = self.SharedFunduModel.hedgeSecondaryColor
        drop.optionsTextColor = SharedFunduModel.hedgeSecondaryColor
        drop.hideOptionsWhenSelect = true
        drop.setActiveIndex(index: 0)
        drop.tint = .white
        drop.didSelect { (option, index) in
            self.showTeamBalance(index: index)
            self.tableView.reloadData()
            print("You just select: \(option) at index: \(index)")
        }
        self.view.addSubview(drop)
        self.view.bringSubview(toFront: drop)
        if drop.options.count > 0 {
            drop.selectOption(index: 0)
        }
        
        createConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewWillAppear")
        refreshWalletBalance()
    }
    
    func refreshWalletBalance() {
        if drop != nil {
            if drop.selectedIndex == nil {
                self.showTeamBalance(index: 0)
            } else {
                self.showTeamBalance(index: drop.selectedIndex!)
            }
            self.tableView.reloadData()
        }
    }
    
    func showTeamBalance(index: Int) {
        if index < self.SharedFunduModel.myUser.teamIDs.count {
            let teamID = self.SharedFunduModel.myUser.teamIDs[index]
            if self.SharedFunduModel.myUser.teamBalances[teamID] != nil {
                self.walletLabel.text = "$" + String(self.SharedFunduModel.myUser.teamBalances[teamID]!)
            }
            //            SharedFunduModel.getUserTeamBalance(teamID: teamID) { (balance) in
            //                DispatchQueue.main.async {
            //                    self.walletLabel.text = "$" + String(balance)
            //                }
            //            }
        }
    }
    
    func createSearch(){
        searchResults = SearchResultsViewController()
        searchResults.nav = self.navigationController
        searchController = UISearchController(searchResultsController: searchResults)
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search companies..."
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.backgroundColor = FunduModel.shared.hedgePrimaryColor
        searchController.searchBar.barTintColor = FunduModel.shared.hedgeSecondaryColor
        searchController.searchBar.keyboardAppearance = .dark
        searchController.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        InstantSearch.shared.register(searchController: searchController)
    }
    
    func createWalletValueLabel() {
        walletLabel = UILabel(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height/7))
        walletLabel.adjustsFontSizeToFitWidth = true
        walletLabel.textAlignment = .center
        walletLabel.textColor = SharedFunduModel.hedgeMainTextColor
        walletLabel.text = "$0.00"
        walletLabel.font = UIFont(name: "DamascusBold", size: 56)
        //        walletLabel.text = SharedFunduModel.myUser.availableBalance
        self.view.addSubview(walletLabel)
        walletLabel.baselineAdjustment = .alignCenters
        
        availableLabel = UILabel(frame: CGRect(x: 0, y: walletLabel.frame.height-20, width: self.view.bounds.width, height: 20))
        availableLabel.adjustsFontSizeToFitWidth = true
        availableLabel.textColor = SharedFunduModel.hedgeMinorTextColor
        availableLabel.textAlignment = .center
        availableLabel.text = "Cash Available"
        walletLabel.addSubview(availableLabel)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //TODO AS USER SCROLLS UP FADE CELLS OUT
        //        let view = cell.contentView
        //        view.layer.opacity = 0.1
    }
    
    
    func getUserWatchList() {
        self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value as Any)
            print("market watch: \(json)")
            for (key,_):(String, JSON) in json {
                if !self.SharedFunduModel.watchedStocks.contains(key.uppercased()) {
                    self.SharedFunduModel.watchedStocks.append(key.uppercased())
                }
            }
            self.fetchWatchlist()
        })
    }
    
    deinit {
        if let marketWatchAddedRef = marketWatchAddedHandle {
            self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").removeObserver(withHandle: marketWatchAddedRef)
        }
        if let marketWatchRemovedRef = marketWatchRemovedHandle {
            self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").removeObserver(withHandle: marketWatchRemovedRef)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let data = stocksData {
                return data.count
            }
        } else if section == 1 {
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "PortfolioTableViewCell", for: indexPath) as! PortfolioTableViewCell
        let stock = stocksData?[indexPath.row]
        var ownership = 0
        if(stock?.isOwned != nil){
            if((stock?.isOwned)!){
                ownership = (stock?.numShares)!
            } else {
                ownership = -1
            }
        }
        defaultCell.setupViews(ticker: (stock?.symbol)!, change: (stock?.change)!, companyName: (stock?.name)!, value: (stock?.price as! NSString).floatValue , sharesOwned: ownership)
        defaultCell.selectionStyle = .none
        return defaultCell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Watchlist"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerHeight: CGFloat
        
        headerHeight = 30
        
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.activityIndicatorView.startAnimating()

        if stocksData != nil && stocksData![indexPath.row] != nil {
            self.chosenStock = stocksData![indexPath.row]!
            let companyVC = CompanyPageViewController()
            companyVC.nav = self.navigationController
            if chosenStock.symbol != nil {
                self.chosenStockSymbol = chosenStock.symbol!
                companyVC.ticker = chosenStock.symbol!
            }
            if chosenStock.numShares !=  nil {
                companyVC.sharesOwned = chosenStock.numShares!
            }

            FunduModel.shared.checkOwnership(ticker: chosenStock.symbol!, completion: { (userTeams, isOwned) in
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
                self.tableView.deselectRow(at: indexPath, animated: false)
                self.navigationController?.pushViewController(companyVC, animated: true)
                self.dismiss(animated: true, completion: nil)
            })
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
        
        self.walletActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width * 0.5, height: self.tableView.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
        self.walletActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(walletActivityIndicatorView)
        self.walletActivityIndicatorView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        self.walletActivityIndicatorView.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor).isActive = true
        self.walletActivityIndicatorView.heightAnchor.constraint(equalToConstant: self.tableView.bounds.height * 0.5).isActive = true
        self.walletActivityIndicatorView.widthAnchor.constraint(equalToConstant: self.tableView.bounds.width * 0.5).isActive = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    
    func checkOwnership(){
        if stocksData!.count == 0 {
            return
        }
        for index in 0...stocksData!.count - 1 {
            let stock = stocksData![index]!
            FunduModel.shared.checkOwnership(ticker: (stock.symbol!)) { (teams, owned) in
                stock.isOwned = owned
                var numShares = 0
                for team in teams {
                    numShares = numShares + team.stockQuantity
                }
                stock.numShares = numShares
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchWatchlist() {
        self.activityIndicatorView.startAnimating()
        let favorites = self.SharedFunduModel.watchedStocks
        if favorites.isEmpty {
            for stockTicker in self.SharedFunduModel.popularStocks {
                self.SharedFunduModel.addWatchStockToUser(stockTicker: stockTicker)
            }
        }
        let formattedArray = (favorites.map{String($0)}).joined(separator: ",%20")
        let urlString = ("https://api.iextrading.com/1.0/stock/market/batch?symbols=\(formattedArray)&types=quote")
        let url = URL(string: (urlString))
        Alamofire.request(url!).validate().responseJSON { (response) in
            let json = JSON(response.value as Any)
            
            //Parse watchlist
            let list = json.dictionaryValue
            print(json.dictionaryValue)
            for (key,subJson):(String, JSON) in list {
                //Parse stock data
                let subJson2 = subJson["quote"].dictionaryValue
                let stock:Stock! = Stock(name: (subJson2["companyName"]?.stringValue)!, action: "sell", price: (subJson2["latestPrice"]?.floatValue)!, symbol: (subJson2["symbol"]?.stringValue)!, change:(subJson2["change"]?.floatValue)!)
                self.stocks.append(stock)
            }
            //Sort and reload UI
            self.stocksData = self.stocks
            self.stocksData?.sort(by: { (stock1, stock2) -> Bool in
                stock1!.name! < stock2!.name!
            })
            self.activityIndicatorView.stopAnimating()
            self.checkOwnership()
        }
    }
    
    @objc func addStockToMarketWatch() {
        // TODO do we want to add search bar to market watch page
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let tickerName = alert.addTextField("Stock Ticker")
        
        alert.addButton("Watch Stock", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            // TODO CHECK IF STOCK TICKER IS REAL
            let stockTicker = tickerName.text!
            self.SharedFunduModel.addWatchStockToUser(stockTicker: stockTicker.uppercased())
            self.fetchWatchlist()
        }
        
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        alert.showEdit("Add Stock to Market Watch", subTitle: "Enter Stock Ticker", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    func createConstraints() {
        drop.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        drop.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        walletLabel.topAnchor.constraint(equalTo: drop.bottomAnchor).isActive = true
        walletLabel.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        walletLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        walletLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let goNext = segue.destination as! CompanyPageViewController
        goNext.delegate = self
    }
    
    // Define Delegate Method
    func StockBought()
    {
        refreshWalletBalance()
    }
}

extension MarketViewController : UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        DispatchQueue.main.async {
            searchController.searchResultsController!.view.isHidden = false
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        searchController.searchResultsController?.view.isHidden = false;
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = ""
    }
}
