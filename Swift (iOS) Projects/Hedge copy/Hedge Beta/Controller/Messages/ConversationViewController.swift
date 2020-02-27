import UIKit
import MessageKit
import MapKit
import SwiftyJSON
//import IQKeyboardManagerSwift
import NVActivityIndicatorView

class ConversationViewController: MessagesViewController {
    
    let refreshControl = UIRefreshControl()
    var channelID:String?
    let SharedFunduModel = FunduModel.shared
    var messageList: [Message] = []
    var conversationName: String!
    var avatars: [UIImage] = []
    var isTyping = false
    var activityIndicatorView: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.messagesCollectionView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        self.navigationController?.navigationBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        self.navigationController?.navigationBar.tintColor = .white
        print(conversationName)
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), type: .ballClipRotateMultiple, color: UIColor.black, padding: 100.0)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        //        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(ConversationViewController.self)
        //        let messagesToFetch = 20
        
        //        DispatchQueue.global(qos: .userInitiated).async {
        //            SampleData.shared.getMessages(count: messagesToFetch) { messages in
        //                DispatchQueue.main.async {
        //                    self.messageList = messages
        //                    self.messagesCollectionView.reloadData()
        //                    self.messagesCollectionView.scrollToBottom()
        //                }
        //            }
        
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        //Where tableview is the IBOutlet for your storyboard tableview.
        self.messagesCollectionView.contentInset = adjustForTabbarInsets
        self.messagesCollectionView.scrollIndicatorInsets = adjustForTabbarInsets
        //        }
        
        setObserver()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        //        refreshControl.addTarget(self, action: #selector(ConversationViewController.loadMoreMessages), for: .valueChanged)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "ic_keyboard"),
                            style: .plain,
                            target: self,
                            action: #selector(ConversationViewController.handleKeyboardButton)),
            UIBarButtonItem(image: UIImage(named: "ic_typing"),
                            style: .plain,
                            target: self,
                            action: #selector(ConversationViewController.handleTyping))
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController!.tabBar.isHidden = true
        FunduModel.shared.ref.child("messages").child(self.channelID!).child("users").child(FunduModel.shared.myUser.userID).setValue(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController!.tabBar.isHidden = false
    }
    
    func setObserver() {
        //        FunduModel.ref.child("messages").child(channelID).observe(.childAdded, with: { (snapshot) in
        //            let json = JSON(snapshot.value)
        //
        //        })
        FunduModel.shared.ref.child("messages").child(channelID!).child("messages").observe(.childAdded, with: {(snapshot) in
            let json = JSON(snapshot.value)
            print(snapshot)
            let subJson = json.dictionaryValue
            let messageText = subJson["messageText"]!.stringValue
            let messageId = subJson["messageId"]!.stringValue
            let senderID = subJson["senderID"]!.stringValue
            let senderName = subJson["senderName"]!.stringValue
            let sender = Sender(id: senderID, displayName: senderName)
            var dateString = subJson["sentDate"]!.stringValue
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatterGet.locale = Locale(identifier: "UTC")
            
            if let sentDate = dateFormatterGet.date(from: dateString){
                let message = Message(text: messageText, sender: sender, messageId: messageId, date: sentDate)
                self.messageList.append(message)
                print("NEW MESSAGE: \(messageText)")
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
                self.activityIndicatorView.stopAnimating()
                // messagesCollectionView.insertSections([messageList.count - 1])
                
            }
        })
    }
    
    @objc func handleTyping() {
        
        defer {
            isTyping = !isTyping
        }
        
        if isTyping {
            
            messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
            messageInputBar.topStackViewPadding = .zero
            
        } else {
            
            let label = UILabel()
            label.text = "User is typing..."
            label.font = UIFont.boldSystemFont(ofSize: 16)
            messageInputBar.topStackView.addArrangedSubview(label)
            
            
            messageInputBar.topStackViewPadding.top = 6
            messageInputBar.topStackViewPadding.left = 12
            
            // The backgroundView doesn't include the topStackView. This is so things in the topStackView can have transparent backgrounds if you need it that way or another color all together
            messageInputBar.backgroundColor = messageInputBar.backgroundView.backgroundColor
            
        }
        
    }
    
    //    @objc func loadMoreMessages() {
    //        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 4) {
    //            SampleData.shared.getMessages(count: 10) { messages in
    //                DispatchQueue.main.async {
    //                    self.messageList.insert(contentsOf: messages, at: 0)
    //                    self.messagesCollectionView.reloadDataAndKeepOffset()
    //                    self.refreshControl.endRefreshing()
    //                }
    //            }
    //        }
    //    }
    
    @objc func handleKeyboardButton() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        let actionSheetController = UIAlertController(title: "Change Keyboard Style", message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Slack", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.slack()
                })
            }),
            UIAlertAction(title: "iMessage", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.iMessage()
                })
            }),
            UIAlertAction(title: "Default", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.defaultStyle()
                })
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheetController.addAction($0) }
        actionSheetController.view.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Style
    
    func slack() {
        defaultStyle()
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        let items = [
            makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            },
            makeButton(named: "ic_at").onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                print("@ Selected")
            },
            makeButton(named: "ic_hashtag").onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                print("# Selected")
            },
            .flexibleSpace,
            makeButton(named: "ic_library").onTextViewDidChange { button, textView in
                button.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                button.isEnabled = textView.text.isEmpty
            },
            messageInputBar.sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: true)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .white
                }.onEnabled {
                    $0.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        ]
        items.forEach { $0.tintColor = .lightGray }
        
        // We can change the container insets if we want
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        // Since we moved the send button to the bottom stack lets set the right stack width to 0
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: true)
        
        // Finally set the items
        messageInputBar.setStackViewItems(items, forStack: .bottom, animated: true)
    }
    
    func iMessage() {
        defaultStyle()
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.textViewPadding.right = -38
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    // MARK: - Helpers
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
}

