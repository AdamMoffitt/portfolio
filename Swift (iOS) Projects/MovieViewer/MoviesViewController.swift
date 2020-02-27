//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Adam Moffitt on 9/30/16.
//  Copyright © 2016 USC SCOPE. All rights reserved.
//

import UIKit
import AFNetworking
import M13ProgressSuite

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate  = self
        
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        loadMoreData()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        loadMoreData()
    }
    
    
    func loadMoreData() {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            url: url! as URL,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        
         // Configure session so that completion handler is executed on main UI thread
        //M13ProgressViewFilteredImage.showHUDAddedTo(self.view, animated: true)
       
        
        // Configure session so that completion handler is executed on main UI thread
  
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                                                                                        completionHandler: { (dataOrNil, response, error) in
                                                                                                                                // Update flag                                      self.isMoreDataLoading = false
                                                                                                                            if let data = dataOrNil {
                                                                                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                                                                                    with: data, options:[]) as? NSDictionary {
                                                                                                                                    print("response: \(responseDictionary)")
                                                                                                                                    
                                                                                                                                    self.movies = responseDictionary["results"] as![NSDictionary]                          }
                                                                                        
                                                                                                                                self.tableView.reloadData()}
                                                                                                                            
                                                                                                                        
                                                                                                                            // Hide HUD once the network request comes back (must be done on main UI thread)
                                                                                                                            //MBProgressHUD.hideHUDForView(self.view, animated: true)
        });
        task.resume()
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()		
            }
        }
    }

    class InfiniteScrollActivityView: UIView {
        var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        static let defaultHeight:CGFloat = 60.0
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupActivityIndicator()
        }
        
        override init(frame aRect: CGRect) {
            super.init(frame: aRect)
            setupActivityIndicator()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
        
        func setupActivityIndicator() {
            activityIndicatorView.activityIndicatorViewStyle = .gray
            activityIndicatorView.hidesWhenStopped = true
            self.addSubview(activityIndicatorView)
        }
        
        func stopAnimating() {
            self.activityIndicatorView.stopAnimating()
            self.isHidden = true
        }
        
        func startAnimating() {
            self.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let movies = movies{
             return movies.count;
        } else {
            return 0
        }
        
       
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
            let movie = movies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.posterView.setImageWith(imageURL as! URL)
        }
              print("row\(indexPath.row)")
        return cell
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        
        print("Prepare for segue called")

        
        
        // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    
}
