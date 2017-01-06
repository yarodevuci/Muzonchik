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
import RealmSwift

class MainScreen: UIViewController, MGSwipeTableCellDelegate {
    
    //MARK: @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var miniPlayerView : UIView!
    @IBOutlet weak var miniPlayerButton : UIButton!
    @IBOutlet weak var miniPlayerArtistName: UILabel!
    @IBOutlet weak var miniPlayerSongName: UILabel!
    @IBOutlet weak var playPauseMiniPlayerButton: UIButton!
    @IBOutlet weak var miniPlayerAlbumCoverImage: UIImageView!
    @IBOutlet weak var miniPlayerProgressView: UIProgressView!
    
    //MARK: Constants
    let player = AudioPlayer.defaultPlayer
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    let gF = GlobalFunctions()
    let defaults = UserDefaults.standard
    //MARK: Variable
    var menuView: BTNavigationDropdownMenu!
    var activeDownloads = [String: Download]()
    var dataTask: URLSessionDataTask?
    var activityView = UIView()
    var allowToDelete = true
    var allowToDeleteFromServer = false
    var allowToAddAudio = false
    var allowToPresent = true
    var isNowPlayingIndex = -1
    var activeDownloadsCount = 0
    var boolArray = [Bool]()
    //MARK: Static variable
    static var selectedIndex = 0
    static var trackProgress = Float(0)
    static var searchResults = [Audio]()
    static var mPlayerPlayButtonImageName = "MiniPlayer_Pause"
    
    weak var refreshControl: UIRefreshControl?
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    lazy var downloadsSession: Foundation.URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    //MARK: Override viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the navigation dropdown menu
        setupDropdownMenu(title: "My music")
        //Set up miniPlayerView
        miniPlayerView.isHidden = true
        
        createRefreshControl()
        
