//
//  GlobalFunctions.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/30/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import AVKit

struct AppDirectory {
    static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
    
    fileprivate static let downloadsFolderURL = localDocumentsURL.appendingPathComponent("Downloads")
    static func getDownloadsFolderURL() -> URL {
        if !FileManager.default.fileExists(atPath: downloadsFolderURL.path) {
            try! FileManager.default.createDirectory(atPath: downloadsFolderURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return downloadsFolderURL
    }
}

public func getAlbumImage(fromURL url: URL) -> UIImage {
    
    let playerItem = AVPlayerItem(url: url)
    let metadataList = playerItem.asset.metadata
    
    if metadataList.count > 0 {
        for item in metadataList {
            guard let key = item.commonKey, let value = item.value else { continue }
            
            if key.rawValue == "artwork" {
                if let audioImage = UIImage(data: value as! Data) {
                    print("\nimage Found for url: \(url)\n")
                    return audioImage
                }
            }
        }
    }
    print("\nMetadataList is empty \n")
    return UIImage(named: "ArtPlaceholder")!
}

public func getFileURL(for fileName: String) -> URL {
    return AppDirectory.getDownloadsFolderURL().appendingPathComponent(fileName)
}

class GlobalFunctions {
    
    static let shared = GlobalFunctions()
    
    func urlToHTMLString(url: String, completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let webURL = URL(string: url) else {
            completionHandler(nil, "Invalid URL")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [] in
            do {
                let myHTMLString = try String(contentsOf: webURL, encoding: .utf8)
                completionHandler(myHTMLString, nil)
            } catch let error {
                print("Error: \(error)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    func search(query: String, offset: Int, resultFrom: Int, completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
        let url = URL(string: "https://mp3mob.net/index.php?do=search&subaction=search&story")!
        
        let form_data: [String : Any] = ["do": "search",
                         "search_start": offset,
                         "result_from": resultFrom,
                         "subaction":"search",
                         "story": query]
        
        sendPOSTRequest(url: url, json: form_data) { (html, error) in
            if let html = html {
                completionHandler(html, nil)
            } else {
                completionHandler(nil, error ?? "Error Occured")
            }
        }
        
    }
    
//    func urlToHTMLString(url: String, completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
//        var urlRequest = URLRequest(
//            url: URL_TO_HTML_API,
//            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
//            timeoutInterval: 10.0 * 10)
//
//        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//            let webURL = URL(string: url) else {
//                completionHandler(nil, "Invalid URL")
//                return
//        }
//
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//        urlRequest.addValue(url, forHTTPHeaderField: "url")
//
//        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) -> Void in
//            guard error == nil else {
//                completionHandler(nil, "Error while loading audio")
//                return
//            }
//            guard let data = data else { return }
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
//                    if let errorMessage = json["error"] as? String {
//                        completionHandler(nil, errorMessage)
//                    }
//                    if let statusMessage = json["html"] as? String {
//                        completionHandler(statusMessage, nil)
//                    }
//                }
//            } catch let error {
//                completionHandler(nil, error.localizedDescription)
//                print(error.localizedDescription)
//            }
//        }
//        task.resume()
//    }
    
    func getLocalDownloadedFileURL(url: String, completionHandler: @escaping (_ local_url: String?, _ error: String?) -> ()) {
        var urlRequest = URLRequest(
            url: LOCAL_API_URL_FILEDOWNLOAD,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0 * 10)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(url, forHTTPHeaderField: "url")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandler(nil, "Error while loading audio")
                return
            }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let statusMessage = json["url"] as? String {
                        completionHandler(statusMessage, nil)
                    }
                }
            } catch let error {
                completionHandler(nil, error.localizedDescription)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func getLocalTrack(completionHandler: @escaping (_ audios: [Audio]?, _ error: String?) -> ()) {
        
        var urlRequest = URLRequest(
            url: LOCAL_TRACK_DOWLOAD_URL,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0 * 10)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(YOUTUBE_CONVERTER_API_KEY, forHTTPHeaderField: "api-key")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandler(nil, "Error while loading audio")
                return
            }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let errorMessage = json["error"] as? String {
                        completionHandler(nil, errorMessage)
                    }
                    
                    if let reponseData = json["data"] as? [[String : Any]] {
                        
                        var trackDetails = [Audio]()
                        
                        for data in reponseData {
                            
                            let title = data["title"] as? String ?? "Unknown"
                            let artist = data["artist"] as? String ?? "Unknown"
                            let duration = data["duration"] as? Int ?? 0
                            let url = data["url"] as? String ?? ""
                            let audio = Audio(withThumbnailImage: #imageLiteral(resourceName: "ArtPlaceholder"), url: url, title: title, artist: artist, duration: duration)
                            trackDetails.append(audio)
                        }
                    
                        completionHandler(trackDetails, nil)
                    }
                }
            } catch let error {
                completionHandler(nil, error.localizedDescription)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
	//MARK: - new API
	func convertYouTubeURL(url: String, completionHandler: @escaping (_ status: String?, _ error: String?) -> ()) {
		
		var urlRequest = URLRequest(
			url: YOUTUBE_CONVERTER_API,
			cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
			timeoutInterval: 10.0 * 10)
        
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
		urlRequest.addValue(url, forHTTPHeaderField: "url")
        urlRequest.addValue(YOUTUBE_CONVERTER_API_KEY, forHTTPHeaderField: "api-key")
		
		let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) -> Void in
			guard error == nil else {
				completionHandler(nil, "Error while loading audio")
				return
			}
			guard let data = data else { return }
			
			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
					if let errorMessage = json["error"] as? String {
						completionHandler(nil, errorMessage)
					}
					if let statusMessage = json["status"] as? String {
						completionHandler(statusMessage, nil)
					}
				}
			} catch let error {
				completionHandler(nil, error.localizedDescription)
				print(error.localizedDescription)
			}
		}
		task.resume()
	}
	
    //For volume bar
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func folderSize() -> UInt {
    
        let folderPath = AppDirectory.localDocumentsURL.appendingPathComponent("Downloads")
        
        if !FileManager.default.fileExists(atPath: folderPath.path) { return 0 }
        
        let filesArray: [String] = try! FileManager.default.subpathsOfDirectory(atPath: folderPath.path)
        var fileSize:UInt = 0
        
        for fileName in filesArray {
            let filePath = folderPath.path + "/" + fileName
            let fileDictionary:NSDictionary = try! FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            fileSize += UInt(fileDictionary.fileSize())
        }
        
        return fileSize
    }
    
    func getFriendlyCacheSize() -> String {
        let size = folderSize()
        if size == 0 {
            return "Zero KB"
        }
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
	
	func localFileExistsForTrack(_ audio: Audio) -> Bool {
		let localUrl = AppDirectory.downloadsFolderURL.appendingPathComponent("\(audio.title)_\(audio.artist)_\(audio.duration).mp\(audio.url.last ?? "3")")
		var isDir : ObjCBool = false
		let path = localUrl.path
		return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
	}
    
    fileprivate func sendPOSTRequest(url: URL, json: [String: Any], completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 60.0)
        
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = json.percentEncoded()
       
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let _ = response as? HTTPURLResponse, let data = data {
                
                if let htmlString = String(data: data, encoding: .utf8) {
                    completionHandler(htmlString, nil)
                } else {
                    completionHandler(nil, "Error 500")
                }
            } else {
                print(error?.localizedDescription ?? "Error in \(urlRequest.url!)")
                completionHandler(nil, error?.localizedDescription ?? "Error occured 801")
            }
        }
        task.resume()
    }
}

