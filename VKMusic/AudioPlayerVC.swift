//
//  AudioPlayerVCViewController.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/20/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

//MARK: - This class is deprecated
class AudioPlayerVC: UIViewController, AudioPlayerDelegate {
    
    //MARK: IBOutlet
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var songNameLabel: MarqueeLabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var playerBackgroundImage: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var durationSliderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeBar: MPVolumeView!
    
    //MARK: Varriables
    static var musicToPlay = [Audio]()
    static var indexToPlay = 0
    static var albumImage = UIImage(named: "music_plate")
    static var time = Float(0)
    static var currentTimeForAudio = ""
    static var playButtonImageName = "MusicPlayer_Pause"
    
    
    let player = AudioPlayer.defaultPlayer
    
    var currentAudioDuration = ""
    var durationNumber: Float = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getAlbumCover), name:NSNotification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
        
        if UIScreen.main.bounds.size.width == 375 { //if iPhone 6
            durationSliderYConstraint.constant = 370
            artistNameBottonLayoutConstraint.constant = 200
            albumCoverHeightConstraint.constant = 330
            view.setNeedsLayout()
        }
        
        if UIScreen.main.bounds.size.height == 480 { //if iPhone 4
            albumCoverHeightConstraint.constant = 230
            durationSliderYConstraint.constant = 270
            artistNameBottonLayoutConstraint.constant = 130
            view.setNeedsLayout()
        }
        
        player.delegate = self
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.highlighted)
        self.setInfo(fromIndex: AudioPlayerVC.indexToPlay)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                dismiss(animated: true, completion: nil)
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = volumeBar.subviews.first as? UISlider
        view?.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        view?.setMinimumTrackImage(getImageWithColor(color: UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0), size: CGSize(width: 1, height: 1)), for: UIControlState.normal)
        
        albumCoverImage.image = AudioPlayerVC.albumImage
        playerBackgroundImage.image = AudioPlayerVC.albumImage
    }
    
    
    @IBAction func adjustDuration(_ sender: AnyObject) {
        player.pause()
        currenTimeLabel.text? = Int(durationSlider.value).toAudioString
        playButton.setImage(UIImage(named: "MusicPlayer_Play"), for: UIControlState())
        
        
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Play"
        MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Play"
    }
    
    @IBAction func didFinishDragging(_ sender: AnyObject) {
        let value = self.durationSlider.value
        let time = CMTime(value: Int64(value), timescale: 1)
        player.seekToTime(time)
        playButton.setImage(UIImage(named: "MusicPlayer_Pause"), for: UIControlState())
        
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
        MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Pause"
        player.play()
    }
    
    
    
    
    @IBAction func tapToDismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func tapPlayPauseButton(_ sender: AnyObject) {
        updatePlayButton()
    }
    
    
    @IBAction func tapNextSong(_ sender: AnyObject) {
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
        MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Pause"
        player.next()
    }
    
    @IBAction func tapPreviousSong(_ sender: AnyObject) {
        AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
        MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Pause"
        player.previous()
    }
    
    @objc func getAlbumCover() {
        playerBackgroundImage.image = AudioPlayerVC.albumImage
        self.albumCoverImage.image = AudioPlayerVC.albumImage
    }
    //For volume bar
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    fileprivate func setInfo(fromIndex: Int) {
        if AudioPlayerVC.musicToPlay.count != 0 {
            let audio = AudioPlayerVC.musicToPlay[AudioPlayerVC.indexToPlay]
            artistNameLabel.text? = audio.artist
            
            songNameLabel.text? = audio.title
            currentAudioDuration = audio.duration.toAudioString
            durationNumber = Float(audio.duration)
            durationLabel.text? = "-\(audio.duration.toAudioString)"
            currenTimeLabel.text? = Int(AudioPlayerVC.time).toAudioString
            durationSlider.maximumValue = Float(audio.duration)
            durationSlider.setValue(AudioPlayerVC.time, animated: false)
            
            
            playButton.setImage(UIImage(named: AudioPlayerVC.playButtonImageName), for: UIControlState())
            if player.getCurrentTime() == 0 {
                playButton.isHidden = true
                activityIndicator.startAnimating()
            }
        }
    }
    
    //MARK: - AudioPlayerDelegate
    func audioDidChangeTime(_ time: Int64) {
        //Unhide play button and hide activity indicator
        if player.getCurrentTime() > 0 {
            activityIndicator.stopAnimating()
            playButton.isHidden = false
        }
        AudioPlayerVC.time = Float(time)
        let progressValue = Float(time) / Float(durationNumber)
        MainScreen.trackProgress = progressValue
        
        currenTimeLabel.text? = Int(time).toAudioString
        durationLabel.text = "-\((Int(durationNumber) - Int(time)).toAudioString)"
        durationSlider.value = Float(time)
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let sa = rootViewController as? MainScreen { sa.miniPlayerProgressView.progress = progressValue }
    }
    
    
    func playerWillPlayNexAudio() {
        currenTimeLabel.text? = "0:00"
        AudioPlayerVC.time = 0
        setInfo(fromIndex: AudioPlayerVC.indexToPlay)
    }
    
    func updatePlayButton() {
        if playButton.imageView?.image == UIImage(named: "MusicPlayer_Play") {
            playButton.setImage(UIImage(named: "MusicPlayer_Pause"), for: UIControlState())
            AudioPlayerVC.playButtonImageName = "MusicPlayer_Pause"
            MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Pause"
            player.play()
        } else {
            playButton.setImage(UIImage(named: "MusicPlayer_Play"), for: UIControlState())
            AudioPlayerVC.playButtonImageName = "MusicPlayer_Play"
            MainScreen.mPlayerPlayButtonImageName = "MiniPlayer_Play"
            player.pause()
        }
    }
    
}
