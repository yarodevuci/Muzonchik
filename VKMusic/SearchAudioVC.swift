//
//  SearchAudioVC.swift
//  VKMusic
//
//  Created by Yaro on 9/16/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import SwiftyVK
import MediaPlayer

class SearchAudioVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let player = AudioPlayer.defaultPlayer
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    let blueButtonColor = UIColor(red:0.04, green:0.38, blue:1.00, alpha:1.0).cgColor
    let redButtonColor = UIColor(red:0.93, green:0.11, blue:0.14, alpha:1.0).cgColor
    let interactor = Interactor()
    
    var activeDownloads = [String: Download]()
    var dataTask: URLSessionDataTask?
    var allowToDelete = true
    var isNowPlaying = -1
    var allowToAddAudio = false
    var activeDownloadsCount = 0
    fileprivate weak var refreshControl: UIRefreshControl?
    static var searchResults = [Audio]()
    
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    lazy var downloadsSession: Foundation.URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.red]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        //refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(displayMusicList), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        self.refreshControl = refreshControl
        
        tableView.tableFooterView = UIView()
        _ = self.downloadsSession
        displayMusicList()
        searchBar.keyboardAppearance = .dark
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AudioPlayerVC {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
        }
    }
    
    
    func deleteTrack(_ row: Int) {
        let audio = SearchAudioVC.searchResults[row]
        let trackToDelete = VK.API.Audio.delete([.audioId: String(audio.id), .ownerId: String(audio.ownerID)])
        trackToDelete.successBlock = { result in
            if result.intValue == 1 {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.player.pause()
                    SearchAudioVC.searchResults.remove(at: row)
                    self.tableView.reloadData()
                    SwiftNotificationBanner.presentNotification("Удалено")
                })
            }
        }
        trackToDelete.errorBlock = {error in
            SwiftNotificationBanner.presentNotification("Не удалось удалить! Попробуйте еще раз")
            print("Deleting Audio Failed\n \(error)")}
        trackToDelete.send()
    }
    
    @IBAction func cancelToPlayersViewController(segue:UIStoryboardSegue) {}
    
    func displayMusicList() {
        allowToDelete = true
        allowToAddAudio = false
        
        let getAudios = VK.API.Audio.get()
        if VK.state == .authorized {
            RappleActivityIndicatorView.startAnimatingWithLabel("Loading...", attributes: RappleModernAttributes)
        }
        getAudios.successBlock = { response in
            SearchAudioVC.searchResults.removeAll()
            RappleActivityIndicatorView.stopAnimating()
            for data in response["items"] {
                let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                SearchAudioVC.searchResults.append(audio)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            })
        }
        getAudios.errorBlock = { error in
            DispatchQueue.main.async(execute: { () -> Void in
                self.refreshControl?.endRefreshing()
                SwiftNotificationBanner.presentNotification("Ошибка авторизации") })
            print("Get Audios fail with error: \(error)")}
        getAudios.send()
    }
    
    func searchAudio(searchText:String) {
        RappleActivityIndicatorView.startAnimatingWithLabel("Searching for \(searchText)", attributes: RappleModernAttributes)
        let getAudios = VK.API.Audio.search([.searchOwn: "0", .q: searchText, .count: "300", .sort: "2", .autoComplete: "1"])
        getAudios.successBlock = { response in
            SearchAudioVC.searchResults.removeAll()
            RappleActivityIndicatorView.stopAnimating()
            for data in response["items"] {
                let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                SearchAudioVC.searchResults.append(audio)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
        getAudios.errorBlock = {error in
            DispatchQueue.main.async(execute: { () -> Void in
                SwiftNotificationBanner.presentNotification("Ошибка поиска аудиозаписей")
                print("searchAudio fail\n \(error)")
            })
        }
        getAudios.send()
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    
    // MARK: Download methods
    // Called when the Download button for a track is tapped
    func startDownload(_ track: Audio) {
        let urlString = track.url
        let url =  URL(string: urlString!)
        let download = Download(url: urlString!)
        download.downloadTask = self.downloadsSession.downloadTask(with: url!)
        download.downloadTask!.resume()
        download.isDownloading = true
        download.fileName = "\(track.title)\n\(track.artist).mp3"
        download.songName = track.title
        if allowToAddAudio {
            let addAudio = VK.API.Audio.add([.audioId: String(track.id), .ownerId: String(track.ownerID)])
            addAudio.send()
        }
        activeDownloads[download.url] = download
        tabBarController?.tabBar.items?[1].badgeValue = "\(activeDownloads.count)"
    }
    
    // Called when the Cancel button for a track is tapped
    func cancelDownload(_ track: Audio) {
        if let urlString = track.url,
            let download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
            trackBadgeCount()
        }
    }
    
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fullPath = documentsPath.appendingPathComponent((activeDownloads[previewUrl]?.fileName) ?? previewUrl)
        return URL(fileURLWithPath:fullPath)
    }
    
    // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
    func localFileExistsForTrack(_ track: Audio) -> Bool {
        if let localUrl = localFilePathForUrl("\(track.title)\n\(track.artist).mp3") {
            var isDir : ObjCBool = false
            let path = localUrl.path
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        }
        return false
    }
    
    func trackIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for (index, track) in SearchAudioVC.searchResults.enumerated() {
                if url == track.url! {
                    return index
                }
            }
        }
        return nil
    }
    
    //MARK: Override preferredStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
}

