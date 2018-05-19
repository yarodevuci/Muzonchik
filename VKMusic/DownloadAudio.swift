//
//  DownloadAudio.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

extension TrackListTableVC: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if let originalURL = downloadTask.originalRequest?.url?.absoluteString,
            let destinationURL = localFilePathForUrl(originalURL) {
            let fileManager = FileManager.default
			// Do this just in case if same file name is already exist. 
			do { try fileManager.removeItem(at: destinationURL) }
			catch let error as Error { //FILE PROBABLY DOES NOT EXIST:
//                print("ERROR REMOVING TEMP FILE: \(error.localizedDescription)")
            }
            self.hideActivityIndicator()
            
            do {
                try fileManager.moveItem(at: location, to: destinationURL)
				if let currentDownload = self.activeDownloads[originalURL] {
					CoreDataManager.shared.saveToCoreData(audio: Audio(withThumbnailImage: currentDownload.thumbnailImage, url: destinationURL.absoluteString, title: currentDownload.title, artist: currentDownload.artist, duration: currentDownload.duration))
                    
					DispatchQueue.main.async {
						SwiftNotificationBanner.presentNotification("\(currentDownload.songName)\nDownload complete")
						self.activeDownloads[downloadTask.originalRequest?.url?.absoluteString ?? ""] = nil
						self.tableView.reloadData()
					}
				}
            } catch let error as Error {
				DispatchQueue.main.async {
                    print("ERROR: \(error.localizedDescription)")
                    if self.activeDownloads[originalURL] != nil {
                        SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\n\(error.localizedDescription)")
                        self.activeDownloads[downloadTask.originalRequest?.url?.absoluteString ?? ""] = nil
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            print(download.progress)
            
            DispatchQueue.main.async {
                
                self.toolBarStatusLabel.text = "Downloading \(String(format: "%.1f%%",  download.progress * 100))"

                
                if let trackIndex = self.trackIndexForDownloadTask(downloadTask),
                    let trackCell = self.tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? TrackListTableViewCell {
                    trackCell.downloadProgressView.progress = download.progress
                    let bitRate = String(Int(totalBytesExpectedToWrite) * 8 / 1000 / download.duration)
                    trackCell.downloadProgressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize) + " \(bitRate) kbps"
                }
            }
        }
    }
    
    func startDownload(_ track: Audio) {

        if track.url.isEmpty {
            SwiftNotificationBanner.presentNotification("Unable to download. No url")
            return
        }
        downloadFile(fromURL: track.url, track: track)
    }
    
    func downloadFile(fromURL urlString: String, track: Audio) {
        
        let download = Download(url: urlString)
        download.downloadTask = self.downloadsSession.downloadTask(with: URL(string: urlString)!)
        download.downloadTask!.resume()
        download.isDownloading = true
        
        var trackURLString = track.url
        if !track.url.hasSuffix(".mp4") {
            trackURLString += ".mp3"
        }
        
        download.fileName = "\(track.title)_\(track.artist)_\(track.duration).mp\(trackURLString.hasSuffix(".mp3") ? "3" : "4")"
        download.songName = track.title
        
        //Save info for CoreData:
        download.title = track.title
        download.artist = track.artist
        download.duration = track.duration        
        download.thumbnailImage = track.thumbnail_image
        
        activeDownloads[download.url] = download
    }
}
