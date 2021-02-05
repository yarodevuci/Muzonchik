//
//  CompactMusicPlayerVC.swift
//  Muzonchik
//
//  Created by Yaro on 3/2/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import LNPopupController
import MediaPlayer

class CompactMusicPlayerVC: UIViewController, UIGestureRecognizerDelegate {
	//MARK: - @IBOutlet
	@IBOutlet weak var musicControlsView: UIView!
	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var currenTimeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var durationSlider: UISlider!
	@IBOutlet weak var albumArtImageView: UIImageView!
	@IBOutlet weak var fullPlayerPlayPauseButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
	//MARK: - Constants
	
	//MARK: - Variables
	var playBarButton: UIBarButtonItem!
	var puseBarButton: UIBarButtonItem!
	var nextBarButton: UIBarButtonItem!
	var plaingTime = Float(0)
	var trackDurationSeconds = 0
	var tracks = [Audio]()
	var currentIndexPathRow = -1
    
    let volume = SubtleVolume(style: .rounded)
    
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
		puseBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Pause"), style: .plain, target: self, action: #selector(pauseSong))
		nextBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Forward"), style: .plain, target: self, action: #selector(nextSong))
		
		playBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MiniPlayer_Play"), style: .plain, target: self, action: #selector(playSong))
		
		if UserDefaults.standard.object(forKey: "PopupSettingsBarStyle") as? LNPopupBarStyle == LNPopupBarStyle.compact || ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10 {
			popupItem.leftBarButtonItems = [ puseBarButton ]
			popupItem.rightBarButtonItems = [ nextBarButton ]
		}
		else {
			popupItem.rightBarButtonItems = [ puseBarButton, nextBarButton ]
		}
        
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        view.backgroundColor = .black

