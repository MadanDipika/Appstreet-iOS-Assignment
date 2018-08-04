//
//  DetailViewController.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/29/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController{
    var photo: Photo? = nil
    @IBOutlet weak var imageView: CachedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.activityIndicator.stopAnimating()
        
        if let _ = photo, let highResPhotoURL = photo?.highResPhotoURL{
            if CacheManager.shared.isImageCached(for: highResPhotoURL.absoluteString){
                imageView.loadImage(atURL: highResPhotoURL)
            } else if let thumbnailURL = photo?.thumbnailURL{
                imageView.loadImage(atURL: thumbnailURL)
                activityIndicator.startAnimating()
                imageView.loadImage(atURL: highResPhotoURL, placeHolder: false, completion: {[weak self] in
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                    }
                })
            }
        }
    }
}
extension DetailViewController: ZoomingViewController{
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return self.imageView
    }
}
