//
//  SearchAudioVC.swift
//  VKMusic
//
//  Created by Yaro on 9/16/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
//MARK: - DEPRECATED ...
class MainScreen: UIViewController, MGSwipeTableCellDelegate {
	
    //MARK: Override viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
    // Called when the Cancel button for a track is tapped
//    func cancelDownload(_ track: Audio) {
//        let urlString = track.url,
//        let download = activeDownloads[urlString] {
//            download.downloadTask?.cancel()
//            activeDownloads[urlString] = nil
//        }
//    }
    

}

// MARK: TrackCellDelegate
extension MainScreen: TrackCellDelegate {
    
    func cancelTapped(_ cell: TrackCell) {
//        if let indexPath = tableView.indexPath(for: cell) {
//            let track = MainScreen.searchResults[(indexPath as NSIndexPath).row]
//            //cancelDownload(track)
//            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
//        }
    }
    
    func downloadTapped(_ cell: TrackCell) {
		
    }
}


extension MainScreen: NSURLConnectionDataDelegate {
    //Disabled for now
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse)
    {
        //        let a = SearchAudioVC.searchResults
        //        let size = response.expectedContentLength
        //        for i in 0..<SearchAudioVC.searchResults.count {
        //            if a[i].url! == String(describing: response.url!) {
        //                print("\(a[i].artist) is \(Int(size) * 8 / 1000 / a[i].duration)kbps")
        //            }
        //        }
        //        print("size : \(size)")
    }
}


