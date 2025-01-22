//
//  DownloadServices.swift
//  Runner
//
//  Created by Abdallah Omer on 18/01/2023.
//

import Foundation
import Alamofire

class DownloadServices {
    
    static var downloadsList:[String:DownloadRequest] = [:]
    
    static func download(fileURLString: String, destinationPath: String, fileName: String, completionHandler: @escaping (URL?, URL?, Error?, Int?) -> ()) {
        guard let fileURL = URL(string: fileURLString),
              let destinationURL = destinationPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let fileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let destinationPath = URL(string: "file://" + destinationURL + fileName) else { return }
        let destination: DownloadRequest.Destination = { _, _ in
            return (destinationPath, [.removePreviousFile, .createIntermediateDirectories])
        }
        cancelDownload(fileURLString)
        var urlRequest = URLRequest(url: fileURL)
        urlRequest.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        let downloadRequest = AF.download(urlRequest, to: destination).response { response in
            switch response.result {
            case .success(let url):
                guard let url = url else { return }
                downloadsList.removeValue(forKey: fileURLString)
                completionHandler(url, fileURL, nil, nil)
            case .failure(let error):
                downloadsList.removeValue(forKey: fileURLString)
                completionHandler(nil, fileURL, error, nil)
            }
        }.downloadProgress { progress in
            completionHandler(nil, fileURL, nil, Int(progress.fractionCompleted * 100))
        }
        
        downloadsList[fileURLString] = downloadRequest
    }
    
    static func cancelDownload(_ fileURLString: String) {
        downloadsList[fileURLString]?.cancel()
    }
    
    
    static func cancelAllDownload() {
        AF.cancelAllRequests()
    }
}
