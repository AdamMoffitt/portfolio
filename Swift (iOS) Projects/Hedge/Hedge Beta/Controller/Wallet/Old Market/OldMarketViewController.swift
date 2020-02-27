//
//  LeaguesViewController.swift
//  fundü
//
//  Created by Adam Moffitt on 2/1/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import Firebase
import Charts
import SwiftyJSON
import SCLAlertView
import NVActivityIndicatorView
import Crashlytics
import InstantSearch

protocol ExpandableTableViewCellDelegate {
    func buyButtonPressed(stockSymbol: String)
    func sellButtonPressed(stockSymbol: String)
}

class OldMarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,  ExpandableTableViewCellDelegate {

    var stocks: [Stock] = []
    var stocksData: [Stock?]? //This needs to be optional for the tableview expandable cell implementation where some cells can be nil
    var tableView = UITableView()
    var dataArray = [[String: Any]]()
    var chosenStockSymbol = "MSFT"
    var chosenStock = Stock()
    var buyTeam = ""
    var sellTeam = ""
    var lineChartView: LineChartView!
    var stockNameLabel: UILabel!
    let SharedFunduModel = FunduModel.shared
    var activityIndicatorView : NVActivityIndicatorView!
    var teamBalance: Double!
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    var marketWatchAddedHandle : DatabaseHandle?
    var marketWatchRemovedHandle : DatabaseHandle?
    var searchController: UISearchController!
    var searchResults: SearchResultsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnAddToMarketWatch = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(addStockToMarketWatch))
        self.navigationItem.rightBarButtonItem = btnAddToMarketWatch
        self.edgesForExtendedLayout = []
        view.backgroundColor = FunduModel.shared.funduColor

        teamBalance = 0
        buyTeam = SharedFunduModel.myUser.teamIDs[0]

        getUserWatchList()

        self.SharedFunduModel.getUserTeamPortfolios()

        setChartView()
        view.addSubview(lineChartView)
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: lineChartView.frame.width, height: lineChartView.frame.height), type: .ballClipRotateMultiple, color: UIColor.black, padding: 30.0)
        lineChartView.addSubview(activityIndicatorView)

        dataArray = seedDataArray()

        tableView = UITableView(frame: CGRect(x: 0, y: (view.frame.height/3)+50, width: view.frame.width, height: (2*view.bounds.height/3)-50), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ExpandedCellTableViewCell.self, forCellReuseIdentifier: "ExpandedCell")
        tableView.register(StockCell.self, forCellReuseIdentifier: "StockCell")
        tableView.backgroundColor = SharedFunduModel.funduColor
        view.addSubview(tableView)

    }

    func createSearch(){
        searchResults = SearchResultsViewController()
        searchResults.nav = self.navigationController
        searchController = UISearchController(searchResultsController: searchResults)
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search companies, teams etc"
        searchController.searchBar.showsCancelButton = false
        searchController.delegate = self as! UISearchControllerDelegate
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        InstantSearch.shared.register(searchController: searchController)
    }
    
    func setChartView() {
        stockNameLabel = UILabel(frame: CGRect(x:0,y:0, width: view.frame.width, height: 32))
        stockNameLabel.textAlignment = .center
        stockNameLabel.font = UIFont(name: "Georgia", size: 30)
        stockNameLabel.backgroundColor = FunduModel.shared.funduColor
        view.addSubview(stockNameLabel)

        lineChartView = LineChartView(frame: CGRect(x: 2, y: 32, width: view.frame.width-1, height: (view.frame.height/3)+18))
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.leftAxis.drawZeroLineEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        let formatter = NumberFormatter()
        formatter.negativeSuffix = "$"
        formatter.positiveSuffix = "$"
        lineChartView.rightAxis.valueFormatter = MoneyChartFormatter()
        lineChartView.gridBackgroundColor = UIColor.clear
        lineChartView.legend.enabled = false
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.extraBottomOffset = 10.0
        lineChartView.chartDescription?.enabled = false
        lineChartView.autoScaleMinMaxEnabled = true
    }

    func setChart(dataPoints: [[Date : Double]]) {
        lineChartView.setLineChartData(dataPoints: dataPoints, label: chosenStockSymbol)
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0, easingOption: .linear)
    }

    func getUserWatchList() {
        self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value as Any)
            print("market watch: \(json)")
            for (key,_):(String, JSON) in json {
                self.SharedFunduModel.watchedStocks.append(key.uppercased())
            }
            self.setMarketWatchObservers() // after reading in all data, then add observer to listen for additional added events
        })
    }

    func setMarketWatchObservers() {
        marketWatchAddedHandle = self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").observe(.childAdded, with: { (snapshot) in
            if !self.SharedFunduModel.watchedStocks.contains(snapshot.key.uppercased()) {
//                    self.tableView.beginUpdates()
                print("stock added to watchlist: \(snapshot.key.uppercased())")
                    self.SharedFunduModel.watchedStocks.append(snapshot.key.uppercased())
//                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//                    self.tableView.endUpdates()
                    self.seedDataArray()
            }
        })

        marketWatchRemovedHandle = self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("marketWatch").observe(.childAdded, with: { (snapshot) in
            if let index = self.SharedFunduModel.watchedStocks.index(where: { $0 == snapshot.key }) {
                //self.tableView.beginUpdates()
                self.SharedFunduModel.watchedStocks.remove(at: index)
                self.seedDataArray()
                //self.tableView.deleteRows(at: [IndexPath(row: index,section: 0)], with: .automatic)
                //self.tableView.endUpdates()
            }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = stocksData {
            return data.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Row is DefaultCell
        if (stocksData?[indexPath.row]) != nil {
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
            if indexPath.row < (stocksData?.count)! {
                defaultCell.stock = stocksData?[indexPath.row]
            }
            defaultCell.selectionStyle = .none
            return defaultCell
        }
            // Row is ExpansionCell
        else {
            if let rowData = stocksData?[getParentCellIndex(expansionIndex: indexPath.row)] {
                //  Create an ExpansionCell
                let expansionCell = tableView.dequeueReusableCell(withIdentifier: "ExpandedCell", for: indexPath) as! ExpandedCellTableViewCell
                expansionCell.delegate = self
                expansionCell.stockSymbol = rowData.symbol!

                //  Set the cell's data
                expansionCell.selectionStyle = .none
                return expansionCell
            }
        }
        return UITableViewCell()

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let headerHeight: CGFloat

        switch section {
        case 0:
            // hide the header
            headerHeight = CGFloat.leastNonzeroMagnitude
        default:
            headerHeight = 10
        }

        return headerHeight
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("did select \(indexPath.row)")
        //        if ((tableView.cellForRow(at: indexPath) as! StockCell).isExpanded) {
        //            contractCell(tableView: tableView, index: indexPath.row)
        //        } else {
        //            expandCell(tableView: tableView, index: indexPath.row)
        //        }

        selectRow(row: indexPath.row)

        if (stocksData?[indexPath.row]) != nil {

            // If user clicked last cell, do not try to access cell+1 (out of range)
            if(indexPath.row + 1 >= (stocksData?.count)!) {
                expandCell(tableView: tableView, index: indexPath.row)
            }
            else {
                // If next cell is not nil, then cell is not expanded
                if(stocksData?[indexPath.row+1] != nil) {
                    expandCell(tableView: tableView, index: indexPath.row)
                    // Close Cell (remove ExpansionCells)
                } else {
                    contractCell(tableView: tableView, index: indexPath.row)

                }
            }
        }

        var counter = 0
        for element in stocksData! { // loop through all cells and if you find a nil one (aka an expanded cell), close it
            if let a = element {
                print(counter, a.name)
            } else {
                if counter-1 != indexPath.row { // if there is an expanded cell is not the selected cell, close it
                    print(counter, "null")
                    contractCell(tableView: tableView, index: counter-1)
                    break
                }
            }
            counter += 1
        }
    }

    func selectRow(row: Int) {
        if (stocksData![row]?.symbol != nil && stocksData![row]?.symbol != chosenStock.symbol) { // check that not the currently selected stock so dont redraw the graph for no reason
            self.chosenStock = stocksData![row]!
            self.chosenStockSymbol = chosenStock.symbol!
            if self.chosenStock.name != nil && self.chosenStock.price != nil {
                stockNameLabel.text = self.chosenStock.name! + ": $" + String(describing: self.chosenStock.price!)
            }
            if !activityIndicatorView.isAnimating {
                activityIndicatorView.startAnimating()
            }
            getStockData(stockSymbol: chosenStock.symbol!)
        }
        //menu.setRevealed(true, animated: true)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let rowData = stocksData?[indexPath.row] {
            return 60
        } else {
            return 40
        }
    }

    func getStockData(stockSymbol: String) {
        let baseURL: String! = "https://www.alphavantage.co/query?"
        let apiKey: String! = "T94MDXP24IHU4PMF"
        let urlString = (baseURL + "function=TIME_SERIES_DAILY&symbol=" + stockSymbol + "&apikey=" + apiKey)
        print("***********")
        print(urlString)

        let url = URL(string: (urlString))
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                do {
                    if let urlContent = data {
                        let result = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let json = JSON(result["Time Series (Daily)"] as? NSDictionary as Any)
                        var dataPoints = [[Date:Double]]()
                        for (key,subJson):(String, JSON) in json {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-mm-dd" //Your date format
                            let date = dateFormatter.date(from: key) //according to date format your date string
                            let close = subJson.dictionary!["4. close"]?.doubleValue
                            dataPoints.append([date!:close!])
                        }
                        DispatchQueue.main.async {
                            self.setChart(dataPoints: dataPoints)
                            self.activityIndicatorView.stopAnimating()
                        }
                    }
                } catch {
                    print("error processing JSON")
                }
            }
        }
        task.resume()
    }

    func seedDataArray() -> [[String: Any]]{
        activityIndicatorView.startAnimating()
        let baseURL: String! = "https://www.alphavantage.co/query?"
        let apiKey: String! = "T94MDXP24IHU4PMF"

        let favorites = self.SharedFunduModel.watchedStocks
        if favorites.isEmpty {
            for stockTicker in self.SharedFunduModel.popularStocks {
                self.SharedFunduModel.addWatchStockToUser(stockTicker: stockTicker)
            }
        }
        let formattedArray = (favorites.map{String($0)}).joined(separator: ",%20")
        var stock_array = [[String: Any]]()
        let urlString = (baseURL + "function=BATCH_STOCK_QUOTES&symbols=" + formattedArray + "&apikey=" + apiKey)
        print(urlString)
        var completed = false
        let url = URL(string: (urlString))
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                if let urlContent = data {
                    do {
                        let result = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //                                print(result)
                        if let arrayData = result["Stock Quotes"] as? [[String: String]] {
                            for (item) in arrayData {
                                
                                if !self.stocks.contains(where: {
                                    $0.name == item["1. symbol"]!}) {
                                    stock_array.append( ["stockName": item["1. symbol"]!,"action":
                                        "sell","stockPrice": Double(item["2. price"]!)!, "stockSymbol": item["1. symbol"]! ])
                                    self.stocks.append(Stock(stockData: stock_array.last! as [String : AnyObject]))

                                }
                            }
                            completed = true
                        }
                    } catch {
                        print("error processing JSON")
                    }
                    if completed == true{
                        //self.stocks = Array(Set<Stock>(self.stocks))
                        self.stocksData = self.stocks
                       // self.stocksData = Array(Set<Stock>(self.stocks))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.selectRow(at: IndexPath(row:0, section:0), animated: true, scrollPosition: .top)
                            self.selectRow(row: 0)
                        }
                    }
                }
            }
        }
        task.resume()
        return stock_array
    }

    func buyButtonPressed(stockSymbol: String) {
        promptBuy()
    }

    func sellButtonPressed(stockSymbol: String) {
        promptSell()
    }

    func promptBuy() {
        print((tableView.indexPathForSelectedRow?.row)!)
        let stock = stocks[(tableView.indexPathForSelectedRow?.row)!]


        //let sharesToBuy = alert.addTextField("Number of Shares: ") OLD

        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame: CGRect = CGRect(x:0, y:0, width: 300, height:150); // CGRectMake(left), top, width, height) - left and top are like margins
        let teamPicker: UIPickerView = UIPickerView(frame: pickerFrame);
        teamPicker.tag = 2
        //set the pickers datasource and delegate
        teamPicker.delegate = self
        teamPicker.dataSource = self
        teamPicker.selectRow(0, inComponent: 0, animated: true)
        teamPicker.layer.borderColor = SharedFunduModel.funduColor.cgColor
        teamPicker.layer.borderWidth = 1         //Add the picker to the alert controller

        var labelTexts = ["Team", "Shares"]
        let labelWidth = teamPicker.frame.width / CGFloat(teamPicker.numberOfComponents)
        for index in 0..<labelTexts.count {
            let label: UILabel = UILabel.init(frame: CGRect(x:teamPicker.frame.origin.x + labelWidth * CGFloat(index),y: 0, width: labelWidth, height: 20))
            label.text = labelTexts[index]
            label.textAlignment = .center
            teamPicker.addSubview(label)
        }

        let appearance1 = SCLAlertView.SCLAppearance(
            kWindowWidth: teamPicker.frame.size.width + 28.0,
            showCloseButton: false
        )

        let alert = SCLAlertView(appearance: appearance1)

        alert.customSubview = teamPicker

        alert.addButton("Next") {
            //if textfields are both not empty, create new user (in firebase and model) and segway to parties
            //if(sharesToBuy.text != "") {
            if teamPicker.numberOfRows(inComponent: 1) != 0 {
            let number = teamPicker.selectedRow(inComponent: 1)+1 // zero indexed
            //Int(sharesToBuy.text!)!
            print(number)
            let price = ((stock.price!) as NSString).floatValue
            let confirm = SCLAlertView(appearance: self.appearance)
            let totalPrice = Float(number)*price
            //                if totalPrice < SharedFunduModel.myUser.money {
            //                    insufficientFundsAlert()
            //                }

            confirm.addButton("Confirm Buy") {
                self.activityIndicatorView.startAnimating()
                self.SharedFunduModel.buyStock(stockSymbol: stock.symbol!, numberShares: number,sharePrice: price, teamID: self.buyTeam, completion: {
                    print("executed successfully")
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        SCLAlertView().showSuccess("Your purchase executed successfully", subTitle: "")
                    }
                })
            }
            confirm.addButton("Close") {
                confirm.dismiss(animated: true, completion: {})
            }
            confirm.showNotice("Confirm purchase of \(String(describing: number)) shares of \(stock.name!) at $\(stock.price!) a share?", subTitle: "Your total purchase will be $\(totalPrice)")
            //}
            } else {
                alert.dismiss(animated: true, completion: {
                    print("not enough money")
                })
            }
        }

        alert.addButton("Close") {
            alert.dismiss(animated: true, completion: {})
        }
        alert.showEdit("Buy shares of \(String(describing: stock.name!))", subTitle: "")
    }

    func promptSell() {
        let stockName = stocks[(tableView.indexPathForSelectedRow?.row)!].name
        let stock = stocks[(tableView.indexPathForSelectedRow?.row)!]

        if self.SharedFunduModel.userOwnsStock(stockName: stockName!) { // TODO confirm that user owns this stock

            let teamPickerFrame: CGRect = CGRect(x:0, y:0, width: 300, height:150)
            let teamPicker: UIPickerView = UIPickerView(frame: teamPickerFrame);
            teamPicker.tag = 3
            teamPicker.delegate = self
            teamPicker.dataSource = self
            teamPicker.selectRow(0, inComponent: 0, animated: true)
            teamPicker.layer.borderColor = SharedFunduModel.funduColor.cgColor
            teamPicker.layer.borderWidth = 1

            var labelTexts = ["Team", "Shares"]
            let labelWidth = teamPicker.frame.width / CGFloat(teamPicker.numberOfComponents)
            for index in 0..<labelTexts.count {
                let label: UILabel = UILabel.init(frame: CGRect(x:teamPicker.frame.origin.x + labelWidth * CGFloat(index),y: 0, width: labelWidth, height: 20))
                label.text = labelTexts[index]
                label.textAlignment = .center
                teamPicker.addSubview(label)
            }

            let appearance1 = SCLAlertView.SCLAppearance(
                kWindowWidth: teamPicker.frame.size.width + 28.0,
                showCloseButton: false
            )

            let alert = SCLAlertView(appearance: appearance1)

            alert.customSubview = teamPicker

            alert.addButton("Next") {
                //if textfields are both not empty, create new user (in firebase and model) and segway to parties
                //if(sharesToSell.text != "") {

                let number = teamPicker.selectedRow(inComponent: 1)+1 // zero indexed
                //Int(sharesToBuy.text!)!
                print(number)
                let price = ((stock.price!) as NSString).floatValue
                let totalPrice = Float(number)*price

                let confirm = SCLAlertView(appearance: self.appearance)
                confirm.addButton("Confirm Sale") {
                    // TODO sell
                    self.activityIndicatorView.startAnimating()
                    self.SharedFunduModel.sellStock(stockSymbol: stock.symbol!, numberShares: number, sharePrice: price, teamID: self.buyTeam, completion: {
                        self.activityIndicatorView.stopAnimating()
                        SCLAlertView().showSuccess("Your sale executed successfully", subTitle: "")
                    })
                }
                confirm.addButton("Close") {
                    confirm.dismiss(animated: true, completion: {})
                }
                let sellQuantity = teamPicker.selectedRow(inComponent: 1)
                confirm.showNotice("Confirm sale of \(sellQuantity) shares of \(stockName!) for \(totalPrice)?", subTitle: "")
                //}
            }
            alert.addButton("Close") {
                alert.dismiss(animated: true, completion: {})
            }
            alert.showInfo("Sell shares of \(String(describing: stockName!))", subTitle: "")
        } else { // user doesnt own stock
            let notice = SCLAlertView(appearance: self.appearance)
            notice.addButton("Yes") {
                self.promptBuy()
            }
            notice.addButton("Close") {
                notice.dismiss(animated: true, completion: {})
            }
            notice.showError("You do not yet own shares of \(String(describing: stockName!))", subTitle: "Would you like to purchase some?")
        }

    }

    func userOwnsStock() {

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    // returns number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if( component == 0 ) {
            return SharedFunduModel.myUser.teamNames.count // TODO: GET TEAMS THAT HAVE THIS STOCK
        } else if (component == 1) {
            if(pickerView.tag == 2){ // BUY
                let chosenTeamID = self.SharedFunduModel.myUser.teamIDs[pickerView.selectedRow(inComponent: 0)]
                // TODO: GET NUMBER OF STOCKS THAT team can buy by dividing money / price of stock
                if let userTeamBalance = self.SharedFunduModel.myUser.teamBalances[chosenTeamID] {
                    guard let index = tableView.indexPathForSelectedRow?.row else {
                        return 0
                    }
                    let price = stocks[index].price
                    return Int(userTeamBalance/Double(price!)!) // only show the number of stocks that the user can buy
                }
            } else if (pickerView.tag == 3) { // SELL
                let chosenTeamID = self.SharedFunduModel.myUser.teamIDs[pickerView.selectedRow(inComponent: 0)]
                // TODO: GET NUMBER OF STOCKS THAT HE HAS ON THAT TEAM
                guard let team = self.SharedFunduModel.userTeamsPortfolios[chosenTeamID] else { return 0 }
                guard let stock = team[chosenStock.symbol?.lowercased() as Any] as? NSDictionary else { return 0 }
                guard let quantity = stock["quantity"] as? Int else { return 0 }
                return quantity
            }
        }
        return 500
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()

            pickerLabel?.adjustsFontSizeToFitWidth = true
            pickerLabel?.textAlignment = NSTextAlignment.center
        }

        if component == 0 {
            let teamName = SharedFunduModel.myUser.teamNames[row]
            pickerLabel?.text = teamName
        } else if component == 1 {
            pickerLabel?.text = String(describing: row+1)
        }

        return pickerLabel!;
    }

    // Return the title of each row in your picker ... In my case that will be the profile name or the username string
    // Currently this is not getting caled as VIEW FOR ROW is getting called because i wanted to change the font style
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let teamName = SharedFunduModel.myUser.teamNames[row]
            return teamName
        } else if component == 1 {
            return String(describing: row+1)
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if(pickerView.tag == 2){
                self.buyTeam = SharedFunduModel.myUser.teamIDs[row]
            } else if (pickerView.tag == 3){
                self.sellTeam = SharedFunduModel.myUser.teamIDs[row]
            }
            pickerView.reloadComponent(1)
        }
    }

    /*  Expand cell at given index  */
    private func expandCell(tableView: UITableView, index: Int) {
        // Expand Cell (add ExpansionCells
        if (stocksData?[index]?.name) != nil {
            tableView.beginUpdates()
            self.stocksData?.insert(nil, at: index + 1)
            tableView.insertRows(at: [NSIndexPath(row: index + 1, section: 0) as IndexPath] , with: .top)
            tableView.endUpdates()
        }
    }

    /*  Contract cell at given index    */
    private func contractCell(tableView: UITableView, index: Int) {
        print(index)
        if let name = stocksData?[index]?.name {
            print(name)
            tableView.beginUpdates()
            self.stocksData?.remove(at: index+1)
            tableView.deleteRows(at: [NSIndexPath(row: index+1, section: 0) as IndexPath], with: .top)
            tableView.endUpdates()
        }
    }

    /*  Get parent cell index for selected ExpansionCell  */
    private func getParentCellIndex(expansionIndex: Int) -> Int {
        return expansionIndex-1
    }

    @objc func addStockToMarketWatch() {
        // TODO do we want to add search bar to market watch page
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)

        let tickerName = alert.addTextField("Stock Ticker")

        alert.addButton("Watch Stock") {
            // TODO CHECK IF STOCK TICKER IS REAL
            let stockTicker = tickerName.text!
            self.SharedFunduModel.addWatchStockToUser(stockTicker: stockTicker.uppercased())
        }

        alert.showEdit("Add Stock to Market Watch", subTitle: "Enter Stock Ticker")
    }
}