        _ = self.downloadsSession
        tableView.tableFooterView = UIView()
        searchBar.keyboardAppearance = .dark
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: .normal)
        
        displayMusicList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playNextSong), name:NSNotification.Name(rawValue: "playNextSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPreviousSong), name:NSNotification.Name(rawValue: "playPreviousSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name:NSNotification.Name(rawValue: "reloadTableView"), object: nil)
    }
    //MARK: Override viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playPauseMiniPlayerButton?.setImage(UIImage(named: MainScreen.mPlayerPlayButtonImageName), for: UIControlState())
    }
    
    //MARK: instance methods
    
    //refresh control
    func createRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(displayMusicList), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        self.refreshControl = refreshControl
    }
    
    func updateProgress() { tableView.reloadData() }
    
    func playPreviousSong() {
        allowToPresent = false
        if MainScreen.selectedIndex == 0 {
            MainScreen.selectedIndex = MainScreen.searchResults.count - 1
        } else {
            MainScreen.selectedIndex = MainScreen.selectedIndex - 1
        }
        let rowToSelect = NSIndexPath(row: MainScreen.selectedIndex, section: 0)
        self.tableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect as IndexPath)
        allowToPresent = true
    }
    
    func playNextSong() {
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
        allowToPresent = false
        if MainScreen.selectedIndex == (MainScreen.searchResults.count - 1) {
            MainScreen.selectedIndex = -1
        }
        let rowToSelect = NSIndexPath(row: MainScreen.selectedIndex + 1, section: 0)
        self.tableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect as IndexPath)
        allowToPresent = true
    }
    
    
    //Set up the navigation dropdown menu
    func setupDropdownMenu(title: String) {
        let items = ["My music", "Downloaded", "Suggested", "Popular"]
        menuView = BTNavigationDropdownMenu(containerView: self.view, title: title, items: items as [AnyObject])
        menuView.cellSeparatorColor = GlobalFunctions.dropDownMenuColor
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = GlobalFunctions.dropDownMenuColor
        menuView.cellSelectionColor = GlobalFunctions.vkNavBarColor
        menuView.shouldKeepSelectedCellColor = false
        menuView.cellTextLabelColor = UIColor.black
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .center // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.black
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.handleDropdownSelection(index: indexPath)
        }
        view.addSubview(menuView)
    }
    
    
    func displayDownloadedSongsOnly() {
        allowToDelete = true
        self.isNowPlayingIndex = -1
        let realm = try! Realm()
        let downloadedAudioFiles = realm.objects(SavedAudio.self)
        MainScreen.searchResults.removeAll()
        for (i, _) in downloadedAudioFiles.enumerated() {
            let object = downloadedAudioFiles[i]
            MainScreen.searchResults.append(Audio(url: object.url, title: object.title, artist: object.artist, duration: object.duration))
        }
        populateBoolArray()
        self.refreshControl?.removeFromSuperview()
        allowToDeleteFromServer = false //Delete local file. Keep audio on VK server
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func displayRecomendations() {
        self.refreshControl?.removeFromSuperview()
        allowToDelete = false
        allowToAddAudio = true
        self.isNowPlayingIndex = -1
        
        let getAudios = VK.API.Audio.getRecommendations([.targetAudio: "3970872_117703755", .shuffle: "1", .count: "500"])
        startActivityIndicator(withLabel: "Loading...")
        
        getAudios.send (
            onSuccess:  { response in
                MainScreen.searchResults.removeAll()
                for data in response["items"] {
                    let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                    MainScreen.searchResults.append(audio)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.populateBoolArray()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.removeActivityView()
                })
        },
            onError: { error in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.removeActivityView()
                    self.refreshControl?.endRefreshing()
                    SwiftNotificationBanner.presentNotification("\(error.localizedDescription)")
                })
                print("Get Audios fail with error: \(error.localizedDescription)")
        })
    }
    
    func displayPopularMusic() {
        self.isNowPlayingIndex = -1
        allowToDelete = false
        allowToAddAudio = true
        self.refreshControl?.removeFromSuperview()
        
        let getAudios = VK.API.Audio.getPopular([.count: "500"])
        startActivityIndicator(withLabel: "Loading...")
        
        getAudios.send(
            onSuccess:  { response in
                MainScreen.searchResults.removeAll()
                for data in response {
                    let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                    MainScreen.searchResults.append(audio)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.populateBoolArray()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.removeActivityView()
                })
        },
            onError: { error in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.removeActivityView()
                    self.refreshControl?.endRefreshing()
                    SwiftNotificationBanner.presentNotification("\(error.localizedDescription)")
                })
                print("Get Audios fail with error: \(error.localizedDescription)")
        })
    }
    
    func displayMusicList() {
        self.isNowPlayingIndex = -1
        if refreshControl == nil { createRefreshControl() }
        allowToDelete = true
        allowToAddAudio = false
        allowToDeleteFromServer = true
        
        if VK.state == .authorized {
            startActivityIndicator(withLabel: "Loading...")
        }
        VK.API.Audio.get().send(
            
            onSuccess: { response in
                MainScreen.searchResults.removeAll()
                for data in response["items"] {
                    let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                    if !(audio.url?.isEmpty)! { //Skip audios that missing url to play
                        MainScreen.searchResults.append(audio)
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.populateBoolArray()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.removeActivityView()
                })
        },
            onError: { error in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.refreshControl?.endRefreshing()
                    self.removeActivityView()
                    SwiftNotificationBanner.presentNotification("\(error.localizedDescription)")
                    self.displayDownloadedSongsOnly()
                    self.menuView.removeFromSuperview()
                    self.setupDropdownMenu(title: "Downloaded")
                })
                print("Get Audios fail with error: \(error.localizedDescription)")
        })
    }
    
    func populateBoolArray() {
        boolArray.removeAll()
        let cells = [Bool](repeating: false, count: MainScreen.searchResults.count)
        for i in cells {
            self.boolArray.append(i)
        }
    }
    func handleDropdownSelection(index: Int) {
        view.endEditing(true)
        switch index {
        case 0:
            displayMusicList()
        case 1:
            displayDownloadedSongsOnly()
        case 2:
            displayRecomendations()
        case 3:
            displayPopularMusic()
        default:
            break
        }
    }
    
    func deleteSong(_ row: Int) {
        let track = MainScreen.searchResults[row]
        
        if localFileExistsForTrack(track) {
            let realm = try! Realm()
            let fileToDelete = realm.objects(SavedAudio.self)
            
            let fileManager = FileManager.default
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            guard let dirPath = paths.first else { return }
            let filePath = String(describing: "\(dirPath)/\(track.title)\n\(track.artist).mp3")
            
            do {
                try fileManager.removeItem(atPath: filePath)
                try! realm.write({ () -> Void in
                    realm.delete(fileToDelete[row])
                })
                if player.currentAudio != nil && player.currentAudio == track {
                    miniPlayerView.isHidden = true
                    player.kill()
                }
                isNowPlayingIndex = -1
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
        if allowToDeleteFromServer {
            deleteTrackFromServer(row)
        }
        
        boolArray[row] = false
        MainScreen.searchResults.remove(at: row)
        tableView.reloadData()
        self.populateBoolArray()
        SwiftNotificationBanner.presentNotification("Deleted")
    }
    
    func deleteTrackFromServer(_ row: Int) {
        let audio = MainScreen.searchResults[row]
        
        VK.API.Audio.delete([.audioId: String(audio.id), .ownerId: String(audio.ownerID)]).send(
            onSuccess: { result in
                if result.intValue == 1 {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.player.pause()
                        SwiftNotificationBanner.presentNotification("Deleted")
                        self.isNowPlayingIndex = -1
                    })
                }
        },
            onError: {error in
                DispatchQueue.main.async(execute: { () -> Void in
                    SwiftNotificationBanner.presentNotification("Deleting Audio Failed!\nTry again")
                })
                print("Deleting Audio Failed\n \(error.localizedDescription)")
        })
    }
    
    func updatePlayButton() {
        if playPauseMiniPlayerButton.imageView?.image == UIImage(named: "MiniPlayer_Play") {
            AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
            player.play()
            playPauseMiniPlayerButton.setImage(UIImage(named: "MiniPlayer_Pause"), for: UIControlState())
        }
        else {
            player.pause()
            AudioPlayerVC.playButtonImageName = "MusicPlayer_Play"
            playPauseMiniPlayerButton.setImage(UIImage(named: "MiniPlayer_Play"), for: UIControlState())
        }
    }
    
    //MARK: IBAction
    @IBAction func tapPlayPauseMiniPlayer(_ sender: AnyObject) {
        updatePlayButton()
    }
    
    @IBAction func tapNextOnMiniPlayer(_ sender: AnyObject) {
        playNextSong()
    }
    
    //MGSwipeTableCell
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        let indexPath = self.tableView.indexPath(for: cell)
        let track = MainScreen.searchResults[(indexPath?.row)!]
        return direction == .leftToRight && !localFileExistsForTrack(track)
    }
    
    //MGSwipeTableCell
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        swipeSettings.transition = MGSwipeTransition.border
        expansionSettings.buttonIndex = 0
        
        if direction == MGSwipeDirection.leftToRight {
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.5
        }
        return [
            MGSwipeButton(title: "Get", backgroundColor: UIColor.gray, callback: { (cell) -> Bool in
                let indexPath = self.tableView.indexPath(for: cell)
                let track = MainScreen.searchResults[(indexPath?.row)!]
                print("Downloading \(track.title)")
                self.startDownload(track)
                self.tableView.reloadRows(at: [IndexPath(row: (indexPath?.row)!, section: 0)], with: .none)
                return true
            })
        ]
    }
    
    func searchAudio(searchText:String) {
        startActivityIndicator(withLabel: "Searching for \(searchText)")
        
        VK.API.Audio.search([.searchOwn: "0", .q: searchText, .count: "300", .sort: "2", .autoComplete: "1"]).send(
            onSuccess: { response in
                self.isNowPlayingIndex = -1
                MainScreen.searchResults.removeAll()
                for data in response["items"] {
                    let audio = Audio(serverData: data.1.object as! [String : AnyObject])
                    MainScreen.searchResults.append(audio)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.populateBoolArray()
                    self.tableView.reloadData()
                    self.removeActivityView()
                })
        },
            onError: { error in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.removeActivityView()
                    SwiftNotificationBanner.presentNotification("Error searching audio")
                    print("searchAudio fail\n \(error.localizedDescription)")
                })
        })
    }
    
    func dismissKeyboard() {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.showsCancelButton = false
        dismissKeyboard()
    }
    
    
    // MARK: Download methods
    // Called when the Download button for a track is tapped
    func startDownload(_ track: Audio) {
        let urlString = track.url
        if (urlString?.isEmpty)! {
            SwiftNotificationBanner.presentNotification("Unable to download. No url")
            print("No url :(")
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
        
        if allowToAddAudio {
            let addAudio = VK.API.Audio.add([.audioId: String(track.id), .ownerId: String(track.ownerID)])
            addAudio.send()
        }
        activeDownloads[download.url] = download
    }
    
    // Called when the Cancel button for a track is tapped
    func cancelDownload(_ track: Audio) {
        if let urlString = track.url,
            let download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
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
            for (index, track) in MainScreen.searchResults.enumerated() {
                if url == track.url! {
                    return index
                }
            }
        }
        return nil
    }
    
    func startActivityIndicator(withLabel: String) {
        activityView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        activityView.backgroundColor = UIColor.black
        activityView.alpha = 0.8
        
        let activityLable = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let x = view.center.x
        let y = (view.frame.size.height / 2) + 40
        activityLable.center = CGPoint(x: x, y: y)
        activityLable.textColor = UIColor.white
        activityLable.font = UIFont.systemFont(ofSize: 18)
        activityLable.textAlignment = .center
        activityLable.numberOfLines = 0
        activityLable.lineBreakMode = .byWordWrapping
        activityLable.text = withLabel
        activityView.addSubview(activityLable)
        
        //Cancel UIButton
        let activityButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        activityButton.setTitleColor(UIColor.red, for: .normal)
        activityButton.titleLabel?.font =  UIFont.systemFont(ofSize: 20)
        activityButton.setTitle("Cancel", for: .normal)
        activityButton.center = CGPoint(x: x, y: view.frame.size.height - 80)
        
        activityButton.addTarget(self, action: #selector(removeActivityView), for: .touchUpInside)
        activityView.addSubview(activityButton)
        
        let r = CGFloat(30)
        let h = 2 * r + 20
        let cd = (h - 10) / 2
        
        var center = view.center
        center.y -= CGFloat(cd)
        let circle1 = UIBezierPath(arcCenter: center, radius: r, startAngle: CGFloat(-M_PI_2), endAngle:CGFloat(3 * M_PI_2), clockwise: true)
        _ = rotatingCircle(circle: circle1)
        
        let circle2 = UIBezierPath(arcCenter: center, radius: r, startAngle: CGFloat(M_PI_2), endAngle:CGFloat(5 * M_PI_2), clockwise: true)
        _ = rotatingCircle(circle: circle2)
        
        view.addSubview(activityView)
        
    }
    
    func rotatingCircle(circle: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circle.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5.0
        activityView.layer.addSublayer(shapeLayer)
        
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0.0
        strokeEnd.toValue = 1.0
        strokeEnd.duration = 1.0
        strokeEnd.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let endGroup = CAAnimationGroup()
        endGroup.duration = 1.3
        endGroup.repeatCount = MAXFLOAT
        endGroup.animations = [strokeEnd]
        
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.beginTime = 0.3
        strokeStart.fromValue = 0.0
        strokeStart.toValue = 1.0
        strokeStart.duration = 1.0
        strokeStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let startGroup = CAAnimationGroup()
        startGroup.duration = 1.3
        startGroup.repeatCount = MAXFLOAT
        startGroup.animations = [strokeStart]
        
        shapeLayer.add(endGroup, forKey: "end")
        shapeLayer.add(startGroup, forKey: "start")
        
        return shapeLayer
    }
    
    func removeActivityView() {
        print("Remove me ")
        activityView.removeFromSuperview()
        if refreshControl != nil {
            refreshControl?.endRefreshing()
        }
    }
    
    //MARK: Override preferredStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
}

