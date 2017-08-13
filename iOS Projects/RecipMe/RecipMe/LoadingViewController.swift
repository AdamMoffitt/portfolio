//
//  SimpsonsViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 1/18/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit
import GTProgressBar
import NVActivityIndicatorView

/*
 This is an abstract class that provides its child view controllers with a loading screen that appears when the showLoadingScreen() method is called.
 */

class LoadingViewController: UIViewController {
    
    var simpsonsLoadingView : UIView?
    var image = UIImage()
    var height : Double?
    var width : Double?
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 290
    
    var progressBar : GTProgressBar!
    var loadingSpinner : NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        height = Double(self.view.bounds.size.height)
        width = Double(self.view.bounds.size.width)
        
        simpsonsLoadingView = UIView(frame: CGRect(x: (self.view.frame.size.width - CARD_WIDTH)/2, y: (self.view.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        //simpsonsLoadingView = UIView(frame: CGRect(x: 20.0, y: Double(20.0 + (self.topLayoutGuide.length)), width: (width!-20.0), height: (height!-20.0)-Double(self.bottomLayoutGuide.length)))
        
        simpsonsLoadingView?.backgroundColor = UIColor.darkGray
        
        image = UIImage.animatedImageNamed("simpsons-", duration: 1.0)!
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.clipsToBounds = true
        //imageView.contentMode = UIViewContentMode.scaleAspectFit
        //imageView.contentMode = UIViewContentMode.center
        
        imageView.frame =  CGRect(x: (simpsonsLoadingView?.bounds.minX)!, y: (simpsonsLoadingView?.bounds.minY)!, width: (CARD_WIDTH), height: (3*CARD_HEIGHT/4))
        //imageView.frame = CGRect(x: simpsonsLoadingView!.frame.minX, y: (simpsonsLoadingView?.frame.minY)!, width: (simpsonsLoadingView?.frame.width)!, height: (simpsonsLoadingView?.frame.height)!
        
        progressBar = GTProgressBar(frame: CGRect(x: (simpsonsLoadingView?.bounds.minX)!, y: ((simpsonsLoadingView?.bounds.minY)! + ((3/4)*CARD_HEIGHT)), width: CARD_WIDTH, height: CARD_HEIGHT/4))
        progressBar.progress = 0
        progressBar.barBorderColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.barFillColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.barBackgroundColor = UIColor(red:0.77, green:0.93, blue:0.78, alpha:1.0)
        progressBar.barBorderWidth = 1
        progressBar.barFillInset = 2
        progressBar.labelTextColor = UIColor(red:0.35, green:0.80, blue:0.36, alpha:1.0)
        progressBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        progressBar.font = UIFont.boldSystemFont(ofSize: 18)
        progressBar.barMaxHeight = 12
        
        let loadingLabel = UILabel(frame: CGRect(x: (simpsonsLoadingView?.bounds.minX)!, y: ((simpsonsLoadingView?.bounds.minY)! + ((3/4)*CARD_HEIGHT)), width: CARD_WIDTH, height: CARD_HEIGHT/4))
        loadingLabel.text = "Loading..."
        loadingLabel.backgroundColor = UIColor.white
        loadingLabel.textAlignment = .center
        
        
        loadingSpinner = NVActivityIndicatorView(frame: CGRect(x: (simpsonsLoadingView?.bounds.minX)!, y: ((simpsonsLoadingView?.bounds.minY)! + ((3/4)*CARD_HEIGHT)), width: CARD_WIDTH, height: CARD_HEIGHT/4), type: .ballRotateChase)
        
        simpsonsLoadingView?.addSubview(imageView)
        simpsonsLoadingView?.addSubview(loadingSpinner)
        self.view.addSubview(simpsonsLoadingView!)
        
        simpsonsLoadingView?.isHidden = true
    }
    
    func setProgress(progress: Double) {
        progressBar.progress = CGFloat(progress);
    }
    
    func showLoadingScreenBar(true: Bool) {
        progressBar.isHidden = true
    }
    func showLoadingScreen(){
        simpsonsLoadingView?.isHidden = false
        loadingSpinner.startAnimating()
    }
    func hideLoadingScreen(){
        simpsonsLoadingView?.isHidden = true
        loadingSpinner.stopAnimating()
    }
}