		tableView.reloadData()
	}
    
    override var viewForPopupInteractionGestureRecognizer: UIView {
        return UIView()
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		tableView.scrollToRow(at: IndexPath(row: currentIndexPathRow, section: 0), at: .none, animated: true)
	}
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
	func setupUI() {
		setupVolumeBar()
		updateCurrentTrackInfo()
		musicControlsView.layer.cornerRadius = 10
		albumArtImageView.layer.cornerRadius = 5
		albumArtImageView.clipsToBounds = true
				
		AudioPlayer.defaultPlayer.delegate = self
		
		durationSlider.setThumbImage(#imageLiteral(resourceName: "circle"), for: UIControl.State())
	}
	
	func setupVolumeBar() {
        volume.barTintColor = .white
        volume.barBackgroundColor = UIColor.white.withAlphaComponent(0.3)
        volume.animation = .fadeIn
        volume.delegate = self
        volume.padding = CGSize(width: 2, height: 8)
        volume.frame = CGRect(x: 16, y: 28, width: 60, height: 20)
        
        view.addSubview(volume)
	}
	
	func updateCurrentTrackInfo() {
		AudioPlayer.defaultPlayer.setPlayList(tracks)
		AudioPlayer.index = currentIndexPathRow
		//Update topview track info labels
		songNameLabel.text = tracks[currentIndexPathRow].artist
		albumNameLabel.text = tracks[currentIndexPathRow].title
		albumArtImageView.image = tracks[currentIndexPathRow].thumbnail_image
        
        albumArtImageView.contentMode = tracks[currentIndexPathRow].thumbnail_image == UIImage(named: "ArtPlaceholder") ? .center : .scaleAspectFill
        
		//Update popupItem text
		popupItem.title = tracks[currentIndexPathRow].artist
		popupItem.subtitle = tracks[currentIndexPathRow].title
		popupItem.image = tracks[currentIndexPathRow].thumbnail_image
		trackDurationSeconds = tracks[currentIndexPathRow].duration
		durationSlider.maximumValue = Float(trackDurationSeconds)
		
        NotificationCenter.default.post(name: .playTrackAtIndex, object: nil, userInfo: ["index" : currentIndexPathRow])
	}
	
	func updatePlayButton() {
		if fullPlayerPlayPauseButton.imageView?.image == #imageLiteral(resourceName: "MPPlay") {
			fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPause"), for: UIControl.State())
			playSong()
		} else {
			fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPlay"), for: UIControl.State())
			pauseSong()
		}
	}
	
	func setPlayButtonIconToPause() {
		fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPause"), for: UIControl.State())
	}
	
	func setPlayButtonIconToPlay() {
		fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPlay"), for: UIControl.State())
	}
    
    func prepPlayerControlsUIForNewSong(with duration: String) {
        currenTimeLabel.text = "0:00"
        durationLabel.text = "-\(duration)"
        durationSlider.value = 0
        popupItem.progress = 0
    }
	
	func playLocalTrack(track: Audio) {
        //Reset values
        prepPlayerControlsUIForNewSong(with: track.duration.toAudioString)
        
		let trackPath = "\(track.title)_\(track.artist)_\(track.duration).mp\(track.url.last ?? "3")"
		AudioPlayer.defaultPlayer.playAudio(fromURL: AppDirectory.getDownloadsFolderURL().appendingPathComponent(trackPath))
	}
	
    func playRemoteTrack(for track: Audio) {
        prepPlayerControlsUIForNewSong(with: track.duration.toAudioString)
        fullPlayerPlayPauseButton.isHidden = true
        activityIndicator.startAnimating()
        
		let sourceURL = URL(string: track.url)
        DispatchQueue.global(qos: .background).async {
            AudioPlayer.defaultPlayer.playAudio(fromURL: sourceURL)
        }
	}
	
	func playNextTrack() {
		var nextIndex = currentIndexPathRow + 1
		
		if nextIndex > (tracks.count - 1) {
			nextIndex = 0
		}
		tableView.selectRow(at: IndexPath(row: nextIndex, section: 0), animated: true, scrollPosition: .none)
		tableView(tableView, didSelectRowAt: IndexPath(row: nextIndex, section: 0))
		tableView.scrollToRow(at: IndexPath(row: nextIndex, section: 0), at: .none, animated: true)
		
		NotificationCenter.default.post(name: .playTrackAtIndex, object: nil, userInfo: ["index" : nextIndex])
	}
	
	func playPreviousTrack() {
		var nextIndex = currentIndexPathRow - 1
		
		if nextIndex < 0 {
			nextIndex = tracks.count - 1
		}
		tableView.selectRow(at: IndexPath(row: nextIndex, section: 0), animated: true, scrollPosition: .none)
		tableView(tableView, didSelectRowAt: IndexPath(row: nextIndex, section: 0))
		tableView.scrollToRow(at: IndexPath(row: nextIndex, section: 0), at: .none, animated: true)
		
		NotificationCenter.default.post(name: .playTrackAtIndex, object: nil, userInfo: ["index" : nextIndex])
	}
	
	//Play pause songs
	@objc func pauseSong() {
		AudioPlayer.defaultPlayer.pause()
		setPlayButtonIconToPlay()
		popupItem.rightBarButtonItems = [ playBarButton, nextBarButton ]
		
		guard let cell = tableView.cellForRow(at: IndexPath(row: currentIndexPathRow, section: 0)) as? TrackTableViewCell else { return }
		cell.musicPlayIdicatorView.state = .estMusicIndicatorViewStatePaused
	}
	
	@objc func playSong() {
		AudioPlayer.defaultPlayer.play()
		setPlayButtonIconToPause()
		popupItem.rightBarButtonItems = [ puseBarButton, nextBarButton ]
		guard let cell = tableView.cellForRow(at: IndexPath(row: currentIndexPathRow, section: 0)) as? TrackTableViewCell else { return }
		cell.musicPlayIdicatorView.state = .estMusicIndicatorViewStatePlaying
	}
	
	@objc func nextSong() {
		AudioPlayer.defaultPlayer.next()
	}
	
	@IBAction func didTapPlayPauseButton(_ sender: UIButton) {
		updatePlayButton()
	}
	
	@IBAction func tapNextSong(_ sender: AnyObject) {
		//nextSong()
		playNextTrack()
	}
	
	@IBAction func tapPreviousSong(_ sender: AnyObject) {
		//AudioPlayer.defaultPlayer.previous()
		playPreviousTrack()
	}
	
	@IBAction func onDurationSliderValChanged(_ sender: UISlider, forEvent event: UIEvent) {
		if let touchEvent = event.allTouches?.first {
			switch touchEvent.phase {
			case .began:
				// handle drag began
				AudioPlayer.defaultPlayer.pause()
				currenTimeLabel.text = Int(durationSlider.value).toAudioString
				print(Int(durationSlider.value).toAudioString)
				fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPlay"), for: UIControl.State())
				
			case .moved:
				// handle drag moved
				currenTimeLabel.text = Int(durationSlider.value).toAudioString
				durationLabel.text = "-\((Int(trackDurationSeconds) - Int(durationSlider.value)).toAudioString)"
				
			case .ended:
				/// handle drag ended
				let value = self.durationSlider.value
				let time = CMTime(value: Int64(value), timescale: 1)
				AudioPlayer.defaultPlayer.seekToTime(time)
				fullPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "MPPause"), for: UIControl.State())
				
				AudioPlayer.defaultPlayer.play()
				
			default:
				break
			}
		}
	}
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        popupPresentationContainer?.closePopup(animated: true, completion: nil)
    }
    
}

