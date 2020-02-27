import UIKit
import AlgoliaSearch
import InstantSearch
import NVActivityIndicatorView

class SearchResultsViewController: MultiHitsTableViewController {
    var nav:UINavigationController!
    var data:[[AnyObject]]!
    var tableView:UITableView!
    var timesCalled = 0
    var activityIndicatorView: NVActivityIndicatorView!
    let SharedFunduModel = FunduModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTable()
        InstantSearch.shared.registerAllWidgets(in: self.view)
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
    
    func createTable(){
        let barHeight = UIApplication.shared.statusBarFrame.size.height
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height
        
        hitsTableView = MultiHitsTableWidget()
        //hitsTableView.indicesArray = ["companies", "users", "teams", "leagues"]
        hitsTableView.indicesArray = ["companies"]
        hitsTableView.frame = CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight)
        hitsTableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        hitsTableView.rowHeight = UITableViewAutomaticDimension
        hitsTableView.estimatedRowHeight = 100
        hitsTableView.translatesAutoresizingMaskIntoConstraints = false
        hitsTableView.backgroundColor = SharedFunduModel.hedgePrimaryColor
        hitsTableView.hitsPerSection = "5,5,5,5"
        hitsTableView.showItemsOnEmptyQuery = false
        hitsTableView.tableFooterView = UIView(frame: .zero)
        hitsTableView.keyboardDismissMode = .onDrag
        hitsTableView.separatorStyle = .none
        self.view.addSubview(hitsTableView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, containing hit: [String : Any]) {
        switch indexPath.section {
        case 0:
            print("in company case")
            let companyVC = CompanyPageViewController()
            companyVC.nav = nav
            companyVC.ticker = hit["Symbol"] as! String
            self.dismissKeyboard()
            self.loadingAnimation()
            FunduModel.shared.checkOwnership(ticker: hit["Symbol"] as! String, completion: { (userTeams, isOwned) in
                companyVC.owned = isOwned
                companyVC.userTeams = userTeams
                var numShares = 0
                if isOwned {
                    var numShares = 0
                    for team in userTeams {
                        numShares = numShares + team.stockQuantity
                    }
                    companyVC.sharesOwned = numShares
                }
                self.activityIndicatorView.stopAnimating()
                self.nav.pushViewController(companyVC, animated: true)
                self.dismiss(animated: true, completion: nil)
            })
//        case 1:
//            print("to user page")
//        case 2:
//            let teamVC = TeamPageViewController()
//            teamVC.teamName = hit["teamName"] as! String
//            self.dismissKeyboard()
//            self.navigationController?.pushViewController(teamVC, animated: true)
        default:
            print("satisfy compiler")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing hit: [String : Any]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        print(timesCalled)
        timesCalled = 1 + timesCalled
        switch indexPath.section {
        case 0 :
            var companyUrl:String = hit["url"] as! String
            //print("https://logo.clearbit.com/" + String(companyUrl[companyUrl.index(companyUrl.startIndex, offsetBy: 11)...]))
            cell.setupViews(text: hit["Name"] as! String, image: "company1", isCompany: true, ticker: hit["Symbol"] as! String, url: "https://logo.clearbit.com/" + String(companyUrl[companyUrl.index(companyUrl.startIndex, offsetBy: 11)...]), placeholder: "placeholder-logo")
//        case 1 :
//            let userImage:String = hit["profilePic"] != nil ? hit["profilePic"] as! String : "default-profile"
//            if (cell.viewWithTag(1) != nil) {
//                cell.updateViews(text: hit["username"] as! String, image: userImage, isCompany: false, ticker: "", url: "", placeholder: "default-profile")
//            } else {
//                cell.setupViews(text: hit["username"] as! String, image: userImage, isCompany: false, ticker: "", url: "", placeholder: "default-profile")
//            }
//        case 2 :
//            let teamImage:String = hit["teamPic"] != nil ? hit["teamPic"] as! String : "default-team"
//            if (cell.viewWithTag(1) != nil) {
//                cell.updateViews(text: hit["teamName"] as! String, image: teamImage, isCompany: false, ticker: "", url: "", placeholder: "default-team")
//            } else {
//                cell.setupViews(text: hit["teamName"] as! String, image: teamImage, isCompany: false, ticker: "", url: "", placeholder: "default-team")
//            }
//        case 3 :
//            let leagueImage:String = hit["leaguePic"] != nil ? hit["leaguePic"] as! String : "default-league"
//            if (cell.viewWithTag(1) != nil) {
//                cell.updateViews(text: hit["leagueName"] as! String, image: leagueImage, isCompany: true, ticker: "", url: "", placeholder: "default-league")
//            } else {
//                cell.setupViews(text: hit["leagueName"] as! String, image: leagueImage, isCompany: true, ticker: "", url: "", placeholder: "default-league")
//            }
        default :
            cell.setupViews(text: hit["Username"] as! String, image: "company1", isCompany: false, ticker: "", url: "", placeholder: "")
        }
        cell.backgroundColor = FunduModel.shared.hedgePrimaryColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 300, height: 30))
        label.textColor = UIColor.white
        if hitsTableView.dataSource?.tableView(hitsTableView, numberOfRowsInSection: section) == 0{
            let view = UIView()
            view.backgroundColor = FunduModel.shared.hedgePrimaryColor
            return view
        }
        
        switch section {
        case 0 :
            label.text = "Companies"
//        case 1 :
//            label.text = "Users"
//        case 2 :
//            label.text = "Teams"
//        case 3 :
//            label.text = "Leagues"
        default :
            label.text = ""
        }
        
        let view = UIView()
        view.addSubview(label)
        view.backgroundColor = FunduModel.shared.hedgePrimaryColor
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
