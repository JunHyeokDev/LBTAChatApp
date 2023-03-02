//
//  ChatLogController.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/21.
//

import UIKit
import Firebase


class ChatLogController : UICollectionViewController, UITextFieldDelegate ,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    var messages = [Message()]
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid , let toId = user?.id else { return } //
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
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
                message.imageUrl = dictionary["imageUrl"] as? String
                
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
        
        setupCell(cell: cell, message: message)
        
        if message.text != nil {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text ?? "I'm nil hehe").width + 20 // for now
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell : ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl   {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
        }
        
        if message.fromID == Auth.auth().currentUser?.uid {
            
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
            
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 32
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect {
     
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
        
        // It just gives additional margin to the collection view cell...
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true // dragable!
        
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //        collectionView.backgroundColor = UIColor.red
        
        collectionView.keyboardDismissMode = .interactive
        
        setupInputComponenets()
        setupKeyboardObservers()
        
    }
    
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // Potential memory leak if we don't remove observer
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    @objc func handleKeyboardWillHide(notification : Notification) {
        guard let durationValue = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: durationValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillShow(notification : Notification) {
        //let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            // use keyboardRect here
            guard let durationValue = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            containerViewBottomAnchor?.constant = -keyboardRect.height + 35
            UIView.animate(withDuration: durationValue) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleUploadTap() {
        print("hello")
        let imagePickerController = UIImagePickerController()
        
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
            
        }
        dismiss(animated: true)
        
    }
    
    private func uploadToFirebaseStorageUsingImage( image : UIImage ) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let imageData = image.jpegData(compressionQuality: 0.1) {
            ref.putData(imageData) { metadata, error in
                if error != nil {
                    return
                }
                ref.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }
                    let imageUrl = downloadURL.absoluteString
                    self.sendMessageWithImageUrl(imageUrl: imageUrl)
                   
                }
                print("Image uploaded successfully")
            }
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let values:[String: Any] = ["imageUrl": imageUrl, "toId": toID!, "fromID": fromID!, "timestamp": timestamp]
        
        childRef.updateChildValues(values) { (errorMsg, ref) in
            if errorMsg != nil {
                print(errorMsg!)
                return
            }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID!).child(toID!)
            print(userMessageRef) // add this line to check if the reference is correct
            
            let messageID = childRef.key!
            userMessageRef.updateChildValues([messageID: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toID!).child(fromID!)
            
            recipientUserMessageRef.updateChildValues([messageID: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        
    }
    
    
    
    func setupInputComponenets() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(systemName: "paperplane")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap) ))
        uploadImageView.isUserInteractionEnabled = true
        
        // w,y,w,h
        NSLayoutConstraint.activate([
            uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            uploadImageView.heightAnchor.constraint(equalToConstant: 36),
            uploadImageView.widthAnchor.constraint(equalToConstant: 36),
        ])
        
        
        view.addSubview(containerView)
        // constraints
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        containerViewBottomAnchor?.isActive = true

        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50),
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
            inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8),
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
                
                let userMessageRef = Database.database().reference().child("user-messages").child(fromID!).child(toID!)
                print(userMessageRef) // add this line to check if the reference is correct
                
                let messageID = childRef.key!
                userMessageRef.updateChildValues([messageID: 1])
                
                let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toID!).child(fromID!)
                
                recipientUserMessageRef.updateChildValues([messageID: 1])
            }
            inputTextField.text = nil
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