// MARK: - NSURLSessionDelegate
extension MainScreen: URLSessionDelegate {
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
extension MainScreen: URLSessionDownloadDelegate {
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
                self.gF.createSavedAudio(title: aD.realmTitle, artist: aD.realmArtist, duration: aD.realmDuration, url: destinationURL)
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
                    SwiftNotificationBanner.presentNotification("\(self.activeDownloads[originalURL]!.songName)\nError downloading")
                    let url = downloadTask.originalRequest?.url?.absoluteString
                    self.activeDownloads[url!] = nil
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
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? TrackCell {
                
                DispatchQueue.main.async(execute: {
                    trackCell.progressView.progress = download.progress
                    let bitRate = String(Int(totalBytesExpectedToWrite) * 8 / 1000 / download.realmDuration)
                    trackCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize) + " \(bitRate)kbps"
                })
            }
        }
    }
}

//MARK: UISearchBar Delegate
extension MainScreen: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if !allowToDelete {
            displayMusicList()
        }
        for (i, _) in boolArray.enumerated() {
            boolArray[i] = false
        }
        searchBar.text = ""
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
            tableView.setContentOffset(CGPoint.zero, animated: true)
            searchAudio(searchText: searchBar.text!)
        }
        
    }
}

// MARK: TrackCellDelegate
extension MainScreen: TrackCellDelegate {
    