// MARK: - MessagesDataSource

extension ConversationViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: FunduModel.shared.myUser.userID, displayName: FunduModel.shared.myUser.username)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
//        NSAttributedString(string)
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1), NSAttributedStringKey.foregroundColor : UIColor.white])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2), NSAttributedStringKey.foregroundColor : UIColor.white])
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 0/255, green: 118/255, blue: 255/255, alpha: 1) : SharedFunduModel.hedgeMinorTextColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender == currentSender() {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: URL(string: FunduModel.shared.myUser.imageURL)!) {
                    DispatchQueue.main.async {
                        let avatar = Avatar(image: UIImage(data: data)!, initials: String(message.sender.displayName.first!))
                        avatarView.set(avatar: avatar)
                    }
                }
            }
        } else {
            FunduModel.shared.ref.child("users").child(message.sender.id).child("imageURL").observeSingleEvent(of: .value, with: {(snapshot) in
                print("HERE: \(snapshot)")
                if snapshot != nil {
                    let imageURLString = snapshot.value as! String
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let data = try? Data(contentsOf: URL(string: imageURLString )!) {
                            DispatchQueue.main.async {
                                let avatar = Avatar(image: UIImage(data: data)!, initials: String(message.sender.displayName.first!))
                                avatarView.set(avatar: avatar)
                            }
                        }
                    }
                }
            })
        }
        
        
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    // MARK: - Location Messages
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
}


// MARK: - MessageCellDelegate

extension ConversationViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapTopLabel(in cell: MessageCollectionViewCell) {
        print("Top label tapped")
    }
    
    func didTapBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ConversationViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String : String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ConversationViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                //                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                //                messageList.append(imageMessage)
                //                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                
                //                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                // date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.locale = Locale(identifier: "UTC")
                let stringDate = formatter.string(from: message.sentDate)
                
                let messageItem = [
                    "senderID": FunduModel.shared.myUser.userID,
                    "senderName": FunduModel.shared.myUser.username,
                    "messageText": message.text,
                    "messageId": message.messageId,
                    "sentDate": stringDate,
                    "timestamp": NSNumber(value: NSDate().timeIntervalSince1970)
                    ] as [String : Any]
                
                FunduModel.shared.ref.child("messages").child(channelID!).child("messages").childByAutoId().setValue(messageItem)
                
                //                messageList.append(message)
                //                messagesCollectionView.insertSections([messageList.count - 1])
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
}
