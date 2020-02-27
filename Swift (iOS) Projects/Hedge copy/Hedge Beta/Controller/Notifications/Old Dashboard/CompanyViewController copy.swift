//
//  CompanyViewController.swift
//  fundü
//
//  Created by Myrl Marmarelis on 12/7/17.
//  Copyright © 2017 fundü. All rights reserved.
//

import UIKit
import Charts

class CompanyViewController: UIViewController {
    var username: String!
    var ticker: String!
    var screenSize: CGRect!
    var navBar: UINavigationBar!
    var previousValues: [Double]!
    var lineChart: LineChartView!
    var timer = Timer()
    let tickerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenSize = UIScreen.main.bounds
        let dimensions = self.view.frame
        self.tickerLabel.frame = CGRect(x: dimensions.width/2-40, y: 100, width: 80, height: 20)
        self.tickerLabel.text = self.ticker
        self.tickerLabel.textAlignment = .center
        self.view.backgroundColor = UIColor(red:0.21, green:0.84, blue:0.72, alpha:1.0)
        self.addSubviews()
        self.initializePortfolio()
        self.scheduledTimerWithTimeInterval()
    }
    
    func buy() {
//        let chat = ChatViewController()
//        chat.connect() {
//            print("yes")
//            chat.close()
//        }
    }
    
    func addSubviews() {
        self.setNavBar()
        self.view.addSubview(self.tickerLabel)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of x seconds
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        updateStockInfo(ticker: self.ticker)
        print("updating..")
    }
    
    func initializePortfolio(){
        //initialize view
        self.lineChart = LineChartView(frame: CGRect(x: self.view.bounds.width * 0.02, y: self.view.bounds.height * 0.35, width: self.view.bounds.width * 0.96, height: self.view.bounds.height * 0.5))
        self.lineChart.borderLineWidth = 2
        self.lineChart.borderColor = UIColor.white
        renderPortfolio()
        self.view.addSubview(self.lineChart)
    }
    
    func renderPortfolio(){
        let defaultData: [Double] = [315.0113, 316.6501, 314.0113, 314.0001, 315.0113, 315.3421, 315.3313, 316.0021, 315.8113, 316.0128, 316.8003, 316.3281, 316.3481, 316.3781, 316.4281, 316.5281, 316.6281, 316.3281, 316.3281, 316.3281, 316.3281, 316.3281]
        self.previousValues = defaultData
        
        updateStockInfo(ticker: self.ticker)
        var lineChartEntry = [ChartDataEntry]()
        let prices: [Double] = self.previousValues //self.stockInfo.timeSeries
        
        //aggregate price quotes in array
        for i in 0..<prices.count {
            let value = ChartDataEntry(x:Double(i), y: prices[i])
            lineChartEntry.append(value)
        }
        
        //create line with aggregated numbers
        let stockLine = LineChartDataSet(values: lineChartEntry, label: "Price")
        stockLine.colors = ChartColorTemplates.colorful()
        stockLine.drawCirclesEnabled = false
        stockLine.lineWidth = 2.0
        
        //create object for chart view to display
        let data = LineChartData()
        data.addDataSet(stockLine)
        data.setDrawValues(false)
        
        //add to view (also triggers update)
        self.lineChart.data = data
        self.lineChart.leftAxis.axisMinimum = self.previousValues[0] * 0.99
        self.lineChart.leftAxis.axisMaximum = self.previousValues[0] * 1.01
        self.lineChart.leftAxis.drawGridLinesEnabled = false
        self.lineChart.xAxis.drawGridLinesEnabled = false
        self.lineChart.legend.enabled = false
        self.lineChart.rightAxis.enabled = false
        self.lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInSine)
        self.lineChart.xAxis.drawLabelsEnabled = false
        self.lineChart.backgroundColor = UIColor.white
        
        //calculate percent change today
        let change = round(1000*(self.previousValues.first! - self.previousValues.last!)/self.previousValues.first!)/1000
        var changeString = String(change) + "%"
        if change > 0 {
            changeString = "+" + changeString
        }
        
        self.lineChart.chartDescription?.text = "Portfolio Performance: " + changeString
        self.lineChart.chartDescription?.font = UIFont(name: "DidactGothic-Regular", size: 24)!
    }
    
    func renderPortfolio(updatedData: [Double]){
        self.previousValues = updatedData
        var lineChartEntry = [ChartDataEntry]()
        let prices: [Double] = updatedData
        
        //aggregate price quotes in array
        for i in 0..<prices.count {
            let value = ChartDataEntry(x:Double(i), y: prices[i])
            lineChartEntry.append(value)
        }
        
        //create line with aggregated numbers
        let stockLine = LineChartDataSet(values: lineChartEntry, label: "Price")
        stockLine.colors = ChartColorTemplates.colorful()
        stockLine.drawCirclesEnabled = false
        stockLine.lineWidth = 2.0
        
        //create object for chart view to display
        let data = LineChartData()
        data.addDataSet(stockLine)
        data.setDrawValues(false)
        
        //add to view (also triggers update)
        self.lineChart.data = data
        self.lineChart.leftAxis.axisMinimum = self.previousValues[0] * 0.99
        self.lineChart.leftAxis.axisMaximum = self.previousValues[0] * 1.01
        self.lineChart.leftAxis.drawGridLinesEnabled = false
        self.lineChart.xAxis.drawGridLinesEnabled = false
        self.lineChart.legend.enabled = false
        self.lineChart.rightAxis.enabled = false
        self.lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInSine)
        self.lineChart.xAxis.drawLabelsEnabled = false
        self.lineChart.backgroundColor = UIColor.white
        
        //calculate percent change today
        let change = round(1000*(self.previousValues.first! - self.previousValues.last!)/self.previousValues.first!)/1000
        var changeString = String(change) + "%"
        if change >= 0{
            changeString = "+" + changeString
        }
        
        self.lineChart.chartDescription?.text = "Portfolio Performance: " + changeString
        self.lineChart.chartDescription?.font = UIFont(name: "DidactGothic-Regular", size: 24)!
    }
    
