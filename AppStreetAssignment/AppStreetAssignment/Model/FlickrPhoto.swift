//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import Foundation

struct FlickrPhoto: Photo {    
    let photoID : String
    let server : String
    let secret : String
    let farm : Int
    
    var thumbnailURL: URL?{
        get{
            //q size suffix stands for large square 150x150 size image
            if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_q.jpg") {
                return url
            }
            return nil
        }
    }
    
    var highResPhotoURL: URL?{
        get{
            // b size suffix stands for a high resolution photo
            if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_b.jpg") {
                return url
            }
            return nil
        }
    }
}

