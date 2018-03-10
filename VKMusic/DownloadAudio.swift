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
            do {
                try fileManager.removeItem(at: destinationURL)
            } catch let error as NSError {
                //FILE PROBABLY DOES NOT EXIST:
                print("ERROR WHEN TRYING REMOVING TEMP FILE: \(error.localizedDescription)")
            }
            
            do {
                try fileManager.moveItem(at: location, to: destinationURL)
                let aD = self.activeDownloads[originalURL]!
				
				
				CoreDataManager.shared.saveToCoreData(audio: Audio(url: destinationURL.absoluteString, title: aD.realmTitle, artist: aD.realmArtist, duration: aD.realmDuration))
				
				
               // GlobalFunctions.shared.createSavedAudio(title: aD.realmTitle, artist: aD.realmArtist, duration: aD.realmDuration, url: destinationURL)
                DispatchQueue.main.async {
                    SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nDownload complete")
                    self.activeDownloads[downloadTask.originalRequest?.url?.absoluteString ?? ""] = nil
                    self.tableView.reloadData()
                }
            } catch let error as NSError {
                DispatchQueue.main.async(execute: { () -> Void in
                    print("ERROR: \(error.localizedDescription)")
                    if self.activeDownloads[originalURL] != nil {
                        SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\n\(error.localizedDescription)")
                        self.activeDownloads[downloadTask.originalRequest?.url?.absoluteString ?? ""] = nil

                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            
            DispatchQueue.main.async(execute: {
                if let trackIndex = self.trackIndexForDownloadTask(downloadTask),
                    let trackCell = self.tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? TrackListTableViewCell {
                    trackCell.downloadProgressView.progress = download.progress
                    let bitRate = String(Int(totalBytesExpectedToWrite) * 8 / 1000 / download.realmDuration)
                    trackCell.downloadProgressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize) + " \(bitRate) kbps"
                }
            })
        }
    }
    
    func startDownload(_ track: Audio) {
        let urlString = track.url
        if urlString.isEmpty {
            SwiftNotificationBanner.presentNotification("Unable to download. No url")
            return
        }
        let url =  URL(string: urlString)
        let download = Download(url: urlString)
        download.downloadTask = self.downloadsSession.downloadTask(with: url!)
        download.downloadTask!.resume()
        download.isDownloading = true
        download.fileName = "\(track.title)_\(track.artist).mp\(track.url.last ?? "3")"
        download.songName = track.title
        
        //Save info for Ream:
        download.realmTitle = track.title
        download.realmArtist = track.artist
        download.realmDuration = track.duration
        
        activeDownloads[download.url] = download
    }
}
