//
//  UserCell.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/24.
//

import UIKit
import Firebase
class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            //
            setUpNameAndProfileImage()
            detailTextLabel?.text = message?.text
            
            if let sconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970:sconds)
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormater.string(from: timestampDate as Date)
            }
            secondaryLabel.text = message?.text
        }
    }
    
    private func setUpNameAndProfileImage() {
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String

                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            }
        }
    }
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spiderman")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        
        return label
        
    }()
    
    let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Secondary text"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRectMake(100, textLabel!.frame.origin.y - 15, textLabel!.frame.width, textLabel!.frame.height)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(secondaryLabel)
        addSubview(timeLabel)
        // ios 9 constraint anchors ?
        // x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // need x,y,width,height for timestamp
        NSLayoutConstraint.activate([
            timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 20),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            //            secondaryLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            //            secondaryLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            //            secondaryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            //            secondaryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            secondaryLabel.widthAnchor.constraint(equalToConstant: 150),
            secondaryLabel.heightAnchor.constraint(equalToConstant: 10),
            secondaryLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            secondaryLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 15)
        ])
        
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
