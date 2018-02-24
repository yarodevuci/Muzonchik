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
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.moveItem(at: location, to: destinationURL)
                let aD = self.activeDownloads[originalURL]!
                GlobalFunctions.shared.createSavedAudio(title: aD.realmTitle, artist: aD.realmArtist, duration: aD.realmDuration, url: destinationURL)
                DispatchQueue.main.async(execute: {
                    SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nDownload complete")
                })
                
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "downloadComplete"), object: nil)
                    let url = downloadTask.originalRequest?.url?.absoluteString
                    self.activeDownloads[url!] = nil
                    self.tableView.reloadData()
                })
            } catch let error as NSError {
                DispatchQueue.main.async(execute: { () -> Void in
                    if self.activeDownloads[originalURL] != nil {
                        SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nError downloading")
                        let url = downloadTask.originalRequest?.url?.absoluteString
                        self.activeDownloads[url!] = nil
                    }
                })
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
        }
        if let trackIndex = trackIndexForDownloadTask(downloadTask) {
            DispatchQueue.main.async(execute: {
                self.tableView.reloadRows(at: [IndexPath(row: trackIndex, section: 0)], with: .none)
            })
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
                    trackCell.downloadProgressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize) + " \(bitRate)kbps"
                }
            })
        }
    }
    
    func startDownload(_ track: Audio) {
        let urlString = track.url
        if (urlString?.isEmpty)! {
            SwiftNotificationBanner.presentNotification("Unable to download. No url")
            return
        }
        let url =  URL(string: urlString!)
        let download = Download(url: urlString!)
        download.downloadTask = self.downloadsSession.downloadTask(with: url!)
        download.downloadTask!.resume()
        download.isDownloading = true
        download.fileName = "\(track.title)\n\(track.artist).mp3"
        download.songName = track.title
        
        //Save info for Ream:
        download.realmTitle = track.title
        download.realmArtist = track.artist
        download.realmDuration = track.duration
        
        activeDownloads[download.url] = download
    }
}
