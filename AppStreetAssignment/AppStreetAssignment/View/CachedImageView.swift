//
//  CachedImageView.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/29/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit
class CachedImageView: UIImageView {
    
    private static let imageCache = NSCache<NSString, UIImage>()
    private var urlKey: String! = nil
    
    func loadImage(atURL url: URL?, placeHolder: Bool = true, completion: (()-> Void)? = nil){
        guard let url = url else{
            if placeHolder {
                self.image = UIImage(named: "placeHolder")
            }
            completion?()
            return
        }
        
        self.urlKey = url.absoluteString
        if let cachedImage = CachedImageView.imageCache.object(forKey: self.urlKey as NSString){
            completion?()
            self.image = cachedImage
            return
        }else{
            if placeHolder {
                self.image = UIImage(named: "placeHolder")
            }
            
            NetworkManager.shared.download(fromURL: url) {[weak self, url] (data, error) in
                guard error == nil, let data = data else{
                    completion?()
                    return
                }
                
                if let image = UIImage(data: data){
                    //Cache image for future use
                    CachedImageView.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    DispatchQueue.main.async {
                        completion?()
                        if url.absoluteString == self?.urlKey{
                            self?.image = image
                        }
                    }
                }else{
                    completion?()
                }
            }
        }
    }
}
