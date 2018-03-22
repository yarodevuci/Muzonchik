//  AudioPlayer.swift
//  Created by Yaroslav on 10.01.16

import Foundation
import AVFoundation
import MediaPlayer

protocol AudioPlayerDelegate {
    func audioDidChangeTime(_ time: Int64)
    func playerWillPlayNexAudio()
	func playerWillPlayPreviousAudio()
	func receivedArtworkImage(_ image: UIImage)
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
		
		let metadataList = playerItem.asset.metadata
		var audio_image = #imageLiteral(resourceName: "ArtPlaceholder")
		if metadataList.count > 0 {
			for item in metadataList {
				guard let key = item.commonKey, let value = item.value else { continue }
				
				if key.rawValue == "artwork" {
					if let audioImage = UIImage(data: value as! Data) {
						print("\nimage Found\n")
						audio_image = audioImage
						self.delegate?.receivedArtworkImage(audioImage)
					}
				}
			}
		} else {
			print("\nMetadataList is empty \n")
		}
		
		CommandCenter.defaultCenter.setNowPlayingInfo(artworkImage: audio_image)
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
