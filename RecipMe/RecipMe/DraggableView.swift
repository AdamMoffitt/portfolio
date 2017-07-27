//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle

protocol DraggableViewDelegate {
    func cardSwipedLeft(_ card: UIView) -> Void
    func cardSwipedRight(_ card: UIView) -> Void
    func cardSwipedUp(_ card: UIView) -> Void
    func cardSwipedDown(_ card: UIView) -> Void
    func cardDoubleTapped(_ card: UIView) -> Void
    func cardSingleTapped(_ card: UIView) -> Void
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var doubleTap : UITapGestureRecognizer?
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    var recipeTitleLabel: UILabel!
    var recipeInfoLabel: UILabel!
    var recipeImageView: UIImageView!

    var recipeTitle : String?
    var recipeInfo : String?
    var recipeImage : UIImage?
    var recipeImageURL : String?
    var recipeId : Int?
    var recipeIndex : Int?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        
        recipeTitle = ""
        recipeInfo = ""
        recipeImage = UIImage(named: "RecipeMeIcon")
        recipeImageURL = ""
        recipeId = 0
        
        recipeTitleLabel = UILabel(frame: CGRect(x: 0, y: self.frame.size.height-100, width: self.frame.size.width, height: 50))
        recipeTitleLabel.text = "no info given"
        recipeTitleLabel.textAlignment = NSTextAlignment.center
        recipeTitleLabel.textColor = UIColor.black
        recipeTitleLabel.numberOfLines = 0
        recipeTitleLabel.adjustsFontSizeToFitWidth = true
        recipeTitleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        recipeInfoLabel = UILabel(frame: CGRect(x: 0, y: self.frame.size.height-50, width: self.frame.size.width, height: 50))
        recipeInfoLabel.text = "no info given"
        recipeInfoLabel.textAlignment = NSTextAlignment.center
        recipeInfoLabel.textColor = UIColor.black
        recipeInfoLabel.numberOfLines = 0
        recipeInfoLabel.adjustsFontSizeToFitWidth = true
        
        let i = UIImage(named: "RecipMeIcon.png")
        recipeImageView = UIImageView(image: i)
        recipeImageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height-100)
        recipeImageView.contentMode = UIViewContentMode.scaleAspectFill
        recipeImageView.clipsToBounds = true
        self.backgroundColor = UIColor.white
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DraggableView.beingDragged(_:)))
        
        doubleTap = UITapGestureRecognizer()
        // DOUBLE TAP
        doubleTap?.numberOfTapsRequired = 2
        doubleTap?.addTarget(self, action: #selector(DraggableView.doubleTappedAction))
        
        
        self.addGestureRecognizer(panGestureRecognizer)
        self.addGestureRecognizer(doubleTap!)
        self.addSubview(recipeImageView)
        self.addSubview(recipeTitleLabel)
        self.addSubview(recipeInfoLabel)
        
        
        overlayView = OverlayView(frame: CGRect(x: self.frame.size.width/2-100, y: 0, width: 100, height: 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)
        
        xFromCenter = 0
        yFromCenter = 0
    }
    
    func setupView() -> Void {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSize(width: 1, height: 1);
    }
    
    func set(title: String, info: String, image: UIImage, imageURL: String, id: Int, index: Int){
        recipeTitleLabel.text = title
        recipeTitle = title
        recipeInfoLabel.text = info
        recipeInfo = info
        recipeImageView.image = image
        recipeImage = image
        recipeImageURL = imageURL
        recipeId = id
        recipeIndex = index
    }
    
    func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translation(in: self).x)
        yFromCenter = Float(gestureRecognizer.translation(in: self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            self.originPoint = self.center
        case UIGestureRecognizerState.changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
            
            self.center = CGPoint(x: self.originPoint.x + CGFloat(xFromCenter), y: self.originPoint.y + CGFloat(yFromCenter))
            
            let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.possible:
            fallthrough
        case UIGestureRecognizerState.cancelled:
            fallthrough
        case UIGestureRecognizerState.failed:
            fallthrough
        default:
            break
        }
    }
    
    func updateOverlay(_ distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.4))
    }
    
    func afterSwipeAction() -> Void {
        let floatYFromCenter = Float(yFromCenter)
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else if floatYFromCenter > ACTION_MARGIN {
            self.upAction()
        } else if floatYFromCenter < -ACTION_MARGIN {
            self.downAction()
        }
        
        else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.overlayView.alpha = 0
            })
        }
    }
    
    func doubleTappedAction() {
        delegate.cardDoubleTapped(self)
    }
    
    func singleTappedAction() {
        delegate.cardSingleTapped(self)
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: 500, y: 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }
    
    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: -500, y: 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
    
    func upAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: 2 * CGFloat(xFromCenter) + self.originPoint.x, y: 500)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedUp(self)
    }
    
    func downAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: 2 * CGFloat(xFromCenter) + self.originPoint.x, y: -500)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedDown(self)
    }
    
    func rightClickAction() -> Void {
        let finishPoint = CGPoint(x: 600, y: self.center.y)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
                        self.transform = CGAffineTransform(rotationAngle: 1)
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }
    
    func leftClickAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: -600, y: self.center.y)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.center = finishPoint
                        self.transform = CGAffineTransform(rotationAngle: 1)
        }, completion: {
            (value: Bool) in
            self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
    
    
}
