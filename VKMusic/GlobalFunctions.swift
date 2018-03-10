//
//  GlobalFunctions.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/30/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import Foundation
import UIKit

class GlobalFunctions {
    
    static let shared = GlobalFunctions()
    
    func urlToHTMLString(url: String, completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let webURL = URL(string: url) else {
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
    
    func processYouTubeURL(url: String, completionHandler: @escaping (_ audio: Audio?, _ error: String?) -> ()) {
        let parameters = ["url": url]
        let url = URL(string: "https://youtubemusic.gogokhiya.com/api/v1/music")!
        //create the session object
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.timeoutInterval = 99999
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error { print(error.localizedDescription) }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    let mp4url = json["url"] as? String ?? ""
                    if mp4url.isEmpty {
                        completionHandler(nil, "Server ERROR")
                    } else {
                        let name = json["name"] as? String ?? ""
                        let durationSeconds = json["duration"] as? Int ?? 0
                        let parsedName = name.replacingOccurrences(of: ".mp4", with: "")
                        //let durationSeconds = ((8 * size) / (Int(bitrate) ?? 0)) + 1
                        let audio = Audio(url: mp4url, title: "YouTube", artist: parsedName, duration: durationSeconds - 1)
                        completionHandler(audio, nil)
                    }
                }
            } catch let error {
                completionHandler(nil, error.localizedDescription)
                print(error.localizedDescription)
            }
        })
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
    
        let folderPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            return 0
        }
        
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
		let localUrl = DocumentsDirectory.localDownloadsURL.appendingPathComponent("\(audio.title)_\(audio.artist).mp\(audio.url.last ?? "3")")
		var isDir : ObjCBool = false
		let path = localUrl.path
		return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
	}
	
	//Send local notification
	func fireLocalNotification(withMessage msg: String) {
		let notification = UILocalNotification()
		notification.fireDate = Date()
		notification.alertBody = msg
		DispatchQueue.main.async {
			UIApplication.shared.scheduleLocalNotification(notification)
		}
	}
}

