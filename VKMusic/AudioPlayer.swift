//  AudioPlayer.swift
//  Created by Yaroslav on 10.01.16

import Foundation
import AVFoundation
import MediaPlayer

protocol AudioPlayerDelegate {
    func audioDidChangeTime(_ time: Int64)
    func playerWillPlayNexAudio()
	func playerWillPlayPreviousAudio()
}

class AudioPlayer {
    
    static let defaultPlayer = AudioPlayer()
    
	var delegate: AudioPlayerDelegate?
    static var index = 0
    fileprivate var player: AVPlayer!
    var currentAudio: Audio!
	
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
    
    func playAudio(fromURL url: URL!) {
        if currentAudio != nil {
            killTimeObserver()
        }
	
        currentAudio = currentPlayList[AudioPlayer.index]
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem:playerItem)
        player.play()
        addTimeObeserver()
        
        DispatchQueue.main.async {
            CommandCenter.defaultCenter.setNowPlayingInfo()
        }
    }
    
	//MARK: - Public API - #####  DEPRECATED  #####
    func playAudioFromURL(audioURL: URL) {
        if currentAudio != nil {
            killTimeObserver()
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
                    if let i = item.commonKey {
                        if i.rawValue == "artwork" {
                            print("image Found")
                            DispatchQueue.main.async {
                                AudioPlayerVC.albumImage = UIImage(data: item.value as! Data)!
                                self.setAlbumImageForMiniPlayer(image: UIImage(data: item.value as! Data)!)
                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
                                CommandCenter.defaultCenter.setNowPlayingInfo()
                            }
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
    
	func play() {
		if let player = player {
			player.play()
		}
	}
    
    func previous() {
       // NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "playPreviousSong"), object: nil)
		delegate?.playerWillPlayPreviousAudio()
    }
	
	func next() {
		//NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "playNextSong"), object: nil)
		delegate?.playerWillPlayNexAudio()
	}
    
    func pause() {
        if let player = player {
            player.pause()
        }
    }
    
    func getCurrentTime() -> Double {
        return player.currentTime().seconds
    }
	
    func kill() {
		if let player = player {
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
