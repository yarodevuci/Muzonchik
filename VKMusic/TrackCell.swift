//
//  TrackCell.swift
//  VKMusic
//
//  Created by Yaro on 9/16/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol TrackCellDelegate {
    func cancelTapped(_ cell: TrackCell)
    func downloadTapped(_ cell: TrackCell)
}

class TrackCell: MGSwipeTableCell {

    var delegat: TrackCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var musicIndicator: ESTMusicIndicatorView!
    
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        delegat?.cancelTapped(self)
    }
    //Disabled. Use swipe guesture to download songs 
    @IBAction func downloadTapped(_ sender: AnyObject) {
        //delegate?.downloadTapped(self)
    }

}
