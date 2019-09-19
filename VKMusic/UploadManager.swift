//
//  SessionDelegate.swift
//  test
//
//  Created by Yaro on 3/15/18.
//  Copyright © 2018 Yaro. All rights reserved.
//

extension Data{
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

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
        let boundary = UUID().uuidString
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let paramName = "file"
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(paramName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: file/zip\r\n\r\n".data(using: .utf8)!)
    
        data.append(try! Data(contentsOf: AppDirectory.localDocumentsURL.appendingPathComponent("import.zip")))
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        urlRequest.httpBody = data
    
		let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
//        let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { (data, response, error) in
//            print(data)
//            print(response)
//
//        }
        
        let task = session.uploadTask(with: urlRequest, from: data)
            
            //session.uploadTask(with: urlRequest, fromFile: AppDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
        
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
		} catch let error {
            delegate?.didReceiveResponseJSON(["error": error.localizedDescription])
			print("error occured in UploadManager \(error.localizedDescription)")
		}
	}
}
