//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import Foundation

private struct FlickrProviderConstants{
    static let apiKey = "1fb7d9bbf4b72651d53f8f8623bf08bf"
    static let flickrAPIBaseURL = "https://api.flickr.com/services/rest/"
    static let stat = "stat"
    static let ok = "ok"
    static let photos = "photos"
    static let photo = "photo"
    static let id = "id"
    static let farm = "farm"
    static let server = "server"
    static let secret = "secret"
    struct Messages {
        static let searchURLCreationFailed = "Failed to create search URL."
        static let parsingFailed = "Failed to parse result."
    }
}

class FlickrProvider: MainViewControllerProtocol{
    
    func searchPhotos(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int, completion: @escaping ([Photo]?, String?)-> Void){
        guard let flickrSearchURL = searchURL(forSearchString: searchString, pageNumber: pageNumber, andItemsPerPage: itemsPerPage) else{
            completion(nil, FlickrProviderConstants.Messages.searchURLCreationFailed)
            return
        }
        
        NetworkManager.shared.request(withURL: flickrSearchURL, completion:{[weak self] (data, error) in
            if let _ = error {
                completion(nil, error.debugDescription)
            }else{
                if let results = self?.parseFlickrSearchResult(data){
                    completion(results, nil)
                }else{
                    completion(nil, FlickrProviderConstants.Messages.parsingFailed)
                }
            }
        })
    }
    
    private func searchURL(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int) -> URL?{
        
        guard let escapedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else { return nil }
        
        let URLString = "\(FlickrProviderConstants.flickrAPIBaseURL)?method=flickr.photos.search&api_key=\(FlickrProviderConstants.apiKey)&text=\(escapedSearchString)&per_page=\(itemsPerPage)&page=\(pageNumber)&format=json&nojsoncallback=1"
        
        guard let url = URL(string: URLString) else { return nil }
        
        return url
    }
    
    private func parseFlickrSearchResult(_ data: Data?) -> [FlickrPhoto]?{
        guard let data = data else{return nil}
        
        do {
            guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                let stat = resultsDictionary[FlickrProviderConstants.stat] as? String else  {return nil}
            
            if stat == FlickrProviderConstants.ok {
                guard let photosContainer = resultsDictionary[FlickrProviderConstants.photos] as? [String: AnyObject], let photosReceived = photosContainer[FlickrProviderConstants.photo] as? [[String: AnyObject]] else {return nil}
            
            var flickrPhotos = [FlickrPhoto]()
            
            for photoObject in photosReceived {
                guard let photoID = photoObject[FlickrProviderConstants.id] as? String,
                    let farm = photoObject[FlickrProviderConstants.farm] as? Int ,
                    let server = photoObject[FlickrProviderConstants.server] as? String ,
                    let secret = photoObject[FlickrProviderConstants.secret] as? String else { break }
                
                let flickrPhoto = FlickrPhoto(photoID: photoID, server: server, secret: secret, farm: farm)
                
                flickrPhotos.append(flickrPhoto)
            }
                return flickrPhotos
            }
        } catch _ {
            return nil
        }
        return nil
    }
}
