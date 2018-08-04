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
    var url: String? = nil
    init(completionHandler: @escaping RequestCompletionHandler, url: String = "abc") {
        self.completionHandler = completionHandler
        self.url = url
    }
    
    func display(){
        print("Task for \(self.url!))")
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
                if self?.isSuccessResponse(response, error) ?? false{
                    do{
                        let data = try Data(contentsOf: tempLocalUrl!)
                        completionHandler?(data, nil)
                    }catch{
                            completionHandler?(nil, nil)
                    }
                }else{
                    completionHandler?(nil, error)
                }
            })
        let task = DownloadTask(completionHandler: completion, url: url.absoluteString)
             downloadTasks[url] = task
            downloadTask?.resume()
            task.display()
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
}
