//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import Foundation

typealias DataRequestCompletionHandler = (Data?, Error?) -> Void
class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    var foregroundSession: URLSession? = nil
    
    private init(){
        foregroundSession = URLSession(configuration: .default)
    }
    
    func request(withURL url: URL, completion: @escaping DataRequestCompletionHandler){
        let dataTask = foregroundSession?.dataTask(with: url, completionHandler: { (data, response, error) in
            if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse{
                switch httpResponse.statusCode{
                case 200...202:
                    completion(data, nil)
                    break
                default:
                    completion(nil, nil)
                    break
                }
            }else{
                completion(nil, error)
            }
        })
        dataTask?.resume()
    }
    
    
    func download(fromURL url: URL, completion: @escaping DataRequestCompletionHandler) {
        let downloadTask = foregroundSession?.downloadTask(with: url, completionHandler: { (tempLocalUrl, response, error) in
            if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse{
                switch httpResponse.statusCode{
                case 200...202:
                    do{
                    let data = try Data(contentsOf: tempLocalUrl!)
                    completion(data, nil)
                    }catch{
                        completion(nil, nil)
                    }
                    break
                default:
                    completion(nil, nil)
                    break
                }
            }else{
                    completion(nil, nil)
            }
        })
        
        downloadTask?.resume()
    }
}
