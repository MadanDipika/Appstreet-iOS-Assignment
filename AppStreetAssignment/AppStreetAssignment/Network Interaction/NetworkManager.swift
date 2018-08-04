//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import Foundation

typealias RequestCompletionHandler = (Data?, Error?) -> Void

class DownloadTask:  URLSessionTask{
    var completionHandler: RequestCompletionHandler
    init(completionHandler: @escaping RequestCompletionHandler) {
        self.completionHandler = completionHandler
    }
}

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    private var session: URLSession? = nil
    private var downloadTasks = [URL: DownloadTask]()
    
    
    private init(){
        session = URLSession(configuration: .default)
    }
    
    func request(withURL url: URL, completion: @escaping RequestCompletionHandler){
        let dataTask = session?.dataTask(with: url, completionHandler: {[weak self] (data, response, error) in
            if self?.isSuccessResponse(response, error) ?? false{
                completion(data, nil)
            }else{
                completion(nil, error)
            }
        })
        dataTask?.resume()
    }
    
    
    func download(fromURL url: URL, completion: @escaping RequestCompletionHandler) {
        if downloadTasks.keys.contains(url){
            let downloadTask = downloadTasks[url]
            downloadTask?.completionHandler = completion
            downloadTask?.priority = URLSessionTask.highPriority
        }else{
            let downloadTask = session?.downloadTask(with: url, completionHandler: {[weak self] (tempLocalUrl, response, error) in
                let completionHandler = self?.downloadTasks[url]?.completionHandler
                if self?.isSuccessResponse(response, error) ?? false, let data = self?.dataFrom(tempLocalUrl){
                    completionHandler?(data, nil)
                }else{
                    completionHandler?(nil, error)
                }
                
                self?.downloadTasks.removeValue(forKey: url)
            })
            let task = DownloadTask(completionHandler: completion)
            downloadTasks[url] = task
            downloadTask?.resume()
        }
    }
    
    private func isSuccessResponse(_ response: URLResponse?,_ error: Error?)-> Bool{
        if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse{
            switch httpResponse.statusCode{
            case 200...202:
                return true
            default:
                return false
            }
        }else{
            return false
        }
    }
    
    private func dataFrom(_ tempLocalUrl: URL?) -> Data!{
        guard let tempLocalUrl = tempLocalUrl else{
            return nil
        }
        
        do{
            let data = try Data(contentsOf: tempLocalUrl)
            return data
        }catch{
            return nil
        }
    }
    func reducePriorityOfTask(withURL url: URL){
        if downloadTasks.keys.contains(url){
            let downloadTask = downloadTasks[url]
            downloadTask?.priority = URLSessionTask.lowPriority
        }
    }
}
