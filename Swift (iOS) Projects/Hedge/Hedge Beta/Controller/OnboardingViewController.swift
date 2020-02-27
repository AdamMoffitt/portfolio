//
//  OnboardingViewController.swift
//  fundü
//
//  Created by Jordan Coppert on 3/15/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import UIKit
import paper_onboarding
import NVActivityIndicatorView

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {
//    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
//        <#code#>
//    }
    
    
    var userEmail:String!
    var visited:Bool = false
    var completeOnboardingButton:UIButton!
    var onboardingView: PaperOnboarding!
    var activityIndicatorView:NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FunduModel.shared.funduColor
        createOnboardingView()
        createCompletionButton()
        setupConstraints()
    }
    
    
    func createOnboardingView(){
        onboardingView = PaperOnboarding()
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        onboardingView.dataSource = self
        onboardingView.delegate = self
        view.addSubview(onboardingView)
    }
    
    func createCompletionButton() {
        completeOnboardingButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.view.safeAreaLayoutGuide.layoutFrame.height * 0.1))
        completeOnboardingButton.addTarget(self, action: #selector(moveToDash), for: .touchUpInside)
//        completeOnboardingButton.layer.cornerRadius = 15
//        completeOnboardingButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        completeOnboardingButton.translatesAutoresizingMaskIntoConstraints = false
        completeOnboardingButton.alpha = 0.0
        completeOnboardingButton.setTitle("Begin", for: .normal)
        completeOnboardingButton.titleLabel?.font = UIFont(name: "DidactGothic-Regular", size: 18)
        view.addSubview(completeOnboardingButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if visited == true {
            self.dismiss(animated: false, completion: nil)
        } else {
            visited = true
        }
    }
    
    func onboardingItemsCount() -> Int {
        return 6
    }
    
    func setupConstraints(){
        let guide = view.safeAreaLayoutGuide
        onboardingView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        onboardingView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        onboardingView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        onboardingView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        
//        self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.view.safeAreaLayoutGuide.layoutFrame.width * 0.1)
        
        completeOnboardingButton.widthAnchor.constraint(equalToConstant: self.view.safeAreaLayoutGuide.layoutFrame.width).isActive = true
        completeOnboardingButton.heightAnchor.constraint(equalToConstant: self.view.safeAreaLayoutGuide.layoutFrame.height * 0.1).isActive = true
        completeOnboardingButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
//        completeOnboardingButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        completeOnboardingButton.bottomAnchor.constraint(greaterThanOrEqualTo: guide.bottomAnchor, constant: -60).isActive = true
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let backgroundColor2 = FunduModel.shared.funduColor
        
        let titleFont = UIFont.systemFont(ofSize: 36)
        let descriptionFont = UIFont.systemFont(ofSize: 24)
        
        return [OnboardingItemInfo(informationImage: UIImage(named: "welcome")!, title: "Invest together.", description: "Welcome to Hedge! Before you dominate the leaderboards here's some tips to get you started.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: UIImage(named: "wolfpack")!, title: "Strength in numbers.", description: "Hedge's competitive ecosystem is based on teams. Create new teams and manage existing ones from the dashboard.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: UIImage(named: "race")!, title: "Race to the top.", description: "Collections of competing teams are called leagues. To create or join a league go to the 'Browse Leagues' page in the menu.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: UIImage(named: "diligence")!, title: "Due diligence.", description: "Use the search bar to find companies and purchase their stock. Use the 'Market Watch' page to add companies to your watch list.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: UIImage(named: "greed")!, title: "Greed is good.", description: "Remember, each team has its OWN portfolio. When purchasing or liquidating stock you must select a team from which you want to buy/sell.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: UIImage(named: "ending")!, title: "Ready, set, go!", description: "Tap the plus icon to create your team and start investing. The clock starts now, your percentage gains are being tracked.", pageIcon: UIImage(), color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont)
            ][index]
    }
    
    @objc func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }
    
    @objc func moveToDash(){
        print("tapped")
        
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.moveToDashboardView()
        self.dismissKeyboard()
        UIView.animate(withDuration: 1.0, animations: {() in
            self.loadingAnimation()
            self.completeOnboardingButton.removeFromSuperview()
            self.onboardingView.removeFromSuperview()
        })
    }
    
    func loadingAnimation() {
        self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.5).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.5).isActive = true
        self.activityIndicatorView.startAnimating()
    }
    
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 4 {
            if self.completeOnboardingButton.alpha == 1.0 {
                UIView.animate(withDuration: 0.4, animations: {
                    self.view.bringSubview(toFront: self.onboardingView)
                    self.completeOnboardingButton.alpha = 0.0
                })
            }
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 5 {
            UIView.animate(withDuration: 0.4, animations: {
                self.view.bringSubview(toFront: self.completeOnboardingButton)
                self.completeOnboardingButton.alpha = 1
            })
        }
    }
    
}

