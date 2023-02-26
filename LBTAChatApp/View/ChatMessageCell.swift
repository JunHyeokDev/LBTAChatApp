//
//  ChatMessageCell.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/26.
//

import UIKit

// because unlike UITalbeViewCell.. CollectionView don't have default ..?

class ChatMessageCell: UICollectionViewCell {
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    
    
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
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        //view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView) // ADD IT FIRST!!!!!!!!!!!!!!!!!!!!
        addSubview(textView)   //  We need to put it to the VIEW!
        
        // and then we need constraints // x,y, width, height
        NSLayoutConstraint.activate([
            
            //textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 3),
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,  constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            
            //textView.widthAnchor.constraint(equalToConstant: 200),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3),
            
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
