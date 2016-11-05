//  AudioPlayer.swift
//  Created by Yaroslav on 10.01.16

import Foundation
import AVFoundation
import MediaPlayer


enum PlaybleScreen {
    case none
    case all
    case search
    case cache
}

let audioPlayerWillChangePlaybleScreenNotificationKey = "audioPlayerWillChangePlaybleScreenNotification"
let audioPlayerWillPlayNextSongNotificationKey = "audioPlayerWillPlayNextSongNotification"

protocol AudioPlayerDelegate {
    func audioDidChangeTime(_ time: Int64)
    func playerWillPlayNexAudio()
}

class AudioPlayer{
    
    static let defaultPlayer = AudioPlayer()
    
    var delegate: AudioPlayerDelegate?
    static var index = 0
    fileprivate var player: AVPlayer!
    var currentAudio: Audio!
    var playbleScreen = PlaybleScreen.none {
        willSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: audioPlayerWillChangePlaybleScreenNotificationKey), object: nil, userInfo: nil)
        }
    }
    
    fileprivate var currentPlayList = [Audio]()
    fileprivate var timeObserber: AnyObject?
    
    //MARK: - Time Observer
    
    fileprivate func addTimeObeserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserber = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            (time: CMTime) -> Void in
            let currentTime  = Int64(time.value) / Int64(time.timescale)
            if let d = self.delegate {
                d.audioDidChangeTime(currentTime)
            }
            if currentTime == Int64(self.currentAudio.duration) {
                self.next()
            }
            } as AnyObject?
    }
    
    fileprivate func killTimeObserver() {
        if let observer = timeObserber {
            player.removeTimeObserver(observer)
        }
    }
    
    //MARK: - Public API
    func playAudioFromURL(audioURL: URL) {
        if currentAudio != nil {
            killTimeObserver()
        }
        if let d = self.delegate {
            d.playerWillPlayNexAudio()
        }
        
        currentAudio = currentPlayList[AudioPlayer.index]
        
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem:playerItem)
        player.play()
        addTimeObeserver()
        
        DispatchQueue.main.async {
            AudioPlayerVC.albumImage = UIImage(named: "music_plate")
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
            self.setAlbumImageForMiniPlayer(image: UIImage(named: "music_plate")!)
            CommandCenter.defaultCenter.setNowPlayingInfo()
        }
        
        
        DispatchQueue.global(qos: .background).async {
            let metadataList = playerItem.asset.metadata
            if metadataList.count != 0 {
                for item in metadataList {
                    if item.commonKey == "artwork" {
                        print("image Found")
                        DispatchQueue.main.async {
                            AudioPlayerVC.albumImage = UIImage(data: item.value as! Data)!
                            self.setAlbumImageForMiniPlayer(image: UIImage(data: item.value as! Data)!)
                            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
                            CommandCenter.defaultCenter.setNowPlayingInfo()
                        }
                    }
                }
            } else { print("MetadataList is empty ") }
        }

    }
    
    func setAlbumImageForMiniPlayer(image: UIImage) {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let sa = rootViewController as? MainScreen { sa.miniPlayerAlbumCoverImage.image = image }
    }
    
    func play() { player.play() }
    
    func previous() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "playPreviousSong"), object: nil)
    }
    
    func pause() {
        if player != nil {
            player.pause()
        }
    }
    
    func getCurrentTime() -> Double {
        return player.currentTime().seconds
    }
    
    func next() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "playNextSong"), object: nil)
    }
    
    func kill() {
        if player != nil {
            killTimeObserver()
            player.replaceCurrentItem(with: nil)
            currentAudio = nil
        }
    }
    
    func setPlayList(_ playList: [Audio]) {
        currentPlayList = playList
    }
    
    func seekToTime(_ time: CMTime) {
        player.seek(to: time)
    }
}
