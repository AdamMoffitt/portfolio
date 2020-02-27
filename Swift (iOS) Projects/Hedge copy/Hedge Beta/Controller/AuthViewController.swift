//
//  ViewController.swift
//  fundü
//
//  Created by Nicholas Kaimakis on 11/29/17.
//  Copyright © 2017 fundü. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import GoogleSignIn
import NVActivityIndicatorView

// TODO JORDAN : Some big changes in the Auth process. Right now, we will only allow users to log in through Google. It makes the onboarding process easier, and also allows all users to effortlessly invite their friends which is a core functionality. This page will need new constraints.
// The majority of Log in functionality has been moved to the AppDelegate. The Google Sign in crap needs to be in the app delegate for some reason, so i have rewritten it there and commented out stuff here
class AuthViewController: UIViewController, GIDSignInUIDelegate {
    var titleLabel: UILabel!
    var mottoLabel: UILabel!
    let SharedFunduModel = FunduModel.shared
    let userDefaults = UserDefaults.standard
    var gSignInButton: GIDSignInButton!
    var activityIndicatorView: NVActivityIndicatorView!
    var logo:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SharedFunduModel.hedgePrimaryColor
        
        createTitleLabel()
        createMottoLabel()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        logo = UIImageView(frame: CGRect(x: 0,y: 0, width: view.bounds.width * 0.8,height: view.bounds.height * 0.15))
        logo.image = UIImage(named: "hedgeLogo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(logo)
        
        gSignInButton = GIDSignInButton(frame: CGRect(x: 0,y: 0, width: self.view.bounds.width/2,height: self.view.bounds.height * 0.1))
        gSignInButton.translatesAutoresizingMaskIntoConstraints = false
        gSignInButton.colorScheme = GIDSignInButtonColorScheme.light
        self.view.addSubview(gSignInButton)
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.4, height: self.view.frame.height * 0.4), type: .ballClipRotateMultiple, color: UIColor.white, padding: 30.0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView)
        setConstraints()
        
        if Auth.auth().currentUser != nil { // if user is already logged in, sign in with Google
            GIDSignIn.sharedInstance().signIn()
            gSignInButton.isEnabled = false
            activityIndicatorView.startAnimating()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createTitleLabel(){
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.bounds.height * 0.2))
        titleLabel.textAlignment = .center
        titleLabel.text = "Hedge"
        titleLabel.textColor = SharedFunduModel.hedgeMainTextColor
        titleLabel.center.x = self.view.center.x
        titleLabel.center.y = self.view.center.y * 0.4
        titleLabel.font = UIFont(name: "DidactGothic-Regular", size: 44)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
    }
    
    func createMottoLabel(){
        self.mottoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Int(self.view.bounds.width), height: 40))
        mottoLabel.textAlignment = .center
        mottoLabel.text = "invest with friends"
        mottoLabel.textColor = SharedFunduModel.hedgeMinorTextColor
        mottoLabel.center.x = self.view.center.x
        mottoLabel.center.y = self.view.center.y * 0.6
        mottoLabel.font = UIFont(name: "OpenSans-LightItalic", size: 26)
        mottoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mottoLabel)
    }
    
    func setConstraints(){
        let margins = view.safeAreaLayoutGuide
        logo.topAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 12).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.5).isActive = true
        logo.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.15).isActive = true
        
        titleLabel.topAnchor.constraintEqualToSystemSpacingBelow(logo.bottomAnchor, multiplier: 3).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        mottoLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
        mottoLabel.topAnchor.constraintEqualToSystemSpacingBelow(titleLabel.bottomAnchor, multiplier: 1).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        activityIndicatorView.topAnchor.constraintEqualToSystemSpacingBelow(mottoLabel.bottomAnchor, multiplier: 6).isActive = true
        
        gSignInButton.topAnchor.constraintEqualToSystemSpacingBelow(mottoLabel.bottomAnchor, multiplier: 3).isActive = true
        gSignInButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        gSignInButton.widthAnchor.constraint(equalToConstant: self.view.frame.width/2).isActive = true
        gSignInButton.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.1)
    }
}

extension UIViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

