//
//  AudioPlayerVCViewController.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/20/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerVC: UIViewController, AudioPlayerDelegate {
    
    //MARK: IBOutlet
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var songNameLabel: MarqueeLabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeControl: UISlider!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var durationSliderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverHeightConstraint: NSLayoutConstraint!
    
    //MARK: Varriables
    static var musicToPlay = [Audio]()
    static var indexToPlay = 0
    static var albumImage = UIImage(named: "music_plate")

    let defaults = UserDefaults.standard
    let player = AudioPlayer.defaultPlayer
    
    var currentAudioDuration = ""
    var durationNumber: Float = 1
    var time = Float(0)
    var tapCloseButtonActionHandler : ((Void) -> Void)?
    
    
    //MARK: Override preferredStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(getAlbumCover), name:NSNotification.Name(rawValue: "albumCoverImageRetrieved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayButton), name:NSNotification.Name(rawValue: "SwapPlayButtonImage"), object: nil)
        
        if UIScreen.main.bounds.size.width == 375 {
            durationSliderYConstraint.constant = 370
            artistNameBottonLayoutConstraint.constant = 200
            albumCoverHeightConstraint.constant = 330
            view.setNeedsLayout()
        }
        player.delegate = self
        volumeControl.setValue(defaults.float(forKey: "volumeControlValue"), animated: false)
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.highlighted)
        volumeControl.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        volumeControl.setThumbImage(UIImage(named: "circle"), for: UIControlState.highlighted)
        
        self.setInfo(fromIndex: AudioPlayerVC.indexToPlay)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func adjustVolume(_ sender: AnyObject) {
        player.controlVolume(value: volumeControl.value)
        var volume = AVAudioSession.sharedInstance().outputVolume
        volume = volumeControl.value
        print("Output volume: \(volume)")
        defaults.set(volumeControl.value, forKey: "volumeControlValue")
    }
    
    @IBAction func adjustDuration(_ sender: AnyObject) {
        player.pause()
        currenTimeLabel.text? = durationString(Int(durationSlider.value))
        playButton.setImage(UIImage(named: "Play"), for: UIControlState())
    }
    
    @IBAction func tapToDismiss(_ sender: AnyObject) {
        
        self.tapCloseButtonActionHandler?()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didFinishDragging(_ sender: AnyObject) {
        let value = self.durationSlider.value
        let time = CMTime(value: Int64(value), timescale: 1)
        player.seekToTime(time)
        playButton.setImage(UIImage(named: "Pause"), for: UIControlState())
        player.play()
    }
    
    
    @IBAction func tapPlayPauseButton(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "SwapMinPlayerPlayButtonImage"), object: nil)
        
        let button = sender as! UIButton
        if button.imageView?.image == UIImage(named: "Play") {
            button.setImage(UIImage(named: "Pause"), for: UIControlState())
            player.play()
        } else {
            button.setImage(UIImage(named: "Play"), for: UIControlState())
            player.pause()
        }
    }
    
    
    @IBAction func tapNextSong(_ sender: AnyObject) {
        updatePlayButton()
        player.next()
    }
    
    @IBAction func tapPreviousSong(_ sender: AnyObject) {
        updatePlayButton()
        player.previous()
    }
    
    func getAlbumCover() {
        self.albumCoverImage.image = AudioPlayerVC.albumImage
    }
    
    
    fileprivate func setInfo(fromIndex: Int) {
        if AudioPlayerVC.musicToPlay.count != 0 {
            let audio = AudioPlayerVC.musicToPlay[AudioPlayerVC.indexToPlay]
            artistNameLabel.text? = (audio.artist)
            
            songNameLabel.text? = (audio.title)
            currentAudioDuration = durationString((audio.duration))
            durationNumber = Float(audio.duration)
            durationLabel.text? = "-\(durationString((audio.duration)))"
            currenTimeLabel.text? = "0:00"
            durationSlider.maximumValue = Float((audio.duration))
            durationSlider.value = 0
            playButton.setImage(UIImage(named: "Pause"), for: UIControlState())
            
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    fileprivate func durationString(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration - minutes * 60
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
    
    //MARK: - AudioPlayerDelegate
    func audioDidChangeTime(_ time: Int64) {
        player.controlVolume(value: self.volumeControl.value)

        activityIndicator.stopAnimating()
        playButton.isHidden = false

        self.time = Float(time)
        //DownloadsTabVC.a = "\(durationString(Int(time))) / \(currentAudioDuration)"
        let progressValue = Float(time) / Float(durationNumber)
        SearchAudioVC.trackProgress = progressValue
        
        //NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadTableView"), object: nil)
        currenTimeLabel.text? = durationString(Int(time))
        durationSlider.value = Float(time)
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let sa = rootViewController as? SearchAudioVC { sa.miniPlayerProgressView.progress = progressValue }
    }
    
    
    func playerWillPlayNexAudio() {
        setInfo(fromIndex: AudioPlayerVC.indexToPlay)
    }
    
    func updatePlayButton() {
        if playButton.imageView?.image == UIImage(named: "Play") {
            playButton.setImage(UIImage(named: "Pause"), for: UIControlState())
            player.play()
        }
        else {
            playButton.setImage(UIImage(named: "Play"), for: UIControlState())
            player.pause()
        }
    }
    
}
