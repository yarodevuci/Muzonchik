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

class AudioPlayerVC: UIViewController, AudioPlayerDelegate {
    
    //MARK: IBOutlet
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var songNameLabel: MarqueeLabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var durationSliderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeBar: MPVolumeView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = volumeBar.subviews.first as? UISlider
        view?.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        view?.setMinimumTrackImage(getImageWithColor(color: UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0), size: CGSize(width: 1, height: 1)), for: UIControlState.normal)
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
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)  //(0, 0, size.width, size.height)
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
        //Unhide play button and hide activity indicator
        if player.getCurrentTime() > 0 {
            activityIndicator.stopAnimating()
            playButton.isHidden = false
        }
        self.time = Float(time)
        //DownloadsTabVC.a = "\(durationString(Int(time))) / \(currentAudioDuration)"
        let progressValue = Float(time) / Float(durationNumber)
        MainScreen.trackProgress = progressValue
        
        //NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadTableView"), object: nil)
        currenTimeLabel.text? = durationString(Int(time))
        durationLabel.text = "-\(durationString(Int(durationNumber) - Int(time)))"
        durationSlider.value = Float(time)
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let sa = rootViewController as? MainScreen { sa.miniPlayerProgressView.progress = progressValue }
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
