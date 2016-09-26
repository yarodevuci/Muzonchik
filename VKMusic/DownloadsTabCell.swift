//
//  DownloadsTabCell.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/20/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit

protocol DownloadsTabCellDelegate {
    func playPauseButtonTapped(_ cell: DownloadsTabCell)
}

class DownloadsTabCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var delegate: DownloadsTabCellDelegate?

    @IBAction func playPauseButtonTapped(_ sender: AnyObject) {
        delegate?.playPauseButtonTapped(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
