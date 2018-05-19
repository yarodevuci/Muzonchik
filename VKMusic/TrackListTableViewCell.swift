//
//  TrackListTableViewCell.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TrackListTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var musicPlayIdicatorView: ESTMusicIndicatorView!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    
    var audioData: Audio? = nil {
        didSet {
            setupCell()
        }
    }
    
    var downloadData: Download? = nil {
        didSet{
            processDownloadingData()
        }
    }
    
    func processDownloadingData() {
        guard let downloadData = downloadData else {
            downloadProgressView.isHidden = true
            downloadProgressLabel.isHidden = true
            return
        }
        
        downloadProgressView.progress = downloadData.progress
        downloadProgressView.isHidden = false
        downloadProgressLabel.isHidden = false
    }
    
    func setupCell() {
        guard let audioData = audioData else { return }
        trackArtistLabel.text = audioData.artist
        trackNameLabel.text = audioData.title
        trackDurationLabel.text = audioData.duration.toAudioString
        downloadProgressView.isHidden = true
        musicPlayIdicatorView.state = .estMusicIndicatorViewStateStopped
        checkMarkImageView.isHidden = true
        albumArtworkImageView.image = audioData.thumbnail_image

    }
	
	func showESTIndicator() {
		musicPlayIdicatorView.state = .estMusicIndicatorViewStatePlaying
		albumArtworkImageView.image = nil
		albumArtworkImageView.backgroundColor = .estBackGroundColor
	}
	
	func hideESTIndicator() {
		musicPlayIdicatorView.state = .estMusicIndicatorViewStateStopped
		albumArtworkImageView.image = audioData?.thumbnail_image
		albumArtworkImageView.backgroundColor = .clear
	}
	
	override var isSelected: Bool {
		didSet{
			isSelected ? showESTIndicator() : hideESTIndicator()
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		albumArtworkImageView.layer.cornerRadius = 5
		albumArtworkImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
