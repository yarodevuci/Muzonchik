//
//  SessionDelegate.swift
//  test
//
//  Created by Yaro on 3/15/18.
//  Copyright © 2018 Yaro. All rights reserved.
//

import Foundation

@objc protocol UploadManagerDelegage: class {
	func didReceiveResponseJSON(_ json: [String: Any])
	func progress(progress: Float)
}

class UploadManager: NSObject, URLSessionDataDelegate {
	
    static let shared = UploadManager()
	weak var delegate: UploadManagerDelegage?
    
	func uploadZipFile() {
        var urlRequest = URLRequest(url: UPLOAD_ZIP_FILE_URL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
		let session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "uploadTask"), delegate: self, delegateQueue: OperationQueue.main)
        let task = session.uploadTask(with: urlRequest, fromFile: DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
		task.resume()
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
		delegate?.progress(progress: uploadProgress)
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		completionHandler(.allow)
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		do {
			if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
				//print(json)
				delegate?.didReceiveResponseJSON(json)
			}
		} catch {
			print("error")
		}
	}
}
