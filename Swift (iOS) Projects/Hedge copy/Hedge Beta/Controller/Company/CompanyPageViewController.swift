//
//  CompanyPageViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 2/23/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

protocol StockBoughtDelegate
{
    func StockBought()
}

class CompanyPageViewController: UIViewController {
    var owned:Bool = false {
        didSet {
            if owned == true {
                buttonStack?.addArrangedSubview(liquidateButton)
            }
        }
    }
    var buttonStack:UIStackView!
    var ticker:String!
    var name:UILabel!
    var tickerLabel:UILabel!
    var priceLabel:UILabel!
    var quotePrice:Float!
    var sectorLabel:UILabel!
    var industryLabel:UILabel!
    var purchaseButton:UIButton!
    var liquidateButton:UIButton!
    var SharedFunduModel = FunduModel.shared
    var companyName:String!
    var sector:String!
    var industry:String!
    var news:UITableView!
    var articles: [Article] = []
    var lineChartView: LineChartView!
    var activityIndicatorView : NVActivityIndicatorView!
    var nav:UINavigationController!
    var userTeams = [Team]() {
        didSet {
            s.data = userTeams
        }
    }
    var sharesOwned = 0
    var quantity = 0
    var selectedTeam:IndexPath = IndexPath(row: -1, section: 0)
    var s:SelectOptionsViewController = SelectOptionsViewController()
    var isPurchase:Bool!
    var delegate: StockBoughtDelegate?
    var sharePrice: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = FunduModel.shared.hedgePrimaryColor
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
        getStockData(stockSymbol: ticker)
        //lineChartView.axis
        //checkOwnership(ticker: ticker)
        let apiRequest = "https://api.iextrading.com/1.0/stock/\(ticker!)/batch?types=company,quote,news"
        Alamofire.request(apiRequest).validate().responseJSON { response in
            let json = JSON(response.value as Any)
            if let companyName = json["company"]["companyName"].string {
                self.name.text = companyName
            }
            if let stockPrice = json["quote"]["latestPrice"].double {
                print(stockPrice)
                self.quotePrice = Float(stockPrice)
                var currencyFormatter = NumberFormatter()
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                formatter.groupingSeparator = "."
                formatter.generatesDecimalNumbers = true
                formatter.locale = .current
                self.sharePrice = Float(stockPrice)
                self.priceLabel.text = "Price: " + formatter.string(from: NSNumber(value: stockPrice))! + " | Shares: \(self.sharesOwned)"
            }
            for index in 0...4 {
                guard let headline = json["news"][index]["headline"].string, let author = json["news"][index]["source"].string,let url = json["news"][index]["url"].string else {
                    continue
                }
                self.articles.append(Article(headline: headline, author: author, url: url))
            }
            self.news.reloadData()
        /*
            json["news"][0]["summary"].string
            json["news"][0]["headline"].string
            json["news"][0]["source"].string
        */
        }
        self.navigationItem.title = ticker
        createCompanyName()
        createChart()
        createCompanyPrice()
        createButtons()
        createNews()
        setConstraints()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        print("in appear")
    }
    
    func setChart(dataPoints: [[Date : Double]]) {
        lineChartView.setLineChartData(dataPoints: dataPoints, label: ticker)
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0, easingOption: .linear)
    }
    
    func createNews(){
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height
        news = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight * 0.4))
        news.register(NewsArticleCell.self, forCellReuseIdentifier: "NewsArticleCell")
        news.rowHeight = UITableViewAutomaticDimension
        news.estimatedRowHeight = 100
        news.translatesAutoresizingMaskIntoConstraints = false
        news.dataSource = self
        news.delegate = self
        news.backgroundColor = FunduModel.shared.hedgePrimaryColor
        self.view.addSubview(news)
    }
    
    func createButtons(){
        purchaseButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:50))
        liquidateButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:50))
        purchaseButton.backgroundColor = UIColor.orange
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.setTitle("Buy", for: .normal)
        liquidateButton.backgroundColor = UIColor.green
        liquidateButton.setTitleColor(.white, for: .normal)
        liquidateButton.setTitle("Sell", for: .normal)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        liquidateButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.addTarget(self, action: #selector(purchase), for: .touchUpInside)
        liquidateButton.addTarget(self, action: #selector(liquidate), for: .touchUpInside)
        
        buttonStack = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.spacing = 5
        buttonStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(purchaseButton)
        if(owned) {
            buttonStack.addArrangedSubview(liquidateButton)
        }
        self.view.addSubview(buttonStack)
    }
    
//    func createHeader(){
//        s = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.9, height: 40))
//        s.axis = .horizontal
//        s.distribution = .fill
//        s.alignment = .center
//        s.spacing = 5
//        s.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        s.translatesAutoresizingMaskIntoConstraints = false
//
//        createCompanyName()
//        createTicker()
//        s.addArrangedSubview(name)
//        s.addArrangedSubview(tickerLabel)
//        self.view.addSubview(s)∂
//    }
    
// https://us-central1-hedge-beta.cloudfunctions.net/transferStocks?ticker=goog&amount=10&price=150&user=XF4057jiRtdZamAoGi3uzMjiFcm2&team=XF4057jiRtdZamAoGi3uzMjiFcm2&league=FEC35503-6536-4A88-AE84-B1C67AAA9156&buy=true
    
    func completeStockTransfer(){
        let value = isPurchase ? "true" : "false"
        let urlString = ("https://us-central1-hedge-beta.cloudfunctions.net/transferStocks?ticker=\(ticker!)&team=\(userTeams[selectedTeam.row].teamID)&amount=\(quantity)&price=\(sharePrice!)&user=\(FunduModel.shared.myUser.userID)&buy=\(value)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        s.waitResponse()
        Alamofire.request(urlString).validate().responseString { (response) in
            switch response.result {
            case .success:
                print("success")
                self.s.success()
            case .failure(let error):
                self.s.fail()
                print(error)
            }
        }
    }
    
    func etGoHome(){
        self.s.removeFromParentViewController()
        self.nav.popViewController(animated: true)
        self.delegate?.StockBought()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MarketViewController {
            let mvc = segue.destination as! MarketViewController
            mvc.refreshWalletBalance()
        }
    }
//    func checkOwnership(ticker:String){
//        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/userHasStock?userID=\(FunduModel.shared.myUser.userID)&ticker=\(ticker)"
//        Alamofire.request(urlString).validate().responseJSON { (response) in
//            switch response.result {
//            case .success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    if let teams = json["teams"].array {
//                        if json["isOwned"].boolValue {
//                            self.owned = true
//                        }
//                        for team in teams {
//                            let t = Team(teamID: team["teamID"].string!, teamName: team["teamName"].string!, userBalance: team["userBalance"].float!, stockQuantity: team["quantity"].int!)
//                            self.userTeams.append(t)
//                        }
//                        self.s.data = self.userTeams
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//
//    }
    
    func createCompanyPrice(){
        priceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        priceLabel.text = "Placeholder"
        priceLabel.textAlignment = .center
        priceLabel.textColor = .white
        priceLabel.font = UIFont(name: "DidactGothic-Regular", size: 36)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.numberOfLines = 0
        self.view.addSubview(priceLabel)
    }
    
    func createCompanyName(){
        name = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        name.text = "Placeholder"
        name.textAlignment = .center
        name.textColor = .white
        name.font = UIFont(name: "DidactGothic-Regular", size: 18)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.numberOfLines = 0
        self.view.addSubview(name)
    }
    
//    func createTicker(){
//        tickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
//        tickerLabel.text = ticker
//        tickerLabel.textAlignment = .center
//        tickerLabel.font = UIFont(name: "DidactGothic-Regular", size: 18)
//        tickerLabel.translatesAutoresizingMaskIntoConstraints = false
//        tickerLabel.numberOfLines = 0
//        //self.view.addSubview(tickerLabel)
//    }
    
    func createChart(){
        //self.edgesForExtendedLayout = []
        lineChartView = LineChartView(frame: CGRect(x: 2, y: 0, width: view.frame.width - 2, height: (view.frame.height/3)))
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.leftAxis.drawZeroLineEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.labelTextColor = .white
        lineChartView.xAxis.labelTextColor = .white
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
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
//        lineChartView.insetsLayoutMarginsFromSafeArea = true
        
        view.backgroundColor = FunduModel.shared.hedgePrimaryColor
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: lineChartView.frame.width, height: lineChartView.frame.height*0.9), type: .ballClipRotateMultiple, color: UIColor.black, padding: 30.0)
        lineChartView.addSubview(activityIndicatorView)
        view.addSubview(lineChartView)
    }
    
    @objc func liquidate(){
        s.modalPresentationStyle = .overCurrentContext
        let boundsW = self.view.bounds.width * 0.95
        let boundsH = self.view.bounds.height * 0.4
        s.boundsW = boundsW
        s.boundsH = boundsH
        s.parentVC = self
        s.promptString = "How many shares do you want to sell?"
        s.data = userTeams
        s.action = "sale"
        //Cut dollar sign
        let p:String! = priceLabel.text!
        s.price = quotePrice
        s.startUp()
        self.present(s, animated: true, completion: nil)
        print("sale")
    }
    
    @objc func purchase(){
        s.modalPresentationStyle = .overCurrentContext
        let boundsW = self.view.bounds.width * 0.95
        let boundsH = self.view.bounds.height * 0.4
        s.boundsW = boundsW
        s.boundsH = boundsH
        s.parentVC = self
        s.promptString = "How many shares do you want to buy?"
        s.data = userTeams
        s.action = "purchase"
        //Cut dollar sign
        let p:String! = priceLabel.text!
        s.price = quotePrice
        s.startUp()
        self.present(s, animated: true, completion: nil)
        print("purchase")
        
        /* WILL IMPLEMENT THIS
         
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
         */
    }
    
    func getStockData(stockSymbol: String) {
        let baseURL: String! = "https://www.alphavantage.co/query?"
        let apiKey: String! = "T94MDXP24IHU4PMF"
        let urlString = (baseURL + "function=TIME_SERIES_DAILY&symbol=" + ticker + "&apikey=" + apiKey)
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
    
    func setConstraints(){
        let margins = view.safeAreaLayoutGuide
        name.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 0.7).isActive = true
        name.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        priceLabel.topAnchor.constraintEqualToSystemSpacingBelow(name.bottomAnchor, multiplier: 4.0).isActive = true
        priceLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        //name.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        //name.leadingAnchor.constraintEqualToSystemSpacingAfter(margins.leadingAnchor, multiplier: 1.2).isActive = true
        //name.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        //name.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true
        
        //tickerLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        //tickerLabel.leadingAnchor.constraintEqualToSystemSpacingAfter(name.trailingAnchor, multiplier: 0.1).isActive = true
        
//        lineChartView.topAnchor.constraintEqualToSystemSpacingBelow(name.bottomAnchor, multiplier: 1.4).isActive = true
        lineChartView.topAnchor.constraintEqualToSystemSpacingBelow(priceLabel.bottomAnchor, multiplier: 1.0).isActive = true
        lineChartView.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.3).isActive = true
        lineChartView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        lineChartView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.9).isActive = true
        buttonStack.topAnchor.constraintEqualToSystemSpacingBelow(lineChartView.bottomAnchor, multiplier: 1.04).isActive = true
        buttonStack.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width * 0.9).isActive = true
        buttonStack.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        purchaseButton.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width * 0.4).isActive = true
        liquidateButton.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width * 0.4).isActive = true
        news.topAnchor.constraintEqualToSystemSpacingBelow(buttonStack.bottomAnchor, multiplier: 0.1).isActive = true
        news.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        news.widthAnchor.constraint(equalToConstant: margins.layoutFrame.width).isActive = true
        news.heightAnchor.constraint(equalToConstant: margins.layoutFrame.height * 0.4).isActive = true
    }
    
}

extension CompanyPageViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let articleVC = ArticleViewController()
        articleVC.url = articles[indexPath.row].url
        nav.pushViewController(articleVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CompanyPageViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsArticleCell", for: indexPath) as! NewsArticleCell
        print(cell)
        cell.setupViews(article: articles[indexPath.row], textColor: .white, backgroundColor: FunduModel.shared.hedgePrimaryColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
}
