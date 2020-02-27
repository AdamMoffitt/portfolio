//
//  ArticleViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 3/3/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var webView:UIWebView!
    var url:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        webView.delegate = self;
        indicator.center = view.center
        self.view.addSubview(webView)
        self.view.addSubview(indicator)
        webView.loadRequest(URLRequest(url: (URL(string: url)!)))
    }
}

extension ArticleViewController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        indicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}
