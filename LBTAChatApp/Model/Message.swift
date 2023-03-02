//
//  Message.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/23.
//

import UIKit
import Firebase


class Message: NSObject {
    
    var fromID : String?
    var text : String?
    var timestamp : NSNumber?
    var toId : String?
    
    var imageUrl: String?
    
    func chatPartnerId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toId : fromID
    }
}