    func cancelTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = MainScreen.searchResults[(indexPath as NSIndexPath).row]
            cancelDownload(track)
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
        }
    }
    
    func downloadTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = MainScreen.searchResults[(indexPath as NSIndexPath).row]
            startDownload(track)
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
        }
    }
}

extension MainScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainScreen.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowToDelete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteSong(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        
        //        cell.downloadButton.layer.borderColor = gF.blueButtonColor
        //        cell.downloadButton.layer.cornerRadius = 5
        cell.cancelButton.layer.borderColor = gF.redButtonColor
        cell.cancelButton.layer.cornerRadius = 5
        
        cell.delegate = self
        cell.delegat = self
        
        let track = MainScreen.searchResults[indexPath.row]
        cell.trackDurationLabel.text = track.duration.toAudioString
        cell.artistLabel.text = track.title
        cell.titleLabel.text = track.artist
        
        //        let request:NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: track.url!)! as URL)
        //        request.httpMethod = "HEAD"
        //
        //        _ = NSURLConnection(request: request as URLRequest, delegate: self)!
        
        
        //when transition from music player keep bar indicator animating for selected song
        if boolArray[indexPath.row] { cell.musicIndicator.state = .estMusicIndicatorViewStatePlaying }
        else { cell.musicIndicator.state = .estMusicIndicatorViewStateStopped }
        
        var showDownloadControls = false
        if let download = activeDownloads[track.url!] {
            showDownloadControls = true
            cell.progressView.progress = download.progress
            cell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
        }
        cell.progressView.isHidden = !showDownloadControls
        cell.progressLabel.isHidden = !showDownloadControls
        cell.trackDurationLabel.isHidden = showDownloadControls
        
        // If the track is already downloaded, enable cell selection and hide the Download button
        let downloaded = localFileExistsForTrack(track)
        cell.downloadButton.isHidden = true
        cell.cancelButton.isHidden = !showDownloadControls
        if downloaded { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
        
        return cell
    }
}

