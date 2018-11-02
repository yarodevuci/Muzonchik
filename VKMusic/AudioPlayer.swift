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
    
    static var index = 0

	var delegate: AudioPlayerDelegate?
    var currentAudio: Audio!

    fileprivate var player: AVPlayer!
    fileprivate var currentPlayList = [Audio]()
    fileprivate var timeObserber: Any?
    
    //MARK: - Time Observer
    
    fileprivate func addTimeObeserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        
        timeObserber = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            
            let currentTime = Int64(time.value) / Int64(time.timescale)
            
            self.delegate?.audioDidChangeTime(currentTime)
            
            if currentTime == Int64(self.currentAudio.duration) {
                self.next()
            }
        }
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
        
        
        if let savedTime = UserDefaults.standard.value(forKey: currentAudio.url) as? Double {
            print(savedTime)
            let timeToScroll = CMTime(seconds: savedTime, preferredTimescale: 1)
            player.seek(to: timeToScroll)
        }
        
        player.play()
        addTimeObeserver()
		
		let metadataList = playerItem.asset.metadata
		var audio_image = currentPlayList[AudioPlayer.index].thumbnail_image
		
		CommandCenter.defaultCenter.setNowPlayingInfo(artworkImage: audio_image ?? #imageLiteral(resourceName: "ArtPlaceholder"))
    }
	
	func play() {
		if let player = player { player.play() }
	}
    
    func previous() {
        NotificationCenter.default.post(name: .previousTrack, object: nil)
		delegate?.playerWillPlayPreviousAudio()
    }
	
	func next() {
		NotificationCenter.default.post(name: .nextTrack, object: nil)
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
