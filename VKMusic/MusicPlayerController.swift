//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit
import LNPopupController
import MediaPlayer

class MusicPlayerController: UIViewController {

	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var fullPlayerPlayPauseButton: UIButton!
    @IBOutlet weak var volumeViewBar: MPVolumeView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
	let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    
    var playBarButton: UIBarButtonItem!
    var puseBarButton: UIBarButtonItem!
    var nextBarButton: UIBarButtonItem!
    var plaingTime = Float(0)
	var trackDurationSeconds = 0
    
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

        puseBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Pause"), style: .plain, target: self, action: #selector(pauseSong))
		puseBarButton.accessibilityLabel = NSLocalizedString("Pause", comment: "")
		nextBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Forward"), style: .plain, target: self, action: #selector(nextSong))
		nextBarButton.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
        
        playBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Play"), style: .plain, target: self, action: #selector(playSong))
		
		if UserDefaults.standard.object(forKey: "PopupSettingsBarStyle") as? LNPopupBarStyle == LNPopupBarStyle.compact || ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10 {
			popupItem.leftBarButtonItems = [ puseBarButton ]
			popupItem.rightBarButtonItems = [ nextBarButton ]
		}
		else {
			popupItem.rightBarButtonItems = [ puseBarButton, nextBarButton ]
		}
		
		accessibilityDateComponentsFormatter.unitsStyle = .spellOut
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = volumeViewBar.subviews.first as? UISlider
        volumeViewBar.showsRouteButton = false
        view?.setThumbImage(#imageLiteral(resourceName: "circle"), for: UIControlState.normal)
        view?.setMinimumTrackImage(GlobalFunctions.shared.getImageWithColor(color: UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0), size: CGSize(width: 1, height: 1)), for: UIControlState.normal)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioPlayer.defaultPlayer.delegate = self
        
        durationSlider.setThumbImage(#imageLiteral(resourceName: "circle"), for: UIControlState.normal)
        durationSlider.setThumbImage(#imageLiteral(resourceName: "circle"), for: UIControlState.highlighted)
        durationSlider.maximumValue = Float(trackDurationSeconds)
        
        songNameLabel.text = songTitle
        albumNameLabel.text = albumTitle
        albumArtImageView.image = albumArt
    }
    
    //Play pause songs
    @objc func pauseSong() {
        AudioPlayer.defaultPlayer.pause()
        popupItem.rightBarButtonItems = [ playBarButton, nextBarButton ]
    }
    
    @objc func playSong() {
        AudioPlayer.defaultPlayer.play()
        popupItem.rightBarButtonItems = [ puseBarButton, nextBarButton ]
    }
    
    @objc func nextSong() {
        AudioPlayer.defaultPlayer.next()
    }
    
	
	var songTitle: String = "" {
		didSet {
			if isViewLoaded {
				songNameLabel.text = songTitle
			}
			popupItem.title = songTitle
		}
	}
	var albumTitle: String = "" {
		didSet {
			if isViewLoaded {
				albumNameLabel.text = albumTitle
			}
			if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 9 {
				popupItem.subtitle = albumTitle
			}
		}
	}
	var albumArt: UIImage = UIImage() {
		didSet {
			if isViewLoaded {
				albumArtImageView.image = albumArt
			}
			popupItem.image = albumArt
			popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
		}
	}
	
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        updatePlayButton()
    }
    
    @IBAction func tapNextSong(_ sender: AnyObject) {
        nextSong()
    }
    
    @IBAction func tapPreviousSong(_ sender: AnyObject) {
        AudioPlayer.defaultPlayer.previous()
    }
    
    @IBAction func onDurationSliderValChanged(_ sender: UISlider, forEvent event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
            // handle drag began
                AudioPlayer.defaultPlayer.pause()
                currenTimeLabel.text? = Int(durationSlider.value).toAudioString
                fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MusicPlayer_Play"), for: UIControlState())
            
            case .ended:
            // handle drag ended
                let value = self.durationSlider.value
                let time = CMTime(value: Int64(value), timescale: 1)
                AudioPlayer.defaultPlayer.seekToTime(time)
                fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MusicPlayer_Pause"), for: UIControlState())
                
                AudioPlayer.defaultPlayer.play()
            default:
                break
            }
        }
    }
    
    
    @IBAction func durationSliderValueChanged(_ sender: UISlider) {
        AudioPlayer.defaultPlayer.pause()
        currenTimeLabel.text? = Int(durationSlider.value).toAudioString
        fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MusicPlayer_Play"), for: UIControlState())
    }
    
    @IBAction func didEndDraginDurationSlider(_ sender: UISlider) {
        let value = self.durationSlider.value
        let time = CMTime(value: Int64(value), timescale: 1)
        AudioPlayer.defaultPlayer.seekToTime(time)
        fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MusicPlayer_Pause"), for: UIControlState())
        
        AudioPlayer.defaultPlayer.play()
    }
    
    
    func updatePlayButton() {
        if fullPlayerPlayPauseButton.imageView?.image == UIImage(named: "MusicPlayer_Play") {
            fullPlayerPlayPauseButton.setImage(UIImage(named: "MusicPlayer_Pause"), for: UIControlState())
            playSong()
        } else {
            fullPlayerPlayPauseButton.setImage(UIImage(named: "MusicPlayer_Play"), for: UIControlState())
            pauseSong()
        }
    }
}
//MARK: - AudioPlayerDelegate
extension MusicPlayerController: AudioPlayerDelegate {
    
    //MARK: - AudioPlayerDelegate
    func audioDidChangeTime(_ time: Int64) {
        //Unhide play button and hide activity indicator
        if AudioPlayer.defaultPlayer.getCurrentTime() > 0 {
            activityIndicator.stopAnimating()
            fullPlayerPlayPauseButton.isHidden = false
        }
        plaingTime = Float(time)
        let progressValue = Float(time) / Float(AudioPlayer.defaultPlayer.currentAudio.duration)
        popupItem.progress = progressValue

        durationSlider.setValue(Float(time), animated: true)

        currenTimeLabel.text = Int(time).toAudioString
        durationLabel.text = "-\((Int(trackDurationSeconds) - Int(time)).toAudioString)"
        
    }
    
    func playerWillPlayNexAudio() {
        print("Audio is finished playing..")
    }
}

