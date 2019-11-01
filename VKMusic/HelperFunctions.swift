//
//  HelperFunctions.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

extension TrackListTableVC {
    
    // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
    func localFileExistsForTrack(_ track: Audio) -> Bool {
        
        var audioURL = ""
        if track.url.hasSuffix(".mp3") || track.url.hasSuffix(".mp4") {
            audioURL = track.url
        } else { //MAILRU IS MISSING .mp3 extension, adding it manually to avoid bugs
            audioURL = track.url + ".mp3"
        }
        let fileURL = getFileURL(for: "\(track.title)_\(track.artist)_\(track.duration).mp\(audioURL.hasSuffix(".mp3") ? "3" : "4")")
        
        var isDir: ObjCBool = false
        let path = fileURL.path
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    func trackIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for (index, track) in audioFiles.enumerated() {
                if url == track.url { return index }
            }
        }
        return nil
    }
		
	func deleteSong(_ row: Int) {
		let track = audioFiles[row]
        
		if localFileExistsForTrack(track) {
            
			do {
                try FileManager.default.removeItem(at: getFileURL(for: "\(track.title)_\(track.artist)_\(track.duration).mp\(track.url.last ?? "3")"))
                
				//Delete From Realm
				CoreDataManager.shared.deleteAudioFile(withID: track.id)
                audioFiles.remove(at: row)
                
                if AudioPlayer.defaultPlayer.currentAudio != nil {
                    /// Find new index for playing audio
                    for (index, track) in audioFiles.enumerated() {
                        if track == AudioPlayer.defaultPlayer.currentAudio {
                            currentSelectedIndex = index
                            break
                        }
                    }
                }
                
                tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                
                if AudioPlayer.defaultPlayer.currentAudio != nil && AudioPlayer.defaultPlayer.currentAudio.duration == track.duration {
                    AudioPlayer.defaultPlayer.kill()
                    currentSelectedIndex = -1
                    self.navigationController?.setToolbarHidden(true, animated: true)
                    self.navigationController?.dismissPopupBar(animated: true, completion: nil)
                    
                } 
                
				SwiftNotificationBanner.presentNotification("Deleted")
			} catch let error as NSError {
				print(error.debugDescription)
				SwiftNotificationBanner.presentNotification(error.localizedDescription)
			}
		}
	}
	
	func showActivityIndicator(withStatus status: String) {
		toolBarStatusLabel.text = status
		activityIndicator.startAnimating()
		navigationController?.setToolbarHidden(false, animated: true)
	}
	
	func hideActivityIndicator() {
		DispatchQueue.main.async {
            self.toolBarStatusLabel.text = ""
			self.activityIndicator.stopAnimating()
            
            let isPopupHidden = self.navigationController?.popupBar.isHidden ?? true
            
            self.navigationController?.setToolbarHidden(isPopupHidden, animated: true)
		}
	}
}
