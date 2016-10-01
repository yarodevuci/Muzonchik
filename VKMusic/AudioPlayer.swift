//
//  AudioPlayer.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

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
        currentAudio = currentPlayList[AudioPlayer.index]
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        addTimeObeserver()
        CommandCenter.defaultCenter.setNowPlayingInfo()
        if let d = self.delegate {
            d.playerWillPlayNexAudio()
        }
        let metadataList = playerItem.asset.metadata
        var isFound = false
        if metadataList.count != 0 {
            for item in metadataList {
                if item.commonKey == "artwork" {
                    print("image loaded")
                    AudioPlayerVC.albumImage = UIImage(data: item.value as! Data)!
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
                    isFound = true
                    break
                }
            }
            if !isFound {
                print("Not Found ")
                AudioPlayerVC.albumImage = UIImage(named: "music_plate")
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
            }
        }
        else {
            AudioPlayerVC.albumImage = UIImage(named: "music_plate")
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
            print("No album Image found ")
        }
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
    
    func controlVolume(value: Float) {
        player.volume = value
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