extension MainScreen: NSURLConnectionDataDelegate {
    //Disabled for now
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse)
    {
        //        let a = SearchAudioVC.searchResults
        //        let size = response.expectedContentLength
        //        for i in 0..<SearchAudioVC.searchResults.count {
        //            if a[i].url! == String(describing: response.url!) {
        //                print("\(a[i].artist) is \(Int(size) * 8 / 1000 / a[i].duration)kbps")
        //            }
        //        }
        //        print("size : \(size)")
    }
}

extension MainScreen: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableViewWidth = self.tableView.bounds
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewWidth.size.width, height: self.tableView.sectionFooterHeight))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return miniPlayerView.isHidden ? 0 : 55.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
        //set true for selected cell
        for (i, _) in boolArray.enumerated() {
            if i != indexPath.row {
                boolArray[i] = false
                tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
            } else {
                boolArray[i] = true
                tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
            }
        }
        
        miniPlayerView.isHidden = false
        MainScreen.selectedIndex = indexPath.row
        playPauseMiniPlayerButton?.setImage(UIImage(named: "MiniPlayer_Pause"), for: UIControlState())
        
        miniPlayerArtistName.text = MainScreen.searchResults[indexPath.row].artist
        miniPlayerSongName.text = MainScreen.searchResults[indexPath.row].title
        
        if isNowPlayingIndex != indexPath.row {
            miniPlayerProgressView.progress = 0
            player.setPlayList(MainScreen.searchResults)
            AudioPlayerVC.musicToPlay = MainScreen.searchResults
            AudioPlayerVC.indexToPlay = indexPath.row
            AudioPlayer.index = indexPath.row
            isNowPlayingIndex = indexPath.row
            let track = MainScreen.searchResults[(indexPath as NSIndexPath).row]
            
            if localFileExistsForTrack(track) {
                let urlString = "\(track.title)\n\(track.artist).mp3"
                let url = localFilePathForUrl(urlString)
                player.playAudioFromURL(audioURL: url!)
            }
            else {
                let url = NSURL(string: MainScreen.searchResults[indexPath.row].url!)
                self.player.playAudioFromURL(audioURL: url as! URL)
            }
            
        }
        
        if allowToPresent {
            allowToPresent = false
            performSegue(withIdentifier:"showAudioVC", sender: self)
        }
        
    }
}


