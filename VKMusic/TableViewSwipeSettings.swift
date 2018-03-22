//
//  TableViewSwipeSettings.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

//MARK: - MGSwipeTableCellDelegate
extension TrackListTableVC: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        guard let indexPath = self.tableView.indexPath(for: cell) else {return false }
        let track = audioFiles[indexPath.row]
        return direction == .leftToRight && !localFileExistsForTrack(track) && activeDownloads[audioFiles[indexPath.row].url] == nil
    }
    
    //MGSwipeTableCell
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        swipeSettings.transition = MGSwipeTransition.border
        expansionSettings.buttonIndex = 0
        
        if direction == MGSwipeDirection.leftToRight {
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.5
        }
        return [
            MGSwipeButton(title: "Get", backgroundColor: .pinkColor, callback: { (cell) -> Bool in
                guard let indexPath = self.tableView.indexPath(for: cell) else { return false }
                let track = self.audioFiles[indexPath.row]
                print("Downloading \(track.title)")
                self.startDownload(track)
                self.tableView.reloadRows(at: [IndexPath(row: (indexPath.row), section: 0)], with: .none)
                return true
            })
        ]
    }
}
