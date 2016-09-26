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
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeControl: UISlider!
    @IBOutlet weak var durationSliderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameBottonLayoutConstraint: NSLayoutConstraint!
    
    static var musicToPlay = [Audio]()
    static var indexToPlay = 0
    fileprivate let player = AudioPlayer.defaultPlayer
    var currentAudioDuration = ""
    var durationNumber: Float = 1
    let defaults = UserDefaults.standard
    var time = Float(0)
    var timer = Timer()
    var interactor:Interactor? = nil
    
    
    //MARK: Override preferredStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.bounds.size.width == 375 {
            durationSliderYConstraint.constant = 348 //adjust duration Slider for iphone6
            artistNameBottonLayoutConstraint.constant = 170
            view.setNeedsLayout()
        }
        player.delegate = self
        volumeControl.value = defaults.float(forKey: "volumeControlValue")
        self.setInfo(fromIndex: AudioPlayerVC.indexToPlay)
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        durationSlider.setThumbImage(UIImage(named: "circle"), for: UIControlState.highlighted)
        volumeControl.setThumbImage(UIImage(named: "circle"), for: UIControlState.normal)
        volumeControl.setThumbImage(UIImage(named: "circle"), for: UIControlState.highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //durationSlider.value = Float(time)
        
    }
    @IBAction func adjustVolume(_ sender: AnyObject) {
        player.controlVolume(value: volumeControl.value)
        defaults.set(volumeControl.value, forKey: "volumeControlValue")
    }
    
    @IBAction func adjustDuration(_ sender: AnyObject) {
        player.pause()
        currenTimeLabel.text? = durationString(Int(durationSlider.value))
        playButton.setImage(UIImage(named: "play"), for: UIControlState())
    }
    
    @IBAction func cancelToDownloads(segue:UIStoryboardSegue) {}
    
    
    @IBAction func tapToDismiss(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didFinishDragging(_ sender: AnyObject) {
        let value = self.durationSlider.value
        let time = CMTime(value: Int64(value), timescale: 1)
        player.seekToTime(time)
        playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        player.play()
    }
    
    @IBAction func handleSwipe(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    
    @IBAction func tapPlayPauseButton(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.imageView?.image == UIImage(named: "play") {
            button.setImage(UIImage(named: "pause"), for: UIControlState())
            player.play()
        } else {
            button.setImage(UIImage(named: "play"), for: UIControlState())
            player.pause()
        }
    }
    
    
    @IBAction func tapNextSong(_ sender: AnyObject) {
        playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        player.next()
    }
    
    @IBAction func tapPreviousSong(_ sender: AnyObject) {
        playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        player.previous()
    }
    
    
    fileprivate func setInfo(fromIndex: Int) {
        if AudioPlayerVC.musicToPlay.count != 0 {
            let audio = AudioPlayerVC.musicToPlay[AudioPlayerVC.indexToPlay]
            artistNameLabel.text? = (audio.artist)
            songNameLabel.text? = (audio.title)
            currentAudioDuration = durationString((audio.duration))
            durationNumber = Float(audio.duration)
            durationLabel.text? = durationString((audio.duration))
            currenTimeLabel.text? = "0:00"
            durationSlider.maximumValue = Float((audio.duration))
            self.player.controlVolume(value: self.volumeControl.value)
            
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
        self.time = Float(time)
        DownloadsTabVC.a = "\(durationString(Int(time))) / \(currentAudioDuration)"
        DownloadsTabVC.b = Float(time) / Float(durationNumber)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadTableView"), object: nil)
        currenTimeLabel.text? = durationString(Int(time))
        durationSlider.value = Float(time)
    }
    
    
    func playerWillPlayNexAudio() {
        setInfo(fromIndex: AudioPlayerVC.indexToPlay)
    }
    
    fileprivate func updatePlayButton() {
        if playButton.imageView?.image == UIImage(named: "play") {
            playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        }
    }
    
}
