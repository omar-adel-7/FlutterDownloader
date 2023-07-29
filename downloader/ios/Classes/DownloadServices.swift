//
//  DownloadServices.swift
//  Runner
//
//  Created by Abdallah Omer on 18/01/2023.
//

import Foundation
import Alamofire

class DownloadServices {
    static func download(fileURLString: String, destinationPath: String, fileName: String, completionHandler: @escaping (URL?, URL?, Error?, Int?) -> ()) {
       guard let fileURL = URL(string: fileURLString),
              let destinationURL = destinationPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let destinationPath = URL(string: "file://" + destinationURL + fileName) else { return }
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (destinationPath, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(fileURL, to: destination).response { response in
            switch response.result {
            case .success(let url):
                guard let url = url else { return }
                completionHandler(url, fileURL, nil, nil)
            case .failure(let error):
                completionHandler(nil, fileURL, error, nil)
            }
        }.downloadProgress { progress in
            completionHandler(nil, fileURL, nil, Int(progress.fractionCompleted * 100))
        }
    }
    
    static func cancelDownloading() {
        AF.cancelAllRequests()
    }
}
