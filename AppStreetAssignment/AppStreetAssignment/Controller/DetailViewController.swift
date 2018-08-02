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
        if let _ = photo{
            imageView.loadImage(atURL: photo?.thumbnailURL)
            activityIndicator.startAnimating()
            imageView.loadImage(atURL: photo?.highResPhotoURL, placeHolder: false, completion: {[weak self] in
                self?.activityIndicator.stopAnimating()
            })
        }
        
    }
}