//MARK: - AudioPlayerDelegate
extension CompactMusicPlayerVC: AudioPlayerDelegate {
	
	func audioDidChangeTime(_ time: Int64) {
		//Unhide play button and hide activity indicator
        activityIndicator.stopAnimating()
        fullPlayerPlayPauseButton.isHidden = false

		plaingTime = Float(time)
		let progressValue = Float(time) / Float(AudioPlayer.defaultPlayer.currentAudio.duration)
		popupItem.progress = progressValue
		
		durationSlider.value = Float(time)
		
		currenTimeLabel.text = Int(time).toAudioString
		durationLabel.text = "-\((Int(trackDurationSeconds) - Int(time)).toAudioString)"
		
        let track = tracks[currentIndexPathRow]
        
        if track.duration > 600 {
            UserDefaults.standard.set(Double(time), forKey: track.url)
        }
	}
	
	func playerWillPlayNexAudio() {
		print("Playing next aduio...")
		playNextTrack()
	}
	
	func playerWillPlayPreviousAudio() {
		print("Playing previous aduio...")
		playPreviousTrack()
	}
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension CompactMusicPlayerVC: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.ulpOfOne
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tracks.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
		cell.setTrackInfo = tracks[indexPath.row]
        cell.albumArtworkImageView.image = tracks[indexPath.row].thumbnail_image
		cell.isSelected = currentIndexPathRow == indexPath.row
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if currentIndexPathRow != indexPath.row {
			currentIndexPathRow = indexPath.row
			setPlayButtonIconToPause()
			updateCurrentTrackInfo()
			
			let track = tracks[indexPath.row]
			albumArtImageView.image = tracks[indexPath.row].thumbnail_image
            albumArtImageView.contentMode = tracks[currentIndexPathRow].thumbnail_image == UIImage(named: "ArtPlaceholder") ? .center : .scaleAspectFill
            GlobalFunctions.shared.localFileExistsForTrack(track) ? playLocalTrack(track: track) : playRemoteTrack(for: track)
			
			tableView.reloadData()
		}
	}
}

extension CompactMusicPlayerVC: SubtleVolumeDelegate {
    func subtleVolume(_ subtleVolume: SubtleVolume, accessoryFor value: Double) -> UIImage? {
        return value > 0 ? #imageLiteral(resourceName: "volume-on.pdf") : #imageLiteral(resourceName: "volume-off.pdf")
    }
}
