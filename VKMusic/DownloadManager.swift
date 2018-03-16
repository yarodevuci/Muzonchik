//
//  DownloadManager.swift
//  test
//
//  Created by Yaro on 3/15/18.
//  Copyright © 2018 Yaro. All rights reserved.
//

import Foundation

protocol DownloadManagerDelegate: class {
	func didFinishDownloading(withError error: String?)
	func receivedProgress(_ progress: Float)
}

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    static var shared = DownloadManager()
	
	weak var delegate: DownloadManagerDelegate?
	
	override private init() {
        super.init()
    }

    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
		delegate?.receivedProgress(progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		//Removed import.zip from Doc folder if exist
		do {
			try FileManager.default.removeItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
		} catch {
			print("Unable to remove import.zip, probably because it does not exist..")
		}
		
		do {			
			try FileManager.default.moveItem(at: location, to: DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
			delegate?.didFinishDownloading(withError: nil)
		} catch let error {
			delegate?.didFinishDownloading(withError: error.localizedDescription)
			print(error.localizedDescription)
		}
    }
}

