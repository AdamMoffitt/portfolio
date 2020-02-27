import UIKit
import SCLAlertView

class FeedCollectionTableViewCell: UITableViewCell {
    var collectionOfStats: [UserNotification]!
    var collection: UICollectionView!
    let SharedFunduModel = FunduModel.shared
    var delegate: FeedCollectionViewDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        collection.removeFromSuperview()
    }
    
    func createCollection(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView(frame: contentView.bounds, collectionViewLayout: layout)
        collection.backgroundColor = FunduModel.shared.hedgePrimaryColor
        collection.register(DashboardCollectionViewCell.self, forCellWithReuseIdentifier: "UserNotification")
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collection)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        collection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collection.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        collection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func setupViews(stats:[UserNotification]){
        //contentView.backgroundColor = UIColor.gray
        collectionOfStats = stats
        createCollection()
        setConstraints()
    }
}

extension FeedCollectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let cell : DashboardCollectionViewCell = (collectionView.cellForItem(at: indexPath as IndexPath)! as? DashboardCollectionViewCell)!
        
        if cell.info.type == "invite" {
            let appearance = SCLAlertView.SCLAppearance (
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Join team") {
                if cell.teamID != nil {
                    self.SharedFunduModel.addUserToTeam(userID: self.SharedFunduModel.myUser.userID, teamID: cell.teamID)
                    self.SharedFunduModel.addteamIDToUser(userID: self.SharedFunduModel.myUser.userID, teamID: cell.teamID, teamName: cell.teamName)
                }
//                self.SharedFunduModel.removeNotification(notificationID: cell.info.key)
                if indexPath.row < self.collectionOfStats.count {
                    self.collectionOfStats.remove(at: indexPath.row)
                    collectionView.deleteItems(at: [indexPath])
                }
            }
            alert.addButton("Dismiss") {
//                self.SharedFunduModel.removeNotification(notificationID: cell.info.key)
                if indexPath.row < self.collectionOfStats.count {
                    self.collectionOfStats.remove(at: indexPath.row)
                    collectionView.deleteItems(at: [indexPath])
                }
            }
            alert.showInfo("Accept team invitation?", subTitle: "")
        } else {
//            self.SharedFunduModel.removeNotification(notificationID: cell.info.key)
            if indexPath.row < collectionOfStats.count {
                collectionOfStats.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
        }
        if collectionOfStats.isEmpty {         delegate?.refreshTableView() }
    }
}

extension FeedCollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionOfStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserNotification", for: indexPath) as! DashboardCollectionViewCell
        cell.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        cell.setupViews(data:collectionOfStats[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

//Size for stat cells
extension  FeedCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: contentView.bounds.width * 0.4, height: contentView.bounds.height)
    }
}
