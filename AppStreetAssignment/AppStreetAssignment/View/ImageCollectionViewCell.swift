//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var imageView: CachedImageView!
    var photo: Photo? = nil
    
    func fillData(_ data: Photo?){
        photo = data
        guard let photo = photo, let thumbnailURL = photo.thumbnailURL else {
            return
        }
        self.imageView.loadImage(atURL: thumbnailURL)
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func reducePriorityOfDownloadtaskForCell(){
        guard let photo = photo, let thumbnailURL = photo.thumbnailURL else {
            return
        }
        NetworkManager.shared.reducePriorityOfTask(withURL: thumbnailURL)
    }
}
