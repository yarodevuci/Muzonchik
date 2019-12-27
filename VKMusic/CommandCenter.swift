//
//  CommandCenter.swift
//  VKMusic
//
//  Created by Yaro
//

import Foundation
import MediaPlayer

class CommandCenter: NSObject {
    
    static let defaultCenter = CommandCenter()
    
    fileprivate let player = AudioPlayer.defaultPlayer
    
    override init() {
        super.init()
        setCommandCenter()
        setAudioSeccion()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    //AVAudioSessionCategoryOptions
    func getUserCategoryOption() -> AVAudioSession.CategoryOptions {
        let isSetToSpeaker = UserDefaults.standard.value(forKey: "mixAudioWithOthers") as? Bool ?? true
        return isSetToSpeaker ? .mixWithOthers : .defaultToSpeaker
    }
   
    func setAudioSeccion() { //TODO: Change to .defaultToSpeaker to show music controls on Locked Screen or .mixWithOthers not to show
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [getUserCategoryOption()])
            do { try AVAudioSession.sharedInstance().setActive(true) }
            catch let error as NSError { print(error.localizedDescription) }
        }
        catch let error as NSError { print(error.localizedDescription) }
    }
    
    //MARK: - Remote Command Center
    fileprivate func setCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
//        commandCenter.pauseCommand.addTarget(self, action: #selector(remoteCommandPause))
//        commandCenter.playCommand.addTarget(self, action: #selector(remoteCommandPlay))
//        commandCenter.previousTrackCommand.addTarget(self, action: #selector(remoteCommandPrevious))
//        commandCenter.nextTrackCommand.addTarget(self, action: #selector(remoteCommandNext))
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.remoteCommandPause()
            return .success
        }
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.remoteCommandPlay()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.remoteCommandPrevious()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.remoteCommandNext()
            return .success
        }
    }
    
    @objc fileprivate func remoteCommandPause() {
        player.pause()
    }
    
    @objc fileprivate func remoteCommandPlay() {
        player.play()
    }
    
    @objc fileprivate func remoteCommandNext() {
        player.next()
    }
    
    @objc fileprivate func remoteCommandPrevious() {
        player.previous()
    }
    
    //MARK: - Public Methods
    
	func setNowPlayingInfo(artworkImage: UIImage) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyPlaybackDuration: player.currentAudio.duration,
            MPMediaItemPropertyTitle: player.currentAudio.title,
            MPMediaItemPropertyArtist: player.currentAudio.artist,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artworkImage),
            MPNowPlayingInfoPropertyPlaybackRate: 1.0]
    }
}
