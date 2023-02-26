//
//  NewMessageController.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/18.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    var messagesController : MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot,arg  in
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user = User()
                // if you use this setter, your app will carsh if ur class properties don't exactly match up wtih the firebase dictionary keys
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                // this will crash because of background thread, so lets use dispatchqueue.main!
                // self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
            
        }
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("when I click each row, something happens!")
            print("So let's dismiss this VC and get the new one!")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        cell.textLabel?.text = user.name
        cell.secondaryLabel.text = user.email
        //cell.imageView?.image = UIImage(named: "spiderman")
        cell.imageView?.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
}


