//
//  ViewController.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/17.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var messages  = [Message]()
    var messagesDictionary = [String : Message]()

//    let sfSymbol_paperplan = UIImage(systemName: "paperplan")
    let sfSymbol_paperplane = UIImage(systemName: "paperplane")

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: sfSymbol_paperplane, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //observeMessages()
    }
    
    func observerUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded ) { (snapshot) in
            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    let message = Message()
                    message.text = dictionary["text"] as? String
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    message.toId = dictionary["toId"] as? String
                    message.fromID = dictionary["fromID"] as? String
                    
                    
                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort { (message1, message2) -> Bool in
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            }
        }
    }

    
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded) { (snapshot, args) in // 속성감시자 같은 느낌이넵~

            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        
        newMessageController.messagesController = self
        
        newMessageController.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: newMessageController)
        //present(navController, animated: true, completion: nil)
        presentInFullScreen(navController, animated: true)
    }
    
    
//    @objc func handleNewMessage() {
//        let newMessageController = NewMessageController()
//        navigationController?.pushViewController(newMessageController, animated: true)
//    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(Database.database().reference().child("users").child(uid))
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot ,error) in
            if error != nil {
                print(error)
            }
            
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
        }
    }
    
    func setupNavBarWithUser(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
        
        observerUserMessage()

        self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.red
        
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        
        if let prifleImageUrl = user.profileImageUrl {
            let tmpString = prifleImageUrl._bridgeToObjectiveC() as String
            profileImageView.loadImageUsingCacheWithUrlString(urlString: tmpString)
        }
        
        let namelabel = UILabel()
        namelabel.text = user.name
        namelabel.translatesAutoresizingMaskIntoConstraints = false
        // need x,y,width,hieght

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.addSubview(containerView)

        containerView.addSubview(profileImageView)
        containerView.addSubview(namelabel)
        
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            namelabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant:  8),
            namelabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            namelabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            namelabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor),
//
            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
//
        ])
        self.navigationItem.titleView = titleView
//        titleView.isUserInteractionEnabled = true
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    @objc func showChatControllerForUser(user : User) {
        print(123)
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        }
        catch let logoutErr {
            print(logoutErr)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        
        present(loginController, animated: true , completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        }
        
        
    }
}



extension MessagesController {
  func presentInFullScreen(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
    viewController.modalPresentationStyle = .fullScreen

    present(viewController, animated: animated, completion: completion)
  }
}
