//
//  DownloadsTabVC.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/20/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import SwiftyVK

class DownloadsTabVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate weak var refreshControl: UIRefreshControl?
    let player = AudioPlayer.defaultPlayer
    
    var allowToDelete = true
    var isNowPlaying = -1
    var myDownloads = [Audio]()
    var selectedIndex = 0
    static var a = ""
    static var b = Float(0)
    let interactor = Interactor()

    
    
    //MARK: Override preferredStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AudioPlayerVC {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(displayDownloads), name:NSNotification.Name(rawValue: "downloadComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name:NSNotification.Name(rawValue: "reloadTableView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playNextSong), name:NSNotification.Name(rawValue: "playNextSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPreviousSong), name:NSNotification.Name(rawValue: "playPreviousSong"), object: nil)
        
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.red]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(displayDownloads), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        self.refreshControl = refreshControl
        
        tableView.tableFooterView = UIView()
        displayDownloads()
        searchBar.keyboardAppearance = .dark

    }
    func playPreviousSong() {
        if selectedIndex == 0 {
            selectedIndex = myDownloads.count - 1
        } else {
            selectedIndex = selectedIndex - 1
        }
        let rowToSelect = NSIndexPath(row: selectedIndex, section: 0)
        self.tableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect as IndexPath)
    }
    
    func playNextSong() {
        if selectedIndex == (myDownloads.count - 1) {
            selectedIndex = -1
        }
        let rowToSelect = NSIndexPath(row: selectedIndex + 1, section: 0)
        self.tableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect as IndexPath)

    }
    func updateProgress() {
        tableView.reloadData()
    }
    
    func displayDownloads() {
        allowToDelete = true
        myDownloads.removeAll()
        for audio in SearchAudioVC.searchResults {
            refreshControl?.endRefreshing()
            if SearchAudioVC().localFileExistsForTrack(audio) {
                self.myDownloads.append(audio)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func deleteTrack(_ row: Int) {
        player.pause()
        myDownloads.remove(at: row)
        tableView.reloadData()
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            do {
                print("deleting file at location:\n\(mp3Files[row].absoluteString)")
                try! fileManager.removeItem(at: mp3Files[row].absoluteURL)
                print("Deleted..")
                SwiftNotificationBanner.presentNotification("Удалено")
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func emptyMessage(message:String) {
        let messageLabel = UILabel(frame: CGRectMake(0,-50,self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 22)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    //@IBAction func goToDownloads(segue:UIStoryboardSegue) {}

    
}

extension DownloadsTabVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myDownloads.count > 0 {
            tableView.backgroundView = .none
            return myDownloads.count
        } else {
            emptyMessage(message: "Здесь пока ничего нет.")
            return 0
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadsTabCell", for: indexPath) as! DownloadsTabCell
        cell.delegate = self
        let track = myDownloads[indexPath.row]
        
        cell.playPauseButton.isHidden = !((player.currentAudio != nil) && player.currentAudio.title == track.title)
        cell.progressLabel.isHidden = !((player.currentAudio != nil) && player.currentAudio.title == track.title)
        cell.progressView.isHidden = !((player.currentAudio != nil) && player.currentAudio.title == track.title)
        
        cell.progressLabel.text = DownloadsTabVC.a
        cell.progressView.progress = DownloadsTabVC.b
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        
        return cell
    }
}

extension DownloadsTabVC: DownloadsTabCellDelegate {
    func playPauseButtonTapped(_ cell: DownloadsTabCell) {
        
        let button = cell.playPauseButton
        if button?.imageView?.image == UIImage(named: "PlayWhite") {
            button?.setImage(UIImage(named: "PauseWhite"), for: UIControlState())
            player.play()
        } else {
            button?.setImage(UIImage(named: "PlayWhite"), for: UIControlState())
            player.pause()
        }
    }
    
}

extension DownloadsTabVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = myDownloads[(indexPath as NSIndexPath).row]
        selectedIndex = indexPath.row
        
        if isNowPlaying != indexPath.row {
            player.setPlayList(myDownloads)
            AudioPlayerVC.musicToPlay = myDownloads
            AudioPlayerVC.indexToPlay = indexPath.row
            AudioPlayer.index = indexPath.row
            isNowPlaying = indexPath.row
            let urlString = "\(track.title)\n\(track.artist).mp3"
            let url = SearchAudioVC().localFilePathForUrl(urlString)
            player.playAudioFromURL(audioURL: url!)
        }
    }
    
}

extension DownloadsTabVC: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}


