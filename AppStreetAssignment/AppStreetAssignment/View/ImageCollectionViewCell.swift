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
    
    func fillData(_ photo: Photo){
         self.imageView.loadImage(atURL: photo.thumbnailURL)
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
}
