//
//  HelperFunctions.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation
import RealmSwift

extension TrackListTableVC {
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
    }
    
    func getLocalDownloadsURL() -> URL {
        return DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        if !directoryExistsAtPath(getLocalDownloadsURL().path) {
            do {
                try FileManager.default.createDirectory(at: getLocalDownloadsURL(), withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError { print(error.localizedDescription) }
        }
        return getLocalDownloadsURL().appendingPathComponent(((activeDownloads[previewUrl]?.fileName) ?? previewUrl))
    }
    
    // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
    func localFileExistsForTrack(_ track: Audio) -> Bool {
        if let localUrl = localFilePathForUrl("\(track.title)_\(track.artist).mp3") {
            var isDir : ObjCBool = false
            let path = localUrl.path
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        }
        return false
    }
    
    func trackIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for (index, track) in audioFiles.enumerated() {
                if url == track.url { return index }
            }
        }
        return nil
    }
	
	func deleteFileFromRealm(url: String) {
        let realm = try! Realm()
        try! realm.write {
            let trackToDelete = realm.objects(SavedAudio.self).filter("url == %@", url)
            realm.delete(trackToDelete)
        }
	}
	
	func deleteSong(_ row: Int) {
		let track = audioFiles[row]
		if localFileExistsForTrack(track) {
            let filePath = getLocalDownloadsURL().appendingPathComponent("\(track.title)_\(track.artist).mp3")
			do {
				try FileManager.default.removeItem(at: filePath)
				if AudioPlayer.defaultPlayer.currentAudio != nil && AudioPlayer.defaultPlayer.currentAudio == track {
					AudioPlayer.defaultPlayer.kill()
					self.navigationController?.dismissPopupBar(animated: true, completion: nil)
				}
				//Delete From Realm
                deleteFileFromRealm(url: track.url)
				currentSelectedIndex = -1
				audioFiles.remove(at: row)
				tableView.reloadData()
				SwiftNotificationBanner.presentNotification("Deleted")
			} catch let error as NSError {
				print(error.debugDescription)
				DispatchQueue.main.async {
					SwiftNotificationBanner.presentNotification(error.localizedDescription)
				}
			}
		}
	}
}