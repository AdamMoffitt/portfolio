//
//  DashboardViewController.swift
//  fundü
//
//  Created by Nicholas Kaimakis on 12/2/17.
//  Copyright © 2017 fundü. All rights reserved.
//
import UIKit
import InstantSearch
import SCLAlertView
import Contacts
import SwiftyJSON

class DashboardViewController: UIViewController {
    var username: String!
    var token:String!
    var collection: UICollectionView!
    var searchController: UISearchController!
    var searchResults: SearchResultsViewController!
    let SharedFunduModel = FunduModel.shared
    var teams:[Team] = [] {
        //When it's set we reload the collection, if collection isn't populated yet it'll have the right data to work with
        didSet {
            self.collection?.reloadData()
        }
    }
    let store = CNContactStore()
    var pages:UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        self.view.backgroundColor = SharedFunduModel.hedgePrimaryColor
        let btnCreateTeam = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(createNewTeam))
        self.navigationItem.rightBarButtonItem = btnCreateTeam
        self.navigationItem.rightBarButtonItem?.tintColor = .darkGray
        createSearch()
        createCollection()
        self.createPageControl()
        setConstraints()
        //loadTeams()
        
        let notificationAddedObserver = self.SharedFunduModel.ref.child("users").child(self.SharedFunduModel.myUser.userID).child("teamIDs").observe(.childAdded, with: { (snapshot) in
            self.loadTeams()
        })
    }
    
    func loadTeams(){
//        FunduModel.shared.loadUserTeams(completion: { (userTeams) in
//            self.teams = userTeams
//            UIView.animate(withDuration: 1, animations: { () in
//                self.collection.reloadData()
//                self.pages?.removeFromSuperview()
//                self.createPageControl()
//                
//                let guide = self.view.safeAreaLayoutGuide
//                self.pages.topAnchor.constraintEqualToSystemSpacingBelow(self.collection.bottomAnchor, multiplier: 0.1).isActive = true
//                self.pages.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
//                self.pages.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.01).isActive = true
//                self.pages.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.2).isActive = true
//                self.pages.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
//            })
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchBar.text = ""
        print("view will appear")
//        loadTeams()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func createPageControl() {
        pages = UIPageControl(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.2, height: self.view.bounds.height * 0.1))
        pages.currentPage = 0
        pages.hidesForSinglePage = true
        pages.numberOfPages = 1
        pages.pageIndicatorTintColor = .lightGray
        pages.currentPageIndicatorTintColor = .white
        pages.translatesAutoresizingMaskIntoConstraints = false
        pages.layer.zPosition = 1
        view.addSubview(pages)
    }
    
    func contactPermissionHandler(result:Bool){
//  COMMENTING OUT UNTIL WE HAVE A BETTER WAY TO DO THIS
//        var s = InviteFriendsViewController()
//        let boundsW = self.view.bounds.width * 0.95
//        let boundsH = self.view.bounds.height * 0.4
//        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
//
//        fetchRequest.sortOrder = CNContactSortOrder.userDefault
//
//        var store = CNContactStore()
//        var results = [CNContact]()
//        do {
//            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
//                results.append(contact)
//
//            })
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//        }
        var s = InviteFriendsViewController()
        s.modalPresentationStyle = .overCurrentContext
        var data = [String]()
        let boundsW = self.view.bounds.width * 0.95
        let boundsH = self.view.bounds.height * 0.4
        s.boundsW = boundsW
        s.boundsH = boundsH
        var results = [String:String]()
        self.SharedFunduModel.ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            let json = JSON(snapshot.value)
            for (key, subJson) in json {
                let name = subJson["username"].stringValue
                let id = subJson["userID"].stringValue
                results.updateValue(id, forKey: name)
                data.append(name)
            }
            let sortedData = data.sorted(by: <)
            s.lookup = results
            s.data = sortedData
            s.parentVC = self
            s.startUp()
            self.present(s, animated: true, completion: nil)
        })
    }
    
    @objc func createNewTeam(){
        contactPermissionHandler(result: true)
        //self.requestAccess(completionHandler: self.contactPermissionHandler)
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
    
    @objc func openMessages(){
        //stub
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
        searchController.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        InstantSearch.shared.register(searchController: searchController)
    }
    
    func createCollection(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.view.safeAreaLayoutGuide.layoutFrame.height * 0.99), collectionViewLayout: layout)
        collection.register(FeedViewController.self, forCellWithReuseIdentifier: "Home")
        collection.register(LeagueCompetitionCollectionViewCell.self, forCellWithReuseIdentifier: "Team")
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor(red:0.21, green:0.84, blue:0.72, alpha:1.0)
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        self.view.addSubview(collection)
    }
    
    func setConstraints(){
        let guide = self.view.safeAreaLayoutGuide
        
        collection.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        collection.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        collection.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//        collection.heightAnchor.constraint(equalToConstant: self.view.safeAreaLayoutGuide.layoutFrame.height * 0.9).isActive = true
        
        pages.topAnchor.constraintEqualToSystemSpacingBelow(collection.bottomAnchor, multiplier: 0.1).isActive = true
        pages.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        pages.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.01).isActive = true
        pages.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.2).isActive = true
        pages.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }
    
}

extension DashboardViewController: UICollectionViewDelegate {
    //Stubbed, would put code in here to transition to appropriate screen / take action
}

extension DashboardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  teams.count + 1
    }
    
    //MARK -- Change reuseIdentifier
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath)
        if(indexPath.row == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home", for: indexPath) as! FeedViewController
            cell.nav = self.navigationController
            cell.setupViews()
            cell.backgroundColor = UIColor(red:0.21, green:0.84, blue:0.72, alpha:1.0)
            return cell
        } else {
            //set for leagues when I can
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Team", for: indexPath) as! LeagueCompetitionCollectionViewCell
            cell.nav = self.navigationController
            cell.setupViews(team: teams[indexPath.row-1])
            cell.backgroundColor = UIColor(red:0.21, green:0.84, blue:0.72, alpha:1.0)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

////Size for stat cells
extension  DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.view.safeAreaLayoutGuide.layoutFrame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pages.currentPage = Int(page)
    }
}

extension DashboardViewController : UISearchControllerDelegate {
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