// MARK: - NSURLSessionDelegate
extension SearchAudioVC: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
}

// MARK: - NSURLSessionDownloadDelegate
extension SearchAudioVC: URLSessionDownloadDelegate {
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
                try fileManager.copyItem(at: location, to: destinationURL)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "downloadComplete"), object: nil)
                DispatchQueue.main.async(execute: { () -> Void in
                    SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nЗагрузка завершена")
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "downloadComplete"), object: nil)
                    let url = downloadTask.originalRequest?.url?.absoluteString
                    self.activeDownloads[url!] = nil
                    self.trackBadgeCount()
                })
            } catch let error as NSError {
                DispatchQueue.main.async(execute: { () -> Void in
                    SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nОшибка загрузки")
                    let url = downloadTask.originalRequest?.url?.absoluteString
                    self.activeDownloads[url!] = nil
                    self.trackBadgeCount()
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
    
    func trackBadgeCount() {
        if self.activeDownloads.count == 0 {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items?[1].badgeValue = "\(self.activeDownloads.count)"
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? TrackCell {
                DispatchQueue.main.async(execute: {
                    trackCell.progressView.progress = download.progress
                    trackCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
}

//MARK: UISearchBar Delegate
extension SearchAudioVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if !allowToDelete {
            displayMusicList()
        }
        allowToDelete = true
        searchBar.showsCancelButton = false
        view.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        allowToAddAudio = true
        view.endEditing(true)
        searchBar.showsCancelButton = false
        if !searchBar.text!.isEmpty {
            if dataTask != nil {
                dataTask?.cancel()
            }
            allowToDelete = false
            searchAudio(searchText: searchBar.text!)
        }
        
    }
}

// MARK: TrackCellDelegate
extension SearchAudioVC: TrackCellDelegate {
    
    func cancelTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = SearchAudioVC.searchResults[(indexPath as NSIndexPath).row]
            cancelDownload(track)
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
        }
    }
    
    func downloadTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = SearchAudioVC.searchResults[(indexPath as NSIndexPath).row]
            startDownload(track)
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
        }
    }
}

extension SearchAudioVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchAudioVC.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowToDelete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTrack(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        
        cell.downloadButton.layer.borderColor = blueButtonColor
        cell.cancelButton.layer.borderColor = redButtonColor
        
        cell.delegate = self
        
        let track = SearchAudioVC.searchResults[indexPath.row]
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        
        var showDownloadControls = false
        if let download = activeDownloads[track.url!] {
            showDownloadControls = true
            cell.progressView.progress = download.progress
            cell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
        }
        
        cell.progressView.isHidden = !showDownloadControls
        cell.progressLabel.isHidden = !showDownloadControls
        
        // If the track is already downloaded, enable cell selection and hide the Download button
        let downloaded = localFileExistsForTrack(track)
        cell.downloadButton.isHidden = downloaded || showDownloadControls
        cell.cancelButton.isHidden = !showDownloadControls
        
        //        if cell.downloadButton.isHidden && cell.cancelButton.isHidden {
        //            cell.titleLabel.frame = CGRect(x: 8, y: 12, width: 300, height: 20)
        //        } else {
        //            cell.titleLabel.frame = CGRect(x: 8, y: 12, width: 195, height: 20)
        //        }
        return cell
    }
}

extension SearchAudioVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isNowPlaying != indexPath.row {
            player.setPlayList(SearchAudioVC.searchResults)
            AudioPlayerVC.musicToPlay = SearchAudioVC.searchResults
            AudioPlayerVC.indexToPlay = indexPath.row
            AudioPlayer.index = indexPath.row
            isNowPlaying = indexPath.row
            let track = SearchAudioVC.searchResults[(indexPath as NSIndexPath).row]
            if localFileExistsForTrack(track) {
                let urlString = "\(track.title)\n\(track.artist).mp3"
                let url = localFilePathForUrl(urlString)
                player.playAudioFromURL(audioURL: url!)
            }
            else {
                let url = NSURL(string: SearchAudioVC.searchResults[indexPath.row].url!)
                player.playAudioFromURL(audioURL: url as! URL)
            }
            
        }
    }
}

extension SearchAudioVC: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}


