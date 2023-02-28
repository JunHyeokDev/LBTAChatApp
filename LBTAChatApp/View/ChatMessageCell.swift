//
//  ChatMessageCell.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/26.
//

import UIKit

// because unlike UITalbeViewCell.. CollectionView don't have default ..?

class ChatMessageCell: UICollectionViewCell {
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.text = "Sample!"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        return tv
    }()
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        //view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "spiderman")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView) // ADD IT FIRST!!!!!!!!!!!!!!!!!!!!
        addSubview(textView)   //  We need to put it to the VIEW!
        addSubview(profileImageView)
        
        // and then we need constraints // x,y, width, height
        NSLayoutConstraint.activate([
            
            //textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 3),
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,  constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            
            //textView.widthAnchor.constraint(equalToConstant: 200),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3),
            
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //bubbleViewLeftAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            profileImageView.widthAnchor.constraint(equalToConstant: 50), // let's configure it later
            profileImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