//    func renderProfilePhoto(){
//        //sample image, to be replaced by user stored image
//        self.headshot = UIImageView(image: UIImage(named: "headshot"))
//        self.headshot.frame = CGRect(x:self.view.center.x, y:0, width:100, height:100)
//        self.headshot.setRounded()
//        self.headshot.clipsToBounds = true
//        self.headshot.center = CGPoint(x: Int(self.view.bounds.width * 0.25), y: 125)
//        self.view.addSubview(self.headshot)
//    }
    
    func setNavBar() {
        //self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 50))
        addBackButton()
        //self.view.addSubview(navBar)
        print("after adding nav")
    }
    
    func addBackButton() {
        //let navItem = UINavigationItem(title: self.ticker)
        let backButton = UIBarButtonItem(title: "< Dashboard", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backAction))
        //navItem.leftBarButtonItem = backButton
        self.navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    @objc func backAction(_ sender: UIButton) {
        //let dashViewController = DashboardContainerViewController()
        //dashViewController.username = self.username
        //present(dashViewController, animated: true, completion: nil)
        self.navigationController!.dismiss(animated: true)
    }
    
    func updateStockInfo(ticker:String) {
        print("update info")
        let baseURL: String! = "https://www.alphavantage.co/query?"
        let apiKey: String! = "T94MDXP24IHU4PMF"
        
        //var lastRefreshed = String()
        //let interval: String = "1 min"
        var timeSeries = [Double]()
        var completed = false
        
        let urlString = (baseURL + "function=TIME_SERIES_INTRADAY&symbol=" + ticker + "&interval=1min&apikey=" + apiKey)
        let url = URL(string: (urlString))
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                if let urlContent = data {
                    do {
                        let result = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //                        if let meta = result["Meta Data"] as? [String: String] {
                        //                            lastRefreshed = meta["3. Last Refreshed"]!
                        //                        }
                        if let arrayData = result["Time Series (1min)"] as? [String: [String: String]] {
                            for (_, item) in arrayData {
                                print(item["4. close"]!)
                                timeSeries.append( Double(item["4. close"]! )! )
                            }
                            completed = true
                        }
                    } catch {
                        print("error processing JSON")
                    }
                    DispatchQueue.main.async(execute: {
                        if completed == true{
                            print("rerender")
                            //now re render chart with new data
                            self.renderPortfolio(updatedData: timeSeries)
                        }
                    })
                }
            }
        }
        task.resume()
    }
}

