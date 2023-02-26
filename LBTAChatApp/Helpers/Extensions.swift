//
//  Extensions.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/20.
//

import UIKit


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString : String) {
        
        self.image = nil
        
        // check cache for image first
        let clasString = urlString._bridgeToObjectiveC() as AnyObject
        if let cachedImage = imageCache.object(forKey: clasString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: urlString){
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let data = data {
                    // Process the data here
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data){
                            let tmpString = urlString._bridgeToObjectiveC() as AnyObject
                            imageCache.setObject(downloadedImage, forKey: tmpString)
                            
                        }
                        self.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
    }
    
}

