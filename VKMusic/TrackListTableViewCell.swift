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
    @IBOutlet weak var albumCoverTintView: UIView!
    
    override var isSelected: Bool {
        didSet {
            setEST_Indicator(to: isSelected)
        }
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtworkImageView.layer.cornerRadius = 5
        albumArtworkImageView.clipsToBounds = true
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
    
    func setEST_Indicator(to isOn: Bool) {
        albumCoverTintView.isHidden = !isOn
        musicPlayIdicatorView.state = isOn ? .estMusicIndicatorViewStatePlaying : .estMusicIndicatorViewStateStopped
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
