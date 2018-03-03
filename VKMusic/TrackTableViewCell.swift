//
//  TrackTableViewCell.swift
//  Muzonchik
//
//  Created by Yaro on 3/2/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
	
	@IBOutlet weak var checkMarkImageView: UIImageView!
	@IBOutlet weak var trackArtistLabel: UILabel!
	@IBOutlet weak var trackNameLabel: UILabel!
	@IBOutlet weak var trackDurationLabel: UILabel!
	@IBOutlet weak var musicPlayIdicatorView: ESTMusicIndicatorView!
	@IBOutlet weak var albumArtworkImageView: UIImageView!
	
	
	var setTrackInfo: Audio? {
		didSet {
			setupTrackInfo()
		}
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
	
	func setupTrackInfo() {
		guard let audio = setTrackInfo else { return }
		trackNameLabel.text = audio.title
		trackDurationLabel.text = audio.duration.toAudioString
		trackArtistLabel.text = audio.artist
		checkMarkImageView.isHidden = !GlobalFunctions.shared.localFileExistsForTrack(audio)
	}
	
	func showESTIndicator() {
		musicPlayIdicatorView.state = .estMusicIndicatorViewStatePlaying
		albumArtworkImageView.image = nil
		albumArtworkImageView.backgroundColor = .estBackGroundColor
	}
	
	func hideESTIndicator() {

		musicPlayIdicatorView.state = .estMusicIndicatorViewStateStopped
		albumArtworkImageView.image = #imageLiteral(resourceName: "ArtPlaceholder")
		albumArtworkImageView.backgroundColor = .clear
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
