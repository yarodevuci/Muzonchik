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
	
	var urlRequest: URLRequest!
	var data: Data!
	weak var delegate: UploadManagerDelegage?
	
	init(uploadTaskDataFromURL data_url: URL) {
		self.data = try! Data(contentsOf: data_url)
		let api_url = URL(string: "http://169.234.206.29:8080/upload/import.zip")
		self.urlRequest = URLRequest(url: api_url!)
		self.urlRequest.httpMethod = "POST"
		self.urlRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
		self.urlRequest.httpBodyStream = InputStream(data: data)
	}
	
	func uploadFiles() {
		let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
		let task = session.uploadTask(with: urlRequest, from: data)
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
