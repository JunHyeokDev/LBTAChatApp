//
//  ChatLogController.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/21.
//

import UIKit
import Firebase


class ChatLogController : UICollectionViewController, UITextFieldDelegate ,UICollectionViewDelegateFlowLayout{
    
    var messages = [Message()]
    
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return } //
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key // just get that key !
            //            Snap (-NP6Mq3vjAawUKUCZO1y) 1 || ==> NP6Mq3vjAawUKUCZO1y 이거 갖고옴 ㅎㅎ
            //            Snap (-NP6T6y-7aiwLauWDD3g) 1 || ==> NP6T6y-7aiwLauWDD3g 이거 갖고옴
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                
                let message = Message()
                // Potential of crashing if keys don't match!
                // message.setValuesForkeys(dictionary)
                // 위에걸로 하면 자꾸 키-밸류가 안맞는다고 에러가 뜨네... 일단 하나씩 집어넣어주자..
                
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                message.fromID = dictionary["fromID"] as? String
                
                
                // id를 체크해서 나한테 보낸 메시지만 볼 수 있게 해야함
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            }
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    let cellId = "cellId"
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        //        cell.backgroundColor = .blue
        
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text ?? "I'm nil hehe").width + 20 // for now
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 32
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect {
        //
        //        let size = CGSize(width: 200, height: 100)
        //        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        //        return NSString(string: text).boundingRect(with: size, context: nil)
        
        let size = CGSize(width: 200, height: 100)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    lazy var inputTextField : UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Enter message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true // dragable!
        
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //        collectionView.backgroundColor = UIColor.red
        setupInputComponenets()
    }
    
    
    
    func setupInputComponenets() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        // constraints
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor),
        ])
        
        
        containerView.addSubview(inputTextField)
        
        
        
        // x,y,w,h
        NSLayoutConstraint.activate([
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.black
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        NSLayoutConstraint.activate([
            separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
        
    }
    
    @objc func handleSend() {
        
        
        //        let ref = Database.database().reference().child("messages")
        //        let childRef = ref.childByAutoId()
        //
        //
        //        // How can we allocate it automatically? like magically?
        //        let toId = user?.id
        //        let fromId = Auth.auth().currentUser!.uid
        //        let tmp = NSDate()
        //        let timestamp : NSNumber = Int(tmp.timeIntervalSince1970) as NSNumber
        //
        //
        //        let values = ["text" : inputTextField.text!, "toId" : String(toId!), "fromId" : String(fromId), "timestamp" : timestamp] as [String : AnyObject]
        //
        //
        //        childRef.updateChildValues(values) { (error, ref) in
        //            if error != nil {
        //                print(error)
        //                return
        //            }
        //            let messageId = childRef.key
        //
        //            let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
        //            userMessageRef.updateChildValues([messageId : 1])
        //
        //            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId!)
        //            recipientUserMessageRef.updateChildValues([messageId : 1])
        //        }
        if inputTextField.text != nil && !(inputTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            let text = inputTextField.text
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toID = user?.id
            let fromID = Auth.auth().currentUser?.uid
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let values:[String: Any] = ["text":text!, "toId": toID!, "fromID": fromID!, "timestamp": timestamp]
            
            childRef.updateChildValues(values) { (errorMsg, ref) in
                if errorMsg != nil {
                    print(errorMsg!)
                    return
                }
                
                let userMessageRef = Database.database().reference().child("user-messages").child(fromID!)
                print(userMessageRef) // add this line to check if the reference is correct
                
                
                
                let messageID = childRef.key!
                userMessageRef.updateChildValues([messageID: 1])
                
                let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toID!)
                
                recipientUserMessageRef.updateChildValues([messageID: 1])
            }
            inputTextField.text = nil
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
    
}