public class MoneyChartFormatter: NSObject, IAxisValueFormatter{

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        return "$\(Int(value))"
    }
}

extension LineChartView {

    private class LineChartFormatter: NSObject, IAxisValueFormatter {

        var dateArray = [String]()

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            //print(value)
            if (value.truncatingRemainder(dividingBy: 5.0)==0) { // show every 5 labels
                return dateArray[Int(value)]
            } else {
                return ""
            }
        }

        init(labels: [String]) {
            super.init()
            let today = Date()
            let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)
            for i in 0...30{
                let nextDay = Calendar.current.date(byAdding: .day, value: i, to: monthAgo!)
                let date = DateFormatter()
                date.dateFormat = "M/dd"
                let stringDate : String = date.string(from: nextDay!)
                dateArray.append(stringDate)
            }
            //(dateArray)
        }
    }

    //Adam this is broken?
    func setLineChartData(dataPoints: [[Date : Double]], label: String) {

        var dataEntries: [ChartDataEntry] = []
        let sortedDataPoints = dataPoints.sorted { (first, second) -> Bool in
            return first.first!.key > second.first!.key
        }
        if sortedDataPoints.count >= 30 {
        let dataPointsSubset = Array(sortedDataPoints[0..<30])
            for i in 0..<dataPointsSubset.count {
                //print("date: \(String(describing: sortedDataPoints[i].first?.key)) close: \(String(describing: sortedDataPoints[i].first?.value))")
                guard let yValue = sortedDataPoints[i].first?.value else {
                    Answers.logCustomEvent(withName: "market data point yvalue was nil")
                    continue
                }
                let dataEntry = ChartDataEntry(x: Double(i), y: yValue)
                dataEntries.append(dataEntry)
            }

            let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawCircleHoleEnabled = false
            chartDataSet.drawValuesEnabled = false
            chartDataSet.lineWidth = 2.0
            let chartData = LineChartData(dataSet: chartDataSet)

            let chartFormatter = LineChartFormatter(labels: [])
            let xAxis = XAxis()
            xAxis.valueFormatter = chartFormatter
            self.xAxis.valueFormatter = xAxis.valueFormatter

            self.data = chartData
        }
    }

}

